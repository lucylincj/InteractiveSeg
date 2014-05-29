function [p r] = computePR(img, groundTruth)
    img = img/255;
    groundTruth = groundTruth/255;
    acc = sum(sum(img .* groundTruth));
    r = acc / sum(sum(groundTruth)) ;
    p = acc / sum(sum(img));
end