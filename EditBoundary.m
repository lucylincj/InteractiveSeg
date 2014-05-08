function EditBoundary(oriImg, segments, lab, editfgpixels, editbgpixels)
    
    FY = editfgpixels(:,1);
    FX = editfgpixels(:,2);

    BY = editbgpixels(:,1);
    BX = editbgpixels(:,2);
    for i = 1:size(FX, 1)
        lab(segments(FX(i), FY(i))+1) = 1;
    end
    for i = 1:size(BX, 1)
        lab(segments(BX(i), BY(i))+1) = 0;
    end
    drawResults(oriImg, segments, lab);
    
end