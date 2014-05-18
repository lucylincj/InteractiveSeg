function newE2 = updateE2(neighboring)
    global numSegments fSeg bSeg meanColor meanCoord; 
    newE2 = zeros(numSegments, numSegments);
    [pair1, pair2] = find(neighboring==1);
    for i = 1:size(pair1, 1)
        n1 = pair1(i);
        n2 = pair2(i);
        %if( n2 > n1 && ((fSeg(n1)-bSeg(n1)) * (fSeg(n2)-bSeg(n2)) ~= 1))
        if( n2 > n1 )
            % at the right-upper triangle && not both belong to bg or fg
            C =  (meanColor(:, n1) - meanColor(:, n2))' * (meanColor(:, n1) - meanColor(:, n2));
            newE2(n1, n2) = 1 / (1 + C) * sqrt((meanCoord(1, n1) - meanCoord(1, n2)).^2 + (meanCoord(2, n1) - meanCoord(2, n2)).^2);
        end
    end
    newE2 = newE2*100;
end