function [p r] = computePR(img, groundTruth)
    acc = sum(sum(img .* groundTruth));
    r = acc / sum(sum(groundTruth)) ;
    p = acc / sum(sum(img));
end