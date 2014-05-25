function LoadImgUI

% Global Variables
% Req by radio button RadioButtonFn
global hfig longfilename segments numSegments oriImg meanColor meanCoord bSeg fSeg neighboring colorDis;
%global radientPatch scaleMap;

% Get handle to current figure;
hfig = gcf;


% Call built-in file dialog to select image file
[filename,pathname] = uigetfile('D:/InteractiveSegTestImage/*.*','Select image file');
if ~ischar(filename); return; end

%//////////////////////Radio Buttons////////////////////////%
h = uibuttongroup('visible','off','Position',[0.7 0.7 0.18 0.18]);
u0 = uicontrol('Style','Radio','String','SNAP',...
    'pos',[10 60 80 30],'parent',h,'HandleVisibility','off');
u1 = uicontrol('Style','Radio','String','EDIT',...
    'pos',[10 20 80 30],'parent',h,'HandleVisibility','off');

set(h,'SelectionChangeFcn',@RadioButtonFn);
set(h,'SelectedObject',[]);
set(h,'Visible','on');

%////////////////Draw Image////////////////////////////%
% Load  Image file
longfilename = strcat(pathname,filename);
oriImg = imread(longfilename);

% Get the position of the image
data.ui.ah_img = axes('Position',[0.01 0.2 .603 .604]);
data.ui.ih_img = image;

% Set the image
set(data.ui.ih_img, 'Cdata', oriImg);
axis('image');axis('ij');axis('off');
drawnow;

%pre-segment
%if(strcmp(strg,'SLIC'))
%     addpath(genpath('vlfeat-0.9.18')) ;
%     regionSize = 20 ;
%     regularizer = 5 ; 
%     img = im2single(Im) ;
%     segments = vl_slic(img, regionSize, regularizer, 'verbose') ;
%     numSegments = segments(end,end) + 1;
%elseif(strcmp(strg,'SLICO'))
    fid=fopen([pathname,'SLICO/300/', filename(1:end-4),'.dat'],'rt');
    A = fread(fid,'*uint32');
    fclose(fid);
    [w, h, dummy] = size(oriImg) ;
    segments = reshape(A, h, w)';
    numSegments = max(A) + 1;
    disp('superpixel done');
    
    %calculate mean color, mean coordinate of every segment
    meanColor = zeros(3, numSegments);
    meanCoord = zeros(2, numSegments);
    for i = 1:numSegments
        [x,y] = find(segments==i-1);
        meanColor(1, i) = sum( sum(oriImg(x,y,1)) )/size(x,1);
        meanColor(2, i) = sum( sum(oriImg(x,y,2)) )/size(x,1);
        meanColor(3, i) = sum( sum(oriImg(x,y,3)) )/size(x,1);
        meanCoord(1, i) = sum(x)/size(x,1);
        meanCoord(2, i) = sum(y)/size(y,1);
    end
    
    %generate radient patch
%     r = floor(min(w,h)/4);
%     tmp = fliplr(1:r)'*(1:r)/r/r;
%     radientPatch = [fliplr(tmp), tmp ; tmp', flipud(tmp)];
%     scaleMap = ones(size(segments));
    
    
    %initialize fSeg and bSeg
    fSeg = zeros(1, numSegments);
    bSeg = zeros(1, numSegments);
    
    %find neighbors
    neighboring = FindNeighbor();
    colorDis = pdist2(meanColor', meanColor').*neighboring;
   
    addpath('Bk') ;
    addpath('Bk/bin') ;
%end