function computeMeanTexture(texture)
    global meanTexture numSegments segments
    meanTexture = zeros(16, numSegments);
    for i = 1:numSegments
        [x,y] = find(segments==i-1);
        sz = size(x, 1);
        meanTexture(1, i) = sum(texture(1, segments==i-1))/sz;
        meanTexture(2, i) = sum(texture(2, segments==i-1))/sz;
        meanTexture(3, i) = sum(texture(3, segments==i-1))/sz;
        meanTexture(4, i) = sum(texture(4, segments==i-1))/sz;
        meanTexture(5, i) = sum(texture(5, segments==i-1))/sz;
        meanTexture(6, i) = sum(texture(6, segments==i-1))/sz;
        meanTexture(7, i) = sum(texture(7, segments==i-1))/sz;
        meanTexture(8, i) = sum(texture(8, segments==i-1))/sz;
        meanTexture(9, i) = sum(texture(9, segments==i-1))/sz;
        meanTexture(10, i) = sum(texture(10, segments==i-1))/sz;
        meanTexture(11, i) = sum(texture(11, segments==i-1))/sz;
        meanTexture(12, i) = sum(texture(12, segments==i-1))/sz;
        meanTexture(13, i) = sum(texture(13, segments==i-1))/sz;
        meanTexture(14, i) = sum(texture(14, segments==i-1))/sz;
        meanTexture(15, i) = sum(texture(15, segments==i-1))/sz;
        meanTexture(16, i) = sum(texture(16, segments==i-1))/sz;
    end
end