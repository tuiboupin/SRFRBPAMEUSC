function dwt=getDetsForTraj(mhs,alldpoints,T,tau)
% count the number of detections that a close
% to a trajectory (< threshold tau)
% 
% (C) Anton Andriyenko, 2012
%
% The code may be used free of charge for non-commercial and
% educational purposes, the only requirement is that this text is
% preserved within the derivative work. For any other purpose you
% must contact the authors for permission. This code may not be
% redistributed without written permission from the authors.


% if nargin<4
%     tau=0.25; % threshold
% end


tt=mhs.start:mhs.end;
dwt=-1*ones(1,T);

splinexy=ppval(mhs,1:T);
for t=tt
    sx=splinexy(1,t); sy=splinexy(2,t);
%     t
%     sx
    
    % find all detections in this frame
    detind=find(alldpoints.tp==t);
%     detind
    sp=[sx*ones(1,numel(detind)); sy*ones(1,numel(detind))];
    dp=[alldpoints.xp(detind);alldpoints.yp(detind)];
    d=sp-dp;
    inthisframe=sqrt(sum(d.^2)) < tau;
%     sqrt(sum(d.^2))/1000
    dwt(t)=sum(inthisframe);
end


end