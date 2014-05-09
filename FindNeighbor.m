function adj = FindNeighbor(segments, numSegments)
    [w, h] = size(segments);
    adj=eye(numSegments);
    hseg=segments(:,[2:h,h]);
    vseg=segments([2:w,w],:);
    f1=find(hseg~=segments);
    f2=find(vseg~=segments);
    adj(segments(f1)*numSegments+hseg(f1)+1)=1;
    adj(segments(f2)*numSegments+vseg(f2)+1)=1;
    adj=max(adj,adj')-eye(numSegments);
end