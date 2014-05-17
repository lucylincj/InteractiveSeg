%for testing new features
function [idx, mask] = testBranch(oriImg, segments, num, info)
    disp(num);
    %process ambiguous region
    %for flowers.png: 348 381
    [x1, y1] = find(segments ==num);
    top = min(x1);
    bottom = max(x1);
    left = min(y1);
    right = max(y1);
    idx = [top, bottom, left, right];
    
    cropImg = oriImg(top:bottom, left:right,:);
    figure; imshow(cropImg);
    cform = makecform('srgb2lab');
    labImg = applycform(cropImg,cform);
    
    ab = double(labImg(:,:,2:3));
    %ab(:,:,1) = ab(:,:,1).*mask;
    %ab(:,:,2) = ab(:,:,2).*mask;
    nrows = size(ab,1);
    ncols = size(ab,2);
    ab = reshape(ab,nrows*ncols,2)';

%     cform = makecform('srgb2lab');
%     labImg = applycform(oriImg,cform);
%     layer1 = labImg(:,:,2);
%     layer2 = labImg(:,:,3);
%     ab = zeros(2, size(x1,1));
%     ab(1, :) = double(layer1(segments==347));
%     ab(2, :) = double(layer2(segments==347));

    nColors = 2;
    % repeat the clustering 3 times to avoid local minima
    %[cluster_idx, cluster_center] = kmeans(ab,nColors,'distance','sqEuclidean', ...
    %                                      'Replicates',3);
%     addpath(genpath('vlfeat-0.9.18')) ;
%     vl_setup();
    
    [idx_, C_, e] = vl_kmeans(ab, nColors,'distance', 'l1') ;
    mask = reshape(C_, nrows, ncols);
    %result = double(result) .* double(mask);
    figure; imagesc(mask);
    mask = mask - 1;
    
    %identify fg bg region
    mask_x = info(3) - top + 1;
    mask_y = info(4) - left + 1;
    if( xor(mask(mask_x, mask_y), info(2)) ==1 ) %flip fg/ bg
        tmp = ones(size(mask, 1), size(mask, 2));
        mask = xor(mask, tmp);
    end
        
     
    
    %I=rgb2gray(cropImg);
    %L = watershed(I);
    %figure; imagesc(L);
    
    
end