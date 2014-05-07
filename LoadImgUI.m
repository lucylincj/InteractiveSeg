function LoadImgUI

% Global Variables
% Req by radio button RadioButtonFn
global hfig longfilename;

% Get handle to current figure;
hfig = gcf;


% Call built-in file dialog to select image file
[filename,pathname] = uigetfile('images/*.*','Select image file');
if ~ischar(filename); return; end

%%%%%%%%%%%%%%%%%%%Radio Buttons%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
h = uibuttongroup('visible','off','Position',[0.7 0.7 0.15 0.18]);
u0 = uicontrol('Style','Radio','String','SLIC',...
    'pos',[10 20 120 30],'parent',h,'HandleVisibility','off');
u1 = uicontrol('Style','Radio','String','SLICO',...
    'pos',[10 60 120 30],'parent',h,'HandleVisibility','off');
set(h,'SelectionChangeFcn',@RadioButtonFn);
set(h,'SelectedObject',[]);
set(h,'Visible','on');

%%%%%%%%%%%%%%%%%%%Draw Image%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Load  Image file
longfilename = strcat(pathname,filename);
Im = imread(longfilename);

% Get the position of the image
data.ui.ah_img = axes('Position',[0.01 0.2 .603 .604]);
data.ui.ih_img = image;

% Set the image
set(data.ui.ih_img, 'Cdata', Im);
axis('image');axis('ij');axis('off');
drawnow;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end