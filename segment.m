function Segment(imgPath)
    global sopt fgpixels bgpixels spflag;
    
    % Segmented output placeholder
    %SegImage = zeros(size(ImName));
    [pathstr, name, ext] = fileparts(imgPath);

    % GUI specific flag
    fgflag = 2;

    %add necessary path
    addpath('Bk') ;
    addpath('Bk/bin') ;
    addpath(genpath('vlfeat-0.9.18')) ;

    %parameters
    infinite = 9999;

    %load image
    %imgPath = 'images/flowers.png';
    oriImg = imread(imgPath);
    img = im2single(oriImg) ;
    w = size(img, 1);
    h = size(img, 2);
    
    %load mask
    maskPath = ['mask/', name, '_mask','.jpg'];
    imgMask = imread(maskPath);

    %load and build graphcut library
    %BK_BuildLib; disp('BuildLib PASSED');
    %BK_LoadLib;  disp('LoadLib PASSED');
    
    if(spflag == 1) %SLIC
        regionSize = 20 ;
        regularizer = 5 ; 
        segments = vl_slic(img, regionSize, regularizer, 'verbose') ;
        %save test.dat segments;
        
        %show superpixel result
        [sx,sy]=vl_grad(double(segments), 'type', 'forward') ;
        s = find(sx | sy) ;
        imp = img ;
        imp([s s+numel(img(:,:,1)) s+2*numel(img(:,:,1))]) = 0 ;
        figure; imagesc(imp) ;
        %figure; imagesc(segments);
        numSegments = segments(w,h) + 1;
        
    elseif(spflag == 2) %SLICO
        fid=fopen('images/flowers_514.dat','rt');
        A = fread(fid,'*uint32');
        fclose(fid);
        segments = reshape(A, h, w)';
        numSegments = max(A) + 1;
        %//////////////////////////////////////////////////////////////%
    end
    tic
    %compute mean color of each segment
    mC = zeros(3, numSegments);

    for i = 1:numSegments
        [x,y] = find(segments==i-1);
        mC(1, i) = sum( sum(img(x,y,1)) )/size(x,1);
        mC(2, i) = sum( sum(img(x,y,2)) )/size(x,1);
        mC(3, i) = sum( sum(img(x,y,3)) )/size(x,1);
    end


    %initilize forground and background segment
    fSeg = zeros(1, numSegments);
    bSeg = zeros(1, numSegments);
    %[f1, f2] = find(imgMask(:,:,1) - imgMask(:,:,2) > 200);
    %[b1, b2] = find(imgMask(:,:,3) - imgMask(:,:,2) > 200);
    % Get Foreground and Background Pixels
    FY = fgpixels(:,1);
    FX = fgpixels(:,2);

    BY = bgpixels(:,1);
    BX = bgpixels(:,2);
    for i = 1:size(FX, 1)
        fSeg(segments(FX(i), FY(i))+1) = 1;
    end
    for i = 1:size(BX, 1)
        bSeg(segments(BX(i), BY(i))+1) = 1;
    end
    uncertain = find((fSeg - bSeg)==0);%this will not be changed

    %calculate dF, dB
    [dF dB] = updateMinDis(uncertain, numSegments, mC, fSeg, bSeg);
    toc

    %distinguish neighbors
    tic
    neighboring = zeros(numSegments, numSegments);
    seg2 = [0 1 0; 1 1 1; 0 1 0];
    for i = 1:numSegments
        seg1 = zeros(w, h);
        seg1(segments==i-1) = 1;
        x = 0; y = 0;
        result = imdilate(seg1, seg2) - seg1;
        [x, y] = find(result==1);
        for k = 1:size(x, 1)
            neighboring(i, segments(x, y)+1) = 1;
        end
    end
    toc
  
    tic
    %compute E1 E2
    E1 = updateE1(numSegments, fSeg, bSeg, dF, dB, infinite);
    E2 = updateE2(numSegments, fSeg, bSeg, neighboring, mC) ;
    toc

    tic
    hinc = BK_Create(numSegments,2*numSegments);
    BK_SetUnary(hinc, E1); 
    BK_SetNeighbors(hinc, E2);
    e_inc = BK_Minimize(hinc);
    lab = BK_GetLabeling(hinc);

    drawResults(oriImg, segments, lab);

    BK_Delete(hinc);

    toc

end