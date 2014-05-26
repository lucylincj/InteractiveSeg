function runERS(name, nC)
    %Path and parameters
    disp('Entropy Rate Superpixel Segmentation');
    path = 'D:/InteractiveSegTestImage/';
    %nC = 200;
    imgPath = strcat(path, name, '.jpg');
    img = imread(imgPath);

    %// We convert the input image into a grey scale image for superpixel
    %// segmentation.
    grey_img = double(rgb2gray(img));

    %%
    %/////////////////////////segmentation////////////////////////////////
    t = cputime;
    nC = size(grey_img, 1) * size(grey_img, 2) / nC;
    [labels] = mex_ers(grey_img,nC);
    fprintf(1,'Use %f sec. \n',cputime-t);
    fprintf(1,'\t to divide the image into %d superpixels.\n',nC);

    %// You can also specify your preference parameters. The parameter values
    %// (lambda_prime = 0.5, sigma = 5.0) are chosen based on the experiment
    %// results in the Berkeley segmentation dataset.
    %// lambda_prime = 0.5; sigma = 5.0;
    %// [out] = mex_ers(grey_img,nC,lambda_prime,sigma);

    %%
    %//=======================================================================
    %// Output
    %//=======================================================================
    [height width] = size(grey_img);

    %// Compute the boundary map and superimpose it on the input image in the
    %// green channel.
    %// The seg2bmap function is directly duplicated from the Berkeley
    %// Segmentation dataset which can be accessed via
    %// http://www.eecs.berkeley.edu/Research/Projects/CS/vision/bsds/
    [bmap] = seg2bmap(labels,width,height);
    bmapOnImg = img;
    idx = find(bmap>0);
    layerR = bmapOnImg(:,:,1);
    layerG = bmapOnImg(:,:,2);
    layerB = bmapOnImg(:,:,3);
    layerR(idx) = 0;
    layerG(idx) = 255;
    layerB(idx) = 0;
    displayImg = img;
    displayImg(:,:,1) = layerR;
    displayImg(:,:,2) = layerG;
    displayImg(:,:,3) = layerB;
    imwrite(displayImg, [path, 'ERS/', name, '.png']);
    %figure; imshow(displayImg);
    %figure; imshow(grey_img,[]);

    %// Randomly color the superpixels
    %[out] = random_color( double(img) ,labels,nC);
    %figure; imshow(out, []);
% 
%     %// Compute the superpixel size histogram.
%     siz = zeros(nC,1);
%     for i=0:(nC-1)
%         siz(i+1) = sum( labels(:)==i );
%     end
%     [his bins] = hist( siz, 20 );
% 
%     %%
%     %//=======================================================================
%     %// Display 
%     %//=======================================================================
%     imshow(out,[]);
%     gcf = figure(1);
%     subplot(2,3,1);
%     imshow(grey_img,[]);
%     title('input grey scale image.');
%     subplot(2,3,2);
%     imshow(bmapOnImg,[]);
%     title('superpixel boundary map');
%     subplot(2,3,3);
%     imshow(out,[]);
%     %add
%     imwrite(uint8(out), 'result3.jpg', 'jpg');
%     title('randomly-colored superpixels');
%     subplot(2,3,5);
%     bar(bins,his,'b');
%     title('the distribution of superpixel size');
%     ylabel('# of superpixels');
%     xlabel('superpixel sizes in pixel');
%     scnsize = get(0,'ScreenSize');
%     set(gcf,'OuterPosition',scnsize);

end