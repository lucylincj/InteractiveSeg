%/////////////////////////////////////////////////////////////////////////
% This function compute the complete E2 chart
% Input:
% @version: specify the different versions of computing E2 ex. 'ver0'
% @neighboroing: a numSegments x numSegments size form,
%                if n1 and n2 superpixels are adjacent, neiboring(n1, n2)=1
% @parameters: include lambda, param1 and param2 for Cr
%
% author : r01942054@NTU
% date : 2014.05
%//////////////////////////////////////////////////////////////////////////
function newE2 = updateE2(version, neighboring, param)
    global numSegments fSeg bSeg meanColor meanCoord colorDis ; 
    newE2 = zeros(numSegments, numSegments);
    [pair1, pair2] = find(triu(neighboring, 1)==1);
    %//////////////////////////////////////////////////////////////////////
    % Ver0
    %//////////////////////////////////////////////////////////////////////
    if(strcmp(version, 'ver0') || strcmp(version, 'ver3') ==1)
        for i = 1:size(pair1, 1)
            n1 = pair1(i);
            n2 = pair2(i);
            if( n2 > n1 && ((fSeg(n1)-bSeg(n1)) * (fSeg(n2)-bSeg(n2)) ~= 1))
                C = colorDis(n1, n2);
                newE2(n1, n2) = 1 / (C^2 + 1) * ...
                sqrt((meanCoord(1, n1) - meanCoord(1, n2)).^2 + (meanCoord(2, n1) - meanCoord(2, n2)).^2);
            end
        end
        newE2 = newE2*param(1);
    %//////////////////////////////////////////////////////////////////////
    % Ver1
    %//////////////////////////////////////////////////////////////////////
    elseif(strcmp(version, 'ver1') || strcmp(version, 'ver2')==1)
        addUpDis = sum(colorDis, 2);
        nNeighbor = sum(neighboring, 2)/2;
    	param1 = param(1) / param(2);
    	param2 = 1-param1;
        for i = 1:size(pair1, 1)
            n1 = pair1(i);
            n2 = pair2(i);
            if( n2 > n1 && ((fSeg(n1)-bSeg(n1)) * (fSeg(n2)-bSeg(n2)) ~= 1))
                % at the right-upper triangle && not both belong to bg or fg
                C = colorDis(n1, n2);
                Cr = (addUpDis(n1) + addUpDis(n2)) / (nNeighbor(n1) + nNeighbor(n2));
                newE2(n1, n2) = 1 / (1 + C^2 * param1 + Cr^2 * param2)...
                   * sqrt((meanCoord(1, n1) - meanCoord(1, n2)).^2 + (meanCoord(2, n1) - meanCoord(2, n2)).^2);
            end
        end
        newE2 = newE2*param(3);
    end
end