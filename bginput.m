%--------------------------------------------------------------------------
function  bginput(strg)
% BGINPUT  - This function gets the background pixels from user input
% BGINPUT(STRG) - strg  - Smart Refine or Smart Rectangle
% Authors - Mohit Gupta, Krishnan Ramnath
% Affiliation - Robotics Institute, CMU, Pittsburgh
% 2006-05-15

% Global variables referenced in this funciton
global fgflag fgbc bgbc fgpixels bgpixels spflag;



if(strcmp(strg,'SmartRectangle'))

    % Gui related flag
    fgflag = 2;
    spflag = 1;

else
    % Gui related flag
    fgflag = 0;
    spflag = 2;

end
    hfig = gcf;
    hold on;
    % Call track function on button press
    set(hfig,'windowbuttondownfcn',{@track});
end
