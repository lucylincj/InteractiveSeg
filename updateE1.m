function E1 = updateE1(numSegments, fSeg, bSeg, dF, dB, infinite)
    E1 = zeros(2, numSegments);
    for i = 1:numSegments
        if ( bSeg(i) == 1 )%background
            E1(1, i) = 0;
            E1(2, i) = infinite;
        elseif ( fSeg(i) == 1)%foreground
            E1(1, i) = infinite;
            E1(2, i) = 0;
        else
            E1(1, i) = dB(i) / (dF(i) + dF(i));
            E1(2, i) = dF(i) / (dF(i) + dF(i));
        end
    end
    
end