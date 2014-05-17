function map = drawResults(img, segments, result)
    map = zeros(size(segments, 1), size(segments, 2));
    x = find(result==2); % result = 2 -> foreground
    for i = 1:size(x)
        map(segments==x(i)-1) = 1;
    end

    %figure; imagesc(map);
    map = uint8(repmat(map,[1,1,3]));
    img  = img .* uint8(map);
    figure; imshow(img);
end