% texture feature : Law's
% return 32 dim feature
function feature = extractTexture(image)
    feature = lawTexture( image );
end


function feature = lawTexture(image)

if(size(image, 3)~=1)    
    lab = rgb2lab(image);
    img = lab(:, :, 1) ./ 100;
else
    img = image ./ 255;
%     if strcmp(class(img),'uint8')
%         img = double(img)/255;
%     end
end
   
    L = [ 1  4  6  4  1; 
         -1 -2  0  2  1;
         -1  0  2  0 -1;
          1 -4  6 -4  1 ];

    feature = zeros(16, size(image, 1), size(image, 2));
    
    for i = 1:4
        for j = 1:4
            idx = (i-1)*4 + j;
            filter = L(i, :)' * L(j, :);
            filter = filter ./ max(max(filter));
            tImg = conv2(img, filter, 'same'); % size = size(img)
%             mu  = mean( mean( tImg ) );
%             var = sum( sum( (tImg - mu).^2 ) ) / ( size(img, 1) * size(img, 2) ); 
%             feature(2*idx - 1) = mu;
%             feature(2*idx) = sqrt(var); 
            feature(idx, :, :) = tImg;
        end
    end
    
end