function MainUI

% Main Menu 
hfig = figure('units','pixels','position', [50 100 1100 600],...
   'tag','GUI', 'name','Graph-Cuts Segmentation',...
   'menubar','none','numbertitle','off');


% File menu for figure, with callbacks:
% Open...    (callback to displayImage)
% Exit       (closes figure window)

hmenu = uimenu('Label','File');

% DisplayImage function - loads the image file
uimenu(hmenu,'label','Open...','callback','LoadImgUI')

% Exit 
uimenu(hmenu,'label','Exit','callback','closereq','separator','on');