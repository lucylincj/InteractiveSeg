%///
% main class for testing and demo
% already blocked the interactive part
% please change paths to load in different image set (line 12-14)
% @parameter: input'SLIC' or 'SLICO'
% @author: r01942054@ntu
% @date: 05.2013
%
%function main(name, param11, param12, lambda)
function main(name, version, params)
    global oriImg numSegments meanColor meanCoord fSeg bSeg segments colorDis meanTexture;
    warning off;
    %parameters
    infinite = 999999;
    %name = '0_15_15742';
    path = 'D:/InteractiveSegTestImage/';
    imgPath = strcat(path, name, '.jpg');
    superpixelPath = [path, 'SLICO/300/', name, '.dat'];
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

    %//////////////////ERS/////////////////////////////////////////////%
%     grey_img = double(rgb2gray(oriImg));
%     nC = floor(w*h/300);
%     t = cputime;
%     [segments] = mex_ers(grey_img,nC);
%     numSegments = max(max(segments)) + 1;
%     fprintf(1,'Use %f sec. \n',cputime-t);
%     fprintf(1,'\t to divide the image into %d superpixels.\n',nC);
    
    %//////////////////////////////////////////////////////////////////%
    
    %compute mean color of each segment
    meanColor = zeros(3, numSegments);
    meanCoord = zeros(2, numSegments);
    texture = extractTexture(rgb2gray(oriImg));
    meanTexture = zeros(16, numSegments);
    for i = 1:numSegments
        [x,y] = find(segments==i-1);
        sz = size(x, 1);
        meanColor(1, i) = sum( sum(img(x,y,1)) )/sz;
        meanColor(2, i) = sum( sum(img(x,y,2)) )/sz;
        meanColor(3, i) = sum( sum(img(x,y,3)) )/sz;
        meanCoord(1, i) = sum(x)/sz;
        meanCoord(2, i) = sum(y)/sz;
        meanTexture(1, i) = sum(texture(1, segments==i-1))/sz;
        meanTexture(2, i) = sum(texture(2, segments==i-1))/sz;
        meanTexture(3, i) = sum(texture(3, segments==i-1))/sz;
        meanTexture(4, i) = sum(texture(4, segments==i-1))/sz;
        meanTexture(5, i) = sum(texture(5, segments==i-1))/sz;
        meanTexture(6, i) = sum(texture(6, segments==i-1))/sz;
        meanTexture(7, i) = sum(texture(7, segments==i-1))/sz;
        meanTexture(8, i) = sum(texture(8, segments==i-1))/sz;
        meanTexture(9, i) = sum(texture(9, segments==i-1))/sz;
        meanTexture(10, i) = sum(texture(10, segments==i-1))/sz;
        meanTexture(11, i) = sum(texture(11, segments==i-1))/sz;
        meanTexture(12, i) = sum(texture(12, segments==i-1))/sz;
        meanTexture(13, i) = sum(texture(13, segments==i-1))/sz;
        meanTexture(14, i) = sum(texture(14, segments==i-1))/sz;
        meanTexture(15, i) = sum(texture(15, segments==i-1))/sz;
        meanTexture(16, i) = sum(texture(16, segments==i-1))/sz;
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
    [dF dB dTF dTB] = updateMinDis(uncertain);
    toc
   
    tic 
    %distinguish neighbors
    neighboring = FindNeighbor();
    colorDis = pdist2(meanColor', meanColor').*neighboring;
    toc
    
    tic
    %compute E1 E2
    E1 = updateE1(version, infinite, dF, dB, dTF, dTB);
	E2 = updateE2(version, neighboring, params) ;
    toc

    tic
    hinc = BK_Create(numSegments,2*numSegments);
    BK_SetUnary(hinc, E1); 
    BK_SetNeighbors(hinc, E2);
    e_inc = BK_Minimize(hinc);
    lab = BK_GetLabeling(hinc);
    BK_Delete(hinc);
    toc
    
    
    [newImg map] = drawResults(lab);
    dir = [path, 'result/SLICO/300/', name, '/'];
%    dir = [path, 'result/SLICO/300/', name, '/Cr_052601/', int2str(param11),'_', int2str(param12),'/',int2str(lambda),'/'];
%     dir = [path, 'result/SLICO/300/', int2str(lambda),'/'];
    if (exist(dir, 'dir') == 0), mkdir(dir); end
	imwrite(newImg, [dir,name,'_ver1_',int2str(params(1)), '_', int2str(params(2)), '_', int2str(params(3)), '.jpg']);
    imwrite(map*255, [dir,'map_', name,'_ver1_',int2str(params(1)), '_', int2str(params(2)), '_', int2str(params(3)), '.bmp']);
    %imwrite(newImg, [dir,name,'_', version, '_', int2str(lambda), '.jpg']);
    
    %///////////////////////STEP 2/////////////////////////////%
    %load mask 2
%     imgMask2 = imread(maskPath2);
%     
%     %identify ambiguous segments
%     uSeg = zeros(numSegments, 4);
%     [new_f1, new_f2] = find(imgMask2(:,:,1) - imgMask2(:,:,2) > 200);
%     [new_b1, new_b2] = find(imgMask2(:,:,3) - imgMask2(:,:,2) > 200);
%     for i = 1:size(new_f1, 1)
%         if(uSeg(segments(new_f1(i), new_f2(i))+1, 1) ~= 1 && fSeg(segments(new_f1(i), new_f2(i))+1) ~=1 )
%             uSeg(segments(new_f1(i), new_f2(i))+1, 1) = 1;
%             uSeg(segments(new_f1(i), new_f2(i))+1, 2) = 1;
%             uSeg(segments(new_f1(i), new_f2(i))+1, 3) = new_f1(i);
%             uSeg(segments(new_f1(i), new_f2(i))+1, 4) = new_f2(i);
%         end
%     end
%     for i = 1:size(new_b1, 1)
%         if(uSeg(segments(new_b1(i), new_b2(i))+1, 1) ~= 1 && bSeg(segments(new_b1(i), new_b2(i))+1) ~=1 )
%             uSeg(segments(new_b1(i), new_b2(i))+1, 1) = 1;
%             uSeg(segments(new_b1(i), new_b2(i))+1, 2) = 0;
%             uSeg(segments(new_b1(i), new_b2(i))+1, 3) = new_b1(i);
%             uSeg(segments(new_b1(i), new_b2(i))+1, 4) = new_b2(i);
%         end
%     end
%     
%     seg = find(uSeg(:,1)==1);
%     
%     for i = 1:size(seg, 1)
%         [idx, M] = testBranch(oriImg, segments, seg(i)-1, uSeg(seg(i),:));
%         map(idx(1):idx(2), idx(3):idx(4)) = M;
%         %drawFineResults(oriImg, segments, lab, idx, M, seg(i)-1);
%     end
%     %restore other segments
%     for i = 1:numSegments
%         if(uSeg(i, 1) ~= 1)
%             map(segments==i-1) = lab(i) -1;
%         end
%     end
%     resultImg(:, :, 1)  = oriImg(:, :, 1) .* uint8(map);
%     resultImg(:, :, 2)  = oriImg(:, :, 2) .* uint8(map);
%     resultImg(:, :, 3)  = oriImg(:, :, 3) .* uint8(map);
% 
%     figure; imshow(resultImg);

end
  