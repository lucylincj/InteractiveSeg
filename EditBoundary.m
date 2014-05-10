function EditBoundary(oriImg, segments, lab, editfgpixels, editbgpixels)
    sizef = size(editfgpixels, 1);
    sizeb = size(editbgpixels, 1);
    %coarsely edit
%     if(sizef>0)
%         FY = editfgpixels(:,1);
%         FX = editfgpixels(:,2);
%         for i = 1:sizef
%             lab(segments(FX(i), FY(i))+1) = 2;
%         end
%     end
%     
%     if(sizeb>0)
%         BY = editbgpixels(:,1);
%         BX = editbgpixels(:,2);
%         for i = 1:sizeb
%             lab(segments(BX(i), BY(i))+1) = 1;
%         end 
%     end
    
    %//////////////////////////finer edit/////////////////////////////////%
    %if the same region is labeled twice by fg and bg respectively,
    %further segment the region into 2 sub-regions.
    %
    
    record = zeros(size(lab, 1), size(lab, 2));
    if(sizef>0)
        FY = editfgpixels(:,1);
        FX = editfgpixels(:,2);
        for i = 1:sizef
            lab(segments(FX(i), FY(i))+1) = 2;
        end
    end
    
    if(sizeb>0)
        BY = editbgpixels(:,1);
        BX = editbgpixels(:,2);
        for i = 1:sizeb
            lab(segments(BX(i), BY(i))+1) = 1;
        end 
    end

    
    
    drawResults(oriImg, segments, lab);
    
end