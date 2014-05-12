%for testing new features
function testBranch()
     %load image
    imgPath = 'images/flowers.png';
    oriImg = imread(imgPath);
    img = im2single(oriImg) ;
    w = size(img, 1);
    h = size(img, 2);
    
    %load SLICO result
    fid=fopen('SLICO_dat/flowers.dat','rt');
    A = fread(fid,'*uint32');
    fclose(fid);
    segments = reshape(A, h, w)';
    numSegments = max(A) + 1;
    
    %process ambiguous region
    %for flowers.png: 348 381
    [x1, y1] = find(segments ==347);
    top = min(x1);
    bottom = max(x1);
    left = min(y1);
    right = max(y1);
    
    cropImg = oriImg(top:bottom, left:right,:);
    tmp = (segments ==347);
    mask = tmp(top:bottom, left:right);
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
    addpath(genpath('vlfeat-0.9.18')) ;
    vl_setup();
    
    [idx_, C_, e] = vl_kmeans(ab, nColors, 'verbose') ;
    result = reshape(C_, nrows, ncols)';
    %result = double(result) .* double(mask);
    figure; imagesc(result);
    
     
    
    
    
end