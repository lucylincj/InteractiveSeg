function map = drawResults(result)
    global oriImg segments;
    map = zeros(size(segments, 1), size(segments, 2));
    tic
    x = find(result==2); % result = 2 -> foreground
    for i = 1:size(x)
        map(segments==x(i)-1) = 1;
    end
    toc
    %figure; imagesc(map);
    tic
    map = uint8(repmat(map,[1,1,3]));
    img  = oriImg .* uint8(map);
    toc
    figure; imshow(img);
end