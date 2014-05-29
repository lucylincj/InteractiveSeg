function err = computeErr(result, trimap, groundTruth)
    result = result/255;
    groundTruth = groundTruth/255;
    [x, y] = find(trimap==128);
    err = sum(sum(abs(double(result) - double(groundTruth)))) / size(x, 1) * 100;
end