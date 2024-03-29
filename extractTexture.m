% -------------------------------------------------------------------- %
%  Adapted from fv_texture.m by R01942068@NTU 2012.11.06
%  @author : R01942054@NTU
%  @date  : 201405
%
%  @Input :
%           image  - RGB color space input image
%           metric - only support 'gabor' or 'Law' 
%
%  @Output :
%           feature - texture filter response 
% -------------------------------------------------------------------- %

function feature = extractTexture(image, metric)

    if( strcmp(metric, 'gabor') )   % Gabor texture
        
        feature = gaborFeature(image);
    
    elseif( strcmp(metric, 'Law') ) % Law's texture   
    
        feature = LawTexture(image);
        
    else
        disp(['Error! Not support metric: ' metric ' !']);
        return;
    end

end     %end of fv_texture

% convert from RGB to CIE-Lab
function Lab = rgb2lab(im)
 
    cform = makecform('srgb2lab');
    if strcmp(class(im),'uint8')
        im = double(im)/255;
    end
    
    Lab = applycform(im, cform);
    Lab(:, :, 1) = Lab(:, :, 1) ./ 100.0;           % L: [0, 100]    -> [0, 1]
    Lab(:, :, 2) = (Lab(:, :, 2) + 128.0) ./ 255.0; % a: [-128, 127] -> [0, 1]
    Lab(:, :, 3) = (Lab(:, :, 3) + 128.0) ./ 255.0; % b: [-128, 127] -> [0, 1]
    
end

% extract feature vector from Gabor texture
function gImg = gaborFeature(image)

    H = size(image, 1);
    W = size(image, 2);
    
    lab = rgb2lab(image);
    fImg = fft2( lab(:, :, 1) ); 
    
    nScale  = 1;
    nOrient = 4;
    filters = gaborconvolve(H, W, nScale, nOrient, 3, 2, 0.65);    

    gImg = zeros(H, W, nScale * nOrient);
    %feature = zeros(nScale * nOrient * 2, 1);
    %figure;

    for s = 1:nScale
        for o = 1:nOrient
            k = (s-1)*nOrient+o;
            tImg = abs( ifft2( fImg .* filters(:, :, k) ) );
            gImg(:, :, k) = tImg ./ max(max(tImg)); 
            subplot(nScale, nOrient, k); imagesc(gImg(:,:,k));
            %feature(2*k-1) = mean(mean(tImg));
            %feature(2*k)   = imgVariance(tImg, feature(2*k-1));
        end
    end

end     %end of GaborFeature

function var = imgVariance(img, mu)
    dif = img-mu;
    s = sum(sum(dif .* dif));
    var = s / (size(img, 1)*size(img, 2));
end


function filters = gaborconvolve(H, W, nscale, norient, minWaveLength, ...
			                      mult, sigmaOnf, Lnorm, feedback)
    
    %if ndims(im) == 3
    %    disp('Colour image supplied: Converting to greyscale');
    %    im = rgb2gray(im);
    %end
    
    if ~exist('Lnorm','var'), Lnorm = 0;  end
    if ~exist('feedback','var'), feedback = 0;  end    
    %if ~isa(im,'double'),  im = double(im);  end
    
    %[rows cols] = size(im);					
    %imagefft = fft2(im);                 % Fourier transform of image
    %EO = cell(nscale, norient);          % Pre-allocate cell array
    %BP = cell(nscale,1);
    
    % Pre-compute some stuff to speed up filter construction
    % Set up X and Y matrices with ranges normalised to +/- 0.5
    % The following code adjusts things appropriately for odd and even values
    % of rows and columns.
    cols = W;
    rows = H;
    if mod(cols,2)
        xrange = ( -(cols-1)/2 : (cols-1)/2 ) / (cols-1);
    else
        xrange = ( -cols/2 : (cols/2-1) ) / cols; 
    end
    
    if mod(rows,2)
        yrange = ( -(rows-1)/2 : (rows-1)/2 ) / (rows-1);
    else
        yrange = ( -rows/2 : (rows/2-1) ) / rows; 
    end
    
    [x,y] = meshgrid(xrange, yrange);
    
    radius = sqrt(x.^2 + y.^2);       % Matrix values contain *normalised* radius from centre.
    theta = atan2(y,x);               % Matrix values contain polar angle.
                                  
    radius = ifftshift(radius);       % Quadrant shift radius and theta so that filters
    theta  = ifftshift(theta);        % are constructed with 0 frequency at the corners.
    radius(1,1) = 1;                  % Get rid of the 0 radius value at the 0
                                      % frequency point (now at top-left corner)
                                      % so that taking the log of the radius will 
                                      % not cause trouble.
    sintheta = sin(theta);
    costheta = cos(theta);
    clear x; clear y; clear theta;    % save a little memory
    
    % Filters are constructed in terms of two components.
    % 1) The radial component, which controls the frequency band that the filter
    %    responds to
    % 2) The angular component, which controls the orientation that the filter
    %    responds to.
    % The two components are multiplied together to construct the overall filter.
    
    % Construct the radial filter components...
    % First construct a low-pass filter that is as large as possible, yet falls
    % away to zero at the boundaries.  All log Gabor filters are multiplied by
    % this to ensure no extra frequencies at the 'corners' of the FFT are
    % incorporated. This keeps the overall norm of each filter not too dissimilar.
    
    %lp = lowpassfilter([rows,cols],.45,15);   % Radius .45, 'sharpness' 15
    lp = fspecial('gaussian', 40, 1.0);
    lp = lp ./max(max(lp));
    
    logGabor = cell(1,nscale);
    
    filters = zeros(H, W, norient*nscale);
    
    for s = 1:nscale
        wavelength = minWaveLength*mult^(s-1);
        fo = 1.0/wavelength;                  % Centre frequency of filter.
        logGabor{s} = exp((-(log(radius/fo)).^2) / (2 * log(sigmaOnf)^2));  
        %logGabor{s} = logGabor{s}.*lp;        % Apply low-pass filter
        conv2(logGabor{s}, lp);
        logGabor{s}(1,1) = 0;                 % Set the value at the 0 frequency point of the filter
                                              % back to zero (undo the radius fudge).
        % Compute bandpass image for each scale 
        if Lnorm == 2       % Normalize filters to have same L2 norm
            L = sqrt(sum(logGabor{s}(:).^2));
        elseif Lnorm == 1   % Normalize to have same L1
            L = sum(sum(abs(real(ifft2(logGabor{s})))));
        elseif Lnorm == 0   % No normalization
            L = 1;
        else
            error('Lnorm must be 0, 1 or 2');
        end
        
        logGabor{s} = logGabor{s}./L;        
        %BP{s} = ifft2(imagefft .* logGabor{s});   
    end
    
    % The main loop...
    for o = 1:norient,                   % For each orientation.
        if feedback
            fprintf('Processing orientation %d \r', o);
        end
    
        angl = (o-1)*pi/norient;           % Calculate filter angle.
        wavelength = minWaveLength;        % Initialize filter wavelength.

        % Pre-compute filter data specific to this orientation
        % For each point in the filter matrix calculate the angular distance from the
        % specified filter orientation.  To overcome the angular wrap-around problem
        % sine difference and cosine difference values are first computed and then
        % the atan2 function is used to determine angular distance.
        ds = sintheta * cos(angl) - costheta * sin(angl);     % Difference in sine.
        dc = costheta * cos(angl) + sintheta * sin(angl);     % Difference in cosine.
        dtheta = abs(atan2(ds,dc));                           % Absolute angular distance.

        % Scale dtheta so that cosine spread function has the right wavelength and clamp to pi    
        dtheta = min(dtheta*norient/2,pi);
        
        % The spread function is cos(dtheta) between -pi and pi.  We add 1,
        % and then divide by 2 so that the value ranges 0-1
        spread = (cos(dtheta)+1)/2;        


% Old angular spread function        
%        dThetaOnSigma = 1.2;
%        thetaSigma = pi/norient/dThetaOnSigma;  % Calculate the standard deviation of the
%                                                % angular Gaussian function used to
%                                                % construct filters in the freq. plane.
%
%        spread = exp((-dtheta.^2) / (2 * thetaSigma^2));  % Calculate the
%                                                          % angular filter component.        
    
        
        for s = 1:nscale,                    % For each scale.
            filter = logGabor{s} .* spread;  % Multiply by the angular spread to get the filter

            if Lnorm == 2      % Normalize filters to have the same L2 norm ** why sqrt 2 **????
                L = sqrt(sum(real(filter(:)).^2 + imag(filter(:)).^2 ))/sqrt(2);
            elseif Lnorm == 1  % Normalize to have same L1
                L = sum(sum(abs(real(ifft2(filter)))));
            elseif Lnorm == 0   % No normalization
                L = 1;                
            end
            filter = filter./L;  
            
            k = (s-1)*norient + o;
            filters(:, :, k) = filter;
            % Do the convolution, back transform, and save the result in EO
            %EO{s,o} = ifft2(imagefft .* filter);
            wavelength = wavelength * mult;       % Finally calculate Wavelength of next filter
        end                                       % ... and process the next scale

    end  % For each orientation
    
    if feedback, fprintf('                                        \r'); end
end

% extract feature vector from the law's texture
function feature = LawTexture(image)

    lab = rgb2lab(image);
    gImg = lab(:, :, 1);
   
    L = [ 1  4  6  4  1; 
         -1 -2  0  2  1;
         -1  0  2  0 -1;
          1 -4  6 -4  1 ];
      
    N = size(image, 1) * size(image, 2);
    feature = zeros(16*2, 1);
    
    for i = 1:4
        for j = 1:4
            k = (i-1)*4 + j;
            filter = L(i, :)' * L(j, :);
            filter = filter ./ max(max(filter));
            tImg = conv2(gImg, filter, 'same');
            mu  = mean( mean( tImg ) );
            var = sum( sum( (tImg - mu).^2 ) ) / N; 
            feature(2*k - 1) = mu;
            feature(2*k)     = sqrt(var); 
        end
    end
    
end
