function  fginput(strg)
% FGINPUT  - This function gets the foreground pixels from user inputn
% FGINPUT(STRG) - strg  - Smart Refine or Smart Rectangle
% Authors - Mohit Gupta, Krishnan Ramnath
% Affiliation - Robotics Institute, CMU, Pittsburgh
% 2006-05-15


    % Global variables referenced in this funciton
    global sopt fgflag fgpixels bgpixels spflag mflag;
    fgflag = 1;
    % If using the SmartRectangle Function
    if(strcmp(strg,'SLIC'))
        spflag = 1;
        mflag = 0;

    elseif(strcmp(strg,'SLICO'))
        spflag = 2;
        mflag = 0;
    elseif(strcmp(strg,'Edit'))
        mflag = 1;

    end
    hfig = gcf;
    hold on;
    % Call track function on button press
    set(hfig,'windowbuttondownfcn',{@track});
end