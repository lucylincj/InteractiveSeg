function  bginput(strg)
% BGINPUT  - This function gets the background pixels from user input
% BGINPUT(STRG) - strg  - Smart Refine or Smart Rectangle
% Authors - Mohit Gupta, Krishnan Ramnath
% Affiliation - Robotics Institute, CMU, Pittsburgh
% 2006-05-15

    % Global variables referenced in this funciton
    global fgflag mflag;
    fgflag = 0;
    if(strcmp(strg,'SNAP'))
        mflag = 0;
    elseif(strcmp(strg,'EDIT'))
        mflag = 1;

    end
    hfig = gcf;
    hold on;
    % Call track function on button press
    set(hfig,'windowbuttondownfcn',{@track});
end
