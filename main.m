function main(superpixel)
    %add necessary path
    addpath('Bk') ;
    addpath('Bk/bin') ;
    addpath(genpath('vlfeat-0.9.18')) ;

    %parameters
    infinite = 999999;

    %load image
    imgPath = 'images/flowers.png';
    oriImg = imread(imgPath);
    img = im2single(oriImg) ;
    w = size(img, 1);
    h = size(img, 2);
    
    %load mask
    maskPath = 'mask/flowers_mask.jpg';
    imgMask = imread(maskPath);

    %load and build graphcut library
    %BK_BuildLib; disp('BuildLib PASSED');
    %BK_LoadLib;  disp('LoadLib PASSED');
    
    if(strcmp(superpixel, 'SLIC'))
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
        
    elseif(strcmp(superpixel, 'SLICO'))
        fid=fopen('images/flowers.dat','rt');
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
    [f1, f2] = find(imgMask(:,:,1) - imgMask(:,:,2) > 200);
    [b1, b2] = find(imgMask(:,:,3) - imgMask(:,:,2) > 200);
    for i = 1:size(f1, 1)
        fSeg(segments(f1(i), f2(i))+1) = 1;
    end
    for i = 1:size(b1, 1)
        bSeg(segments(b1(i), b2(i))+1) = 1;
    end
    uncertain = find((fSeg - bSeg)==0);%this will not be changed

    %calculate dF, dB

    [dF dB] = updateMinDis(uncertain, numSegments, mC, fSeg, bSeg);
    toc
    % %temp
    %calculate mean color of forground and background
    % f_mC = [mC(1,:)*fSeg' mC(2,:)*fSeg' mC(3,:)*fSeg'];
    % f_mC = f_mC / sum(fSeg);
    % b_mC = [mC(1,:)*bSeg' mC(2,:)*bSeg' mC(3,:)*bSeg'];
    % b_mC = b_mC / sum(bSeg);

    % for i = 1:size(uncertain, 1)
    %     dF(i) = sqrt((f_mC - mC(:, i)') * (f_mC - mC(:, i)')');
    %     dB(i) = sqrt((b_mC - mC(:, i)') * (b_mC - mC(:, i)')');
    % end


    %distinguish neighbors
    tic
%     neighboring = zeros(numSegments, numSegments);
%     seg2 = [0 1 0; 1 1 1; 0 1 0];
%     for i = 1:numSegments
%         seg1 = zeros(w, h);
%         seg1(segments==i-1) = 1;
%         x = 0; y = 0;
%         result = imdilate(seg1, seg2) - seg1;
%         [x, y] = find(result==1);
%         for k = 1:size(x, 1)
%             neighboring(i, segments(x, y)+1) = 1;
%         end
%     end
    neighboring = FindNeighbor(segments, numSegments);
    toc
    
    tic
    %compute E1 E2
    E1 = updateE1(numSegments, fSeg, bSeg, dF, dB, infinite);
    E2 = updateE2(numSegments, fSeg, bSeg, neighboring, mC) ;
    toc
    %lambda = 16;
    %while (lambda >= 1)
    tic
        hinc = BK_Create(numSegments,2*numSegments);
        BK_SetUnary(hinc, E1); 
        BK_SetNeighbors(hinc, E2);
        e_inc = BK_Minimize(hinc);
        lab = BK_GetLabeling(hinc);

        drawResults(oriImg, segments, lab);

        %//////////////////////////new round values/////////////////////////
    %     fSeg = lab - 1;
    %     bSeg = 1 - fSeg;
    %     
    %     [dF dB] = updateMinDis(uncertain, numSegments, mC, fSeg, bSeg);
    %     E1 = updateE1(numSegments, fSeg, bSeg, dF, dB, infinite);
    %     E2 = updateE2(numSegments, fSeg, bSeg, neighboring, mC) ;

    %     hnew = BK_Create(numSegments,2*numSegments);
    %     BK_SetNeighbors(hnew,E2);
    %     BK_SetUnary(hnew,E1); 
    %     %tic; 
    %     e_new = BK_Minimize(hnew);
    %     time_new(end+1) = toc;
    %     BK_Delete(h new);

        %Assert(abs(e_inc - e_new) < 1e-6);
        BK_Delete(hinc);
        %lambda = lambda*0.9;
    %end 
    toc

    %release memory
    %BK_Delete(hinc);

end
  