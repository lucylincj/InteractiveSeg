function RadioButtonFn(source, eventdata)
% RADIOBUTTONFUNCTION - This function is called whenever there is change in
% choice of radio button

% Global Variables
global hfig;

% Pass string value to seed selection function
strg = get(eventdata.NewValue,'String');

%%%%%%%%%%%%%%%%Seed Selection Buttons%%%%%%%%%%%%%%%%%%%
% Calls fginput - gets foreground pixels from the user
data.ui.push_fg = uicontrol(hfig, 'Style','pushbutton', 'Units', 'Normalized','Position',[.7 .6 .1 .05], ...
    'String','Foreground','Callback', ['fginput ',strg]);

% Calls bginput - gets background pixels from the user
data.ui.push_bg = uicontrol(hfig, 'Style','pushbutton', 'Units', 'Normalized','Position',[.7 .5 .1 .05], ...
    'String','Background','Callback', ['bginput ',strg]);

% Calls Segment - graph-cuts on the image
data.ui.push_bg = uicontrol(hfig, 'Style','pushbutton', 'Units', 'Normalized','Position',[.7 .4 .1 .05], ...
    'String','Graph Cuts','Callback', 'Segment ');
drawnow;

end