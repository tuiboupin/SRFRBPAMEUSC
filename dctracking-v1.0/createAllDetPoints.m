function alldpoints=createAllDetPoints(detections)
% put all data points (detections) into one struct
% 
% (C) Anton Andriyenko, 2012
%
% The code may be used free of charge for non-commercial and
% educational purposes, the only requirement is that this text is
% preserved within the derivative work. For any other purpose you
% must contact the authors for permission. This code may not be
% redistributed without written permission from the authors.


T=size(detections,2); 
alldpoints.xp=[];alldpoints.yp=[];alldpoints.sp=[];alldpoints.tp=[];
for t=1:T
    alldpoints.xp=[alldpoints.xp detections(t).xp];
    alldpoints.yp=[alldpoints.yp detections(t).yp];
    alldpoints.sp=[alldpoints.sp detections(t).sc];
    alldpoints.tp=[alldpoints.tp t*ones(1,length(detections(t).xp))];    
end