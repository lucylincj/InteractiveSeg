function drawResults(img, segments, result)
    map = zeros(size(segments, 1), size(segments, 2));
    for i = 1:size(result, 1)
        map(segments==i-1) = result(i) -1;
    end

    figure; imagesc(map);
    img(:, :, 1)  = img(:, :, 1) .* uint8(map);
    img(:, :, 2)  = img(:, :, 2) .* uint8(map);
    img(:, :, 3)  = img(:, :, 3) .* uint8(map);

    figure; imshow(img);
end