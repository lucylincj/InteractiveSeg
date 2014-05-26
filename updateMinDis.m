function [dF dB dTF dTB] = updateMinDis(uncertain)
    global numSegments meanColor fSeg bSeg meanTexture;
    dF = zeros(1, numSegments);
    dB = zeros(1, numSegments);
    for i = 1:size(uncertain, 2)
        j = uncertain(i);
        seg = repmat(meanColor(:,j ), 1, numSegments);
        dis = sum( (meanColor - seg).^2, 1 );
        dF(j) = sqrt(min(dis(fSeg==1)));
        dB(j) = sqrt(min(dis(bSeg==1)));
        seg_texture = repmat(meanTexture(:,j), 1, numSegments);
        dis_texture = sum( (meanTexture - seg_texture).^2, 1 );
        dTF(j) = sqrt(min(dis_texture(fSeg==1)));
        dTB(j) = sqrt(min(dis_texture(bSeg==1)));
%         f = meanColor(:, fSeg==1);
%         b = meanColor(:, bSeg==1);
%         [d,p] = min((A(:,1)-x).^2 + (A(:,2)-y).^2);
%         d = sqrt(d);
    end
end