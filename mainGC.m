%///
% main class for testing GrabCut database
% already blocked the interactive part
% please change paths to load in different image set (line 12-14)
%
% @author: r01942054@ntu
% @date: 05.2013
%
%function main(name, param11, param12, lambda)
function mainGC(version, name, params, type)
    global oriImg numSegments meanColor meanCoord fSeg bSeg segments colorDis texDis lumDis meanTexture closebSeg;
    warning off;
    %parameters: change paths if needed
    infinite = 999999;
    path = 'D:/InteractiveSegTestImage/GrabcutDatabase/';
    dir = [path, 'result/ERS/200/'];
    imgPath = strcat(path, 'data_GT/', name, type);
    superpixelPath = [path, 'SLICO/200/', name, '.dat'];
    ERSPath = [path, 'ERS/200/', name, '.mat'];
    maskPath = [path, 'boundary_GT_lasso/', name, '.bmp'];
    %maskPath = [path, 'mask1/', name, '_mask1.jpg'];
    %maskPath2 = [path, 'mask2/', name, '_mask2.jpg'];
    
    %add necessary path
    addpath('Bk') ;
    addpath('Bk/bin') ;
    addpath(genpath('vlfeat-0.9.18')) ;
    addpath('testGCUtil') ;

    %load image
    oriImg = imread(imgPath);
    %img = im2single(oriImg) ;
    img = oriImg;
    w = size(img, 1);
    h = size(img, 2);
    
    %load mask
    imgMask = imread(maskPath);

    %load and build graphcut library
    %BK_BuildLib; disp('BuildLib PASSED');
    %BK_LoadLib;  disp('LoadLib PASSED');
    
    %///////////SLIC///////////////////////////////////////////////////%
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
    %////////////////SLICO/////////////////////////////////////////////%
%         fid=fopen(superpixelPath,'rt');
%         A = fread(fid,'*uint32');
%         fclose(fid);
%         segments = reshape(A, h, w)';
%         numSegments = max(A) + 1;
    %//////////////////////////////////////////////////////////////////%

    %////////////////runERS////////////////////////////////////////////%
%     grey_img = double(rgb2gray(oriImg));
%     nC = floor(w*h/200);
%     t = cputime;
%     [segments] = mex_ers(grey_img,nC);
%     numSegments = max(max(segments)) + 1;
%     fprintf(1,'Use %f sec. \n',cputime-t);
%     fprintf(1,'\t to divide the image into %d superpixels.\n',nC);
    %//////////////////////////////////////////////////////////////////%
    
    %////////////////loadERS///////////////////////////////////////////%
    segments = load(ERSPath, '-ascii');
    numSegments = max(max(segments)) + 1;
    %//////////////////////////////////////////////////////////////////%
    
    %compute mean color of each segment

    if(strcmp(version, 'ver4')==1)
        img = rgb2lab(img);
        Layer1 = img(:,:,1);
        Layer2 = img(:,:,2);
        Layer3 = img(:,:,3);
        %img(:,:,1) = img(:,:,1).*2.55;
        meanColor = zeros(3, numSegments);
        meanCoord = zeros(2, numSegments);
        %test = zeros(w, h);
        for i = 1:numSegments
            [x,y] = find(segments==i-1);
            sz = size(x, 1);

            meanColor(1, i) = sum( sum(Layer1(segments==i-1)) )/sz;
            meanColor(2, i) = sum( sum(Layer2(segments==i-1)) )/sz;
            meanColor(3, i) = sum( sum(Layer3(segments==i-1)) )/sz;
            %meanColor(4, i) = sum( sum(oriImg(x,y,1)) )/sz;
            %meanColor(5, i) = sum( sum(oriImg(x,y,2)) )/sz;
            %meanColor(6, i) = sum( sum(oriImg(x,y,3)) )/sz;
            meanCoord(1, i) = sum(x)/sz;
            meanCoord(2, i) = sum(y)/sz;
            %test(segments==i-1) = meanColor(1, i);
        end
    elseif(strcmp(version, 'ver5')==1)
        gray_img = rgb2gray(oriImg);
        Layer1 = img(:,:,1);
        Layer2 = img(:,:,2);
        Layer3 = img(:,:,3);
        meanColor = zeros(4, numSegments);
        for i = 1:numSegments
            [x,y] = find(segments==i-1);
            sz = size(x, 1);
            meanColor(1, i) = sum( sum(Layer1(segments==i-1)) )/sz;
            meanColor(2, i) = sum( sum(Layer2(segments==i-1)) )/sz;
            meanColor(3, i) = sum( sum(Layer3(segments==i-1)) )/sz;
            meanColor(4, i) = sum( sum(gray_img(segments==i-1)) )/sz;
        end    
    else
        Layer1 = img(:,:,1);
        Layer2 = img(:,:,2);
        Layer3 = img(:,:,3);
        meanColor = zeros(3, numSegments);
        meanCoord = zeros(2, numSegments);
        for i = 1:numSegments
            [x,y] = find(segments==i-1);
            sz = size(x, 1);
            meanColor(1, i) = sum( sum(Layer1(segments==i-1)) )/sz;
            meanColor(2, i) = sum( sum(Layer2(segments==i-1)) )/sz;
            meanColor(3, i) = sum( sum(Layer3(segments==i-1)) )/sz;
            meanCoord(1, i) = sum(x)/sz;
            meanCoord(2, i) = sum(y)/sz;

        end
    end
    %//////////////////////////////////////////////////////////////////////
    % read mask, initilize forground and background segment
    %//////////////////////////////////////////////////////////////////////
    fSeg = zeros(1, numSegments);
    bSeg = zeros(1, numSegments);
    closebSeg = zeros(1, numSegments);
    % for Grabcut database : 
    % foreground: 255, background: 64, uncertain: 128
    [f1, f2] = find(imgMask(:,:)==255);
    [b1, b2] = find(imgMask(:,:)==64);
    [b3, b4] = find(imgMask(:,:)==0);
%     [f1, f2] = find(imgMask(:,:,1) - imgMask(:,:,2) > 200);
%     [b1, b2] = find(imgMask(:,:,3) - imgMask(:,:,2) > 200);
    for i = 1:size(f1, 1)
        fSeg(segments(f1(i), f2(i))+1) = 1;
    end
    for i = 1:size(b1, 1)
        closebSeg(segments(b1(i), b2(i))+1) = 1;
        bSeg(segments(b1(i), b2(i))+1) = 1;
    end
    for i = 1:size(b3, 1)
        bSeg(segments(b3(i), b4(i))+1) = 1;
    end
    uncertain = find((fSeg - bSeg)==0);
    
    %distinguish neighbors
    neighboring = FindNeighbor();
    colorDis = pdist2(meanColor', meanColor').*neighboring;

    if(strcmp(version, 'ver0')==1 || strcmp(version, 'ver4')==1)
        tarName = [name,'_', version, '_',int2str(params(1))];
        
        %calculate dF, dB
        [dF dB] = updateMinDis(version, uncertain);

        %compute E1 E2
        E1 = updateE1(version, infinite, dF, dB);
        E2 = updateE2(version, neighboring, params) ;
        
    elseif(strcmp(version, 'ver1')==1)
        tarName = [name,'_', version, '_',int2str(params(1)), '_', int2str(params(2)), '_', int2str(params(3))];
        
        texture = extractTexture(rgb2gray(oriImg));
        computeMeanTexture(texture);
        
        %calculate dF, dB
        [dF dB dTF dTB] = updateMinDis(version, uncertain);

        %compute E1 E2
        E1 = updateE1(version, infinite, dF, dB, dTF, dTB);
        E2 = updateE2(version, neighboring, params) ;
        
     elseif(strcmp(version, 'ver2'))
        tarName = [name,'_', version, '_',int2str(params(1)), '_', int2str(params(2)), '_', int2str(params(3))];
        
        %calculate dF, dB
        [dF dB] = updateMinDis(version, uncertain);

        %compute E1 E2
        E1 = updateE1(version, infinite, dF, dB);
        E2 = updateE2(version, neighboring, params) ;
    elseif(strcmp(version, 'ver3'))
        tarName = [name,'_', version, '_',int2str(params(1))];
        
        texture = extractTexture(rgb2gray(oriImg));
        computeMeanTexture(texture);
        
        %calculate dF, dB
        [dF dB dTF dTB] = updateMinDis(version, uncertain);
        
        %compute E1 E2
        E1 = updateE1(version, infinite, dF, dB, dTF, dTB);
        E2 = updateE2(version, neighboring, params) ;
    elseif(strcmp(version, 'ver5'))
        tarName = [name,'_', version, '_',int2str(params(1))];
        
        texture = extractTexture(oriImg, 'gabor');
        computeMeanTexture(texture);
        texDis = pdist2(meanTexture', meanTexture').*neighboring;
        lumDis = pdist2(meanColor(4,:)', meanColor(4,:)').*neighboring;
        
        %calculate dF, dB
        [dF dB dTF dTB] = updateMinDisGC(version, uncertain);
        
        %compute E1 E2
        E1 = updateE1(version, infinite, dF, dB, dTF, dTB);
        E2 = updateE2(version, neighboring, params);
        %mydisplay(segments, numSegments, E1(1,:)-fSeg*infinite);
        %mydisplay(segments, numSegments, E1(2,:)-bSeg*infinite);        

    end
    %graph cut
    hinc = BK_Create(numSegments,2*numSegments);
    BK_SetUnary(hinc, E1); 
    BK_SetNeighbors(hinc, E2);
    e_inc = BK_Minimize(hinc);
    lab = BK_GetLabeling(hinc);
    BK_Delete(hinc);
    
    %display and save file
    [newImg map] = drawResults(lab);
    path1 = [dir, name, '/'];
    if (exist(path1, 'dir') == 0), mkdir(path1); end
	imwrite(newImg, [path1, tarName, '.jpg']);
    imwrite(map*255, [path1, 'map_', tarName, '.bmp']);
    path2 = [dir, version, '/'];
    if (exist(path2, 'dir') == 0), mkdir(path2); end
    imwrite(newImg, [path2, tarName, '.jpg']);
    imwrite(map*255, [path2, 'map_', tarName, '.bmp']);
    
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
  