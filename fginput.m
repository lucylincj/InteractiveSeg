function  fginput(strg)
% FGINPUT  - This function gets the foreground pixels from user inputn
% FGINPUT(STRG) - strg  - Smart Refine or Smart Rectangle
% Authors - Mohit Gupta, Krishnan Ramnath
% Affiliation - Robotics Institute, CMU, Pittsburgh
% 2006-05-15


    % Global variables referenced in this funciton
    global sopt fgflag fgpixels bgpixels spflag;

    % If using the SmartRectangle Function
    if(strcmp(strg,'SLIC'))
        % GUI related flag
        fgflag = 2;
        spflag = 1;

    elseif(strcmp(strg,'SLICO'))
        % Gui related flag
        fgflag = 1;
        spflag = 2;

    end
    hfig = gcf;
    hold on;
    % Call track function on button press
    set(hfig,'windowbuttondownfcn',{@track});
end