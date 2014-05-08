function dataout(imagefig,varargins)
% DATAOUT  - This function adds all the stroke points to previous ones
% Authors - Mohit Gupta, Krishnan Ramnath
% Affiliation - Robotics Institute, CMU, Pittsburgh
% 2006-05-15

% Global Variables
global sopt mflag fgflag fgpixels bgpixels editfgpixels editbgpixels;

% Ignore motion
set(gcf,'WindowButtonMotionFcn',[]);

% If Button down start tracking
set(gcf,'windowbuttondownfcn',{@track});


% Get current data
temp=get(gcf,'userdata');
coords = floor(temp(:,1:2));
coords = union(coords,coords,'rows');


if (mflag == 1)
    if(fgflag == 1)
        editfgpixels = vertcat(editfgpixels,coords);
    elseif(fgflag == 0)
        editbgpixels = vertcat(editbgpixels,coords);
    end
elseif(mflag == 0)
    if(fgflag == 1)
        fgpixels = vertcat(fgpixels,coords);
    elseif(fgflag == 0)
        bgpixels = vertcat(bgpixels,coords);
    end
end
