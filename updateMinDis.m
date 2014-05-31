function [dF dB dTF dTB] = updateMinDis(version, uncertain)
    global numSegments meanColor fSeg bSeg meanTexture;
    dF = zeros(1, numSegments);
    dB = zeros(1, numSegments);
    dTF = zeros(16, numSegments);
    dTB = zeros(16, numSegments);
    if(strcmp(version, 'ver0') == 1 || strcmp(version, 'ver2')==1 || strcmp(version, 'ver4')==1)
        for i = 1:size(uncertain, 2)
            j = uncertain(i);
            seg = repmat(meanColor(:,j ), 1, numSegments);
            dis = sum( (meanColor - seg).^2, 1 );
            dF(j) = sqrt(min(dis(fSeg==1)));
            dB(j) = sqrt(min(dis(bSeg==1)));
        end
    elseif(strcmp(version, 'ver1') == 1 || strcmp(version, 'ver3')==1)
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
        end
     elseif(strcmp(version, 'ver5') == 1)
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
        end
    end
end