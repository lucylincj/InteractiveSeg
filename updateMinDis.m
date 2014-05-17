function [dF dB] = updateMinDis(uncertain)
    global numSegments meanColor fSeg bSeg;
    dF = zeros(1, numSegments);
    dB = zeros(1, numSegments);
    for i = 1:size(uncertain, 2)
        j = uncertain(i);
        seg = repmat(meanColor(:,j ), 1, numSegments);
        dis = sum( (meanColor - seg).^2, 1 );
        dF(j) = sqrt(min(dis(fSeg==1)));
        dB(j) = sqrt(min(dis(bSeg==1)));
    end
end