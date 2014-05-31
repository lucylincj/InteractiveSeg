function computeMeanTexture(texture)
    global meanTexture numSegments segments
    h = size(texture, 3);
    meanTexture = zeros(h, numSegments);
    for k = 1:h
        layer = texture(:,:,k);
        for i = 1:numSegments
            [x,y] = find(segments==i-1);
            sz = size(x, 1);
            meanTexture(k, i) = sum(layer(segments==i-1))/sz;
        end
    end
end