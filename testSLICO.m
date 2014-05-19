function testSLICO(name, sizes)
    global oriImg numSegments meanColor meanCoord fSeg bSeg segments;
    for j = 1:size(sizes, 2)
        %parameters
        infinite = 999999;
        path = 'D:/InteractiveSegTestImage/';
        imgPath = strcat(path, name, '.jpg');
        superpixelPath = [path, 'SLICO_dat/', name, '_', sizes(j), '.dat'];
        maskPath = [path, 'mask1/', name, '_mask1.jpg'];

        %add necessary path
        addpath('Bk') ;
        addpath('Bk/bin') ;
        addpath(genpath('vlfeat-0.9.18')) ;

        %load image
        oriImg = imread(imgPath);
        img = im2single(oriImg) ;
        w = size(img, 1);
        h = size(img, 2);

        %load mask
        imgMask = imread(maskPath);

        %load and build graphcut library
        %BK_BuildLib; disp('BuildLib PASSED');
        %BK_LoadLib;  disp('LoadLib PASSED');

        fid=fopen(superpixelPath,'rt');
        A = fread(fid,'*uint32');
        fclose(fid);
        segments = reshape(A, h, w)';
        numSegments = max(A) + 1;
        
        %compute mean color of each segment
        meanColor = zeros(3, numSegments);
        meanCoord = zeros(2, numSegments);

        for i = 1:numSegments
            [x,y] = find(segments==i-1);
            meanColor(1, i) = sum( sum(img(x,y,1)) )/size(x,1);
            meanColor(2, i) = sum( sum(img(x,y,2)) )/size(x,1);
            meanColor(3, i) = sum( sum(img(x,y,3)) )/size(x,1);
            meanCoord(1, i) = sum(x)/size(x,1);
            meanCoord(2, i) = sum(y)/size(y,1);
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

        tic
        %calculate dF, dB
        [dF dB] = updateMinDis(uncertain);
        toc

        tic 
        %distinguish neighbors
        neighboring = FindNeighbor();
        toc

        tic
        %compute E1 E2
        E1 = updateE1(dF, dB, infinite);
        E2 = updateE2(neighboring) ;
        toc

        tic
        hinc = BK_Create(numSegments,2*numSegments);
        BK_SetUnary(hinc, E1); 
        BK_SetNeighbors(hinc, E2);
        e_inc = BK_Minimize(hinc);
        lab = BK_GetLabeling(hinc);
        BK_Delete(hinc);
        toc

        map = drawResults(lab);
    end
end