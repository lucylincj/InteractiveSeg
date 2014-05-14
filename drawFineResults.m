function drawFineResults(img, segments, result, testIdx, testM, num)
    map = zeros(size(segments, 1), size(segments, 2));

    tmp = ones(size(testM, 1), size(testM, 2));
    map(testIdx(1):testIdx(2), testIdx(3):testIdx(4)) = xor(testM, tmp);

    for i = 1:size(result, 1)
        if(i ~= num+1)
            map(segments==i-1) = result(i) -1;
        end
    end
    
    %figure; imagesc(map);
    img(:, :, 1)  = img(:, :, 1) .* uint8(map);
    img(:, :, 2)  = img(:, :, 2) .* uint8(map);
    img(:, :, 3)  = img(:, :, 3) .* uint8(map);

    figure; imshow(img);

end