function E1 = updateE1(version, infinite, dF, dB, dTF, dTB)
%function E1 = updateE1(dF, dB, infinite)
    global numSegments fSeg bSeg;
    E1 = zeros(2, numSegments);
    if(strcmp(version, 'ver0')==1 || strcmp(version, 'ver2')==1)
        for i = 1:numSegments
            if ( bSeg(i) == 1 )%background
                E1(1, i) = 0;
                E1(2, i) = infinite;
            elseif ( fSeg(i) == 1)%foreground
                E1(1, i) = infinite;
                E1(2, i) = 0;
            else
                E1(1, i) = dB(i) / (dF(i) + dB(i));
                E1(2, i) = dF(i) / (dF(i) + dB(i));
            end
        end
    elseif(strcmp(version, 'ver1')==1 || strcmp(version, 'ver3')==1)
        for i = 1:numSegments
            if ( bSeg(i) == 1 )%background
                E1(1, i) = 0;
                E1(2, i) = infinite;
            elseif ( fSeg(i) == 1)%foreground
                E1(1, i) = infinite;
                E1(2, i) = 0;
            else
                E1(1, i) = dB(i) / (dF(i) + dB(i)) + dTB(i) / (dTF(i) + dTB(i));
                E1(2, i) = dF(i) / (dF(i) + dB(i)) + dTF(i) / (dTF(i) + dTB(i));
            end
        end
    end
end