function plotFinal(stateInfo)
[frames,tracks] = size(stateInfo.X);
targetsExist=getTracksLifeSpans(stateInfo.X);
prepFigure;
for i=1:tracks
    IDcol=getColorFromID(i);
    sid=targetsExist(i,1);
    eid=targetsExist(i,2);
    X = transpose(stateInfo.X(sid:eid,i));
    Y = transpose(stateInfo.Y(sid:eid,i));
    Z = stateInfo.frameNums(sid:eid);
    plot3(X,Y,Z,'Marker','^','MarkerSize',2,'Color',IDcol);
end