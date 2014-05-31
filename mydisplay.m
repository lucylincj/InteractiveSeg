function mydisplay(segments, numSegments, value)
    result = segments;
    for j = 1:numSegments
        result(segments==j-1) = value(j);
    end
    figure;
    imagesc(result);
    colormap(gray);
end