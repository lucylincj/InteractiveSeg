function img = drawResults(result)
    global oriImg segments;
%     map = zeros(size(segments, 1), size(segments, 2));
%     x = find(result==2); % result = 2 -> foreground
%     for i = 1:size(x)
%         map(segments==x(i)-1) = 1;
%     end
    tic
    map = result(segments+1);
    map = map-1;
    map = repmat(map,[1,1,3]);
    img  = oriImg .* uint8(map);
    toc
    %figure; imshow(img);
end