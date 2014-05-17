%///
% main class for testing and demo
% already blocked the interactive part
% please change paths to load in different image set (line 12-14)
% @parameter: input'SLIC' or 'SLICO'
% @author: lucylin
% @date: 05.2013
%
function main()
    %parameters
    infinite = 999999;
    name = '3_111_111965';
    path = 'D:/InteractiveSegTestImage/';
    imgPath = [path, name, '.jpg'];
    superpixelPath = [path, 'SLICO_dat/', name, '.dat'];
    maskPath = [path, 'mask1/', name, '_mask1.jpg'];
    maskPath2 = [path, 'mask2/', name, '_mask2.jpg'];
    
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
    
%     if(strcmp(superpixel, 'SLIC'))
%         regionSize = 20 ;
%         regularizer = 10 ; 
%         tic
%         segments = vl_slic(img, regionSize, regularizer, 'verbose') ;
%         toc
%         %save test.dat segments;
%         
%         %show superpixel result
%         [sx,sy]=vl_grad(double(segments), 'type', 'forward') ;
%         s = find(sx | sy) ;
%         imp = img ;
%         imp([s s+numel(img(:,:,1)) s+2*numel(img(:,:,1))]) = 0 ;
%         figure; imagesc(imp) ;
%         %figure; imagesc(segments);
%         numSegments = segments(w,h) + 1;
%         
%     elseif(strcmp(superpixel, 'SLICO'))
        fid=fopen(superpixelPath,'rt');
        A = fread(fid,'*uint32');
        fclose(fid);
        segments = reshape(A, h, w)';
        numSegments = max(A) + 1;
        %//////////////////////////////////////////////////////////////%
%     end

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
    
    tic
    %calculate dF, dB
    [dF dB] = updateMinDis(uncertain, numSegments, mC, fSeg, bSeg);
    toc
   
    tic 
    %distinguish neighbors
    neighboring = FindNeighbor(segments, numSegments);
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
    BK_Delete(hinc);
    toc
    
    tic
    map = drawResults(oriImg, segments, lab);
    toc
    
    %///////////////////////STEP 2/////////////////////////////%
    %load mask 2
    imgMask2 = imread(maskPath2);
    
    %identify ambiguous segments
    uSeg = zeros(numSegments, 4);
    [new_f1, new_f2] = find(imgMask2(:,:,1) - imgMask2(:,:,2) > 200);
    [new_b1, new_b2] = find(imgMask2(:,:,3) - imgMask2(:,:,2) > 200);
    for i = 1:size(new_f1, 1)
        if(uSeg(segments(new_f1(i), new_f2(i))+1, 1) ~= 1 && fSeg(segments(new_f1(i), new_f2(i))+1) ~=1 )
            uSeg(segments(new_f1(i), new_f2(i))+1, 1) = 1;
            uSeg(segments(new_f1(i), new_f2(i))+1, 2) = 1;
            uSeg(segments(new_f1(i), new_f2(i))+1, 3) = new_f1(i);
            uSeg(segments(new_f1(i), new_f2(i))+1, 4) = new_f2(i);
        end
    end
    for i = 1:size(new_b1, 1)
        if(uSeg(segments(new_b1(i), new_b2(i))+1, 1) ~= 1 && bSeg(segments(new_b1(i), new_b2(i))+1) ~=1 )
            uSeg(segments(new_b1(i), new_b2(i))+1, 1) = 1;
            uSeg(segments(new_b1(i), new_b2(i))+1, 2) = 0;
            uSeg(segments(new_b1(i), new_b2(i))+1, 3) = new_b1(i);
            uSeg(segments(new_b1(i), new_b2(i))+1, 4) = new_b2(i);
        end
    end
    
    seg = find(uSeg(:,1)==1);
    
    for i = 1:size(seg, 1)
        [idx, M] = testBranch(oriImg, segments, seg(i)-1, uSeg(seg(i),:));
        map(idx(1):idx(2), idx(3):idx(4)) = M;
        %drawFineResults(oriImg, segments, lab, idx, M, seg(i)-1);
    end
    %restore other segments
    for i = 1:numSegments
        if(uSeg(i, 1) ~= 1)
            map(segments==i-1) = lab(i) -1;
        end
    end
    resultImg(:, :, 1)  = oriImg(:, :, 1) .* uint8(map);
    resultImg(:, :, 2)  = oriImg(:, :, 2) .* uint8(map);
    resultImg(:, :, 3)  = oriImg(:, :, 3) .* uint8(map);

    figure; imshow(resultImg);

end
  