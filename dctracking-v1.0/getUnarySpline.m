function Dmat = getUnarySpline(nLabels,nPoints,mh,allpoints,dphi,uF,T)
% compute unary energy term for all data points and all labels
% 
% (C) Anton Andriyenko, 2012
%
% The code may be used free of charge for non-commercial and
% educational purposes, the only requirement is that this text is
% preserved within the derivative work. For any other purpose you
% must contact the authors for permission. This code may not be
% redistributed without written permission from the authors.


global opt

if isempty(mh)
    Dmat = dphi * ones(nLabels,nPoints);
    return
end

normfac=1;
if opt.track3d, normfac=1000; end


Dmat=zeros(nLabels,nPoints);

exthead=2;
exttail=2;
allpind=1:nPoints;

for l=1:nLabels-1
    %
    splstart=mh(l).start-exttail;
    splend=mh(l).end+exthead;
    splineTimespan=max(1,splstart):min(T,splend);
    %
    %         spltime=splstart:splend;
    inSplineTimespan=find(allpoints.tp>=splstart & allpoints.tp<=splend);
%     allothers=setdiff(1:nPoints,inSplineTimespan);
    notinSplineTimespan=true(1,nPoints);
    notinSplineTimespan(inSplineTimespan)=0;
    allothers=find(allpind & notinSplineTimespan);
    
    %
    pt=allpoints.tp(inSplineTimespan);
    xt=ppval(mh(l),pt)'; %pts on spline
    px=allpoints.xp(inSplineTimespan);
    py=allpoints.yp(inSplineTimespan);
    pt=allpoints.tp(inSplineTimespan);
    sp=allpoints.sp(inSplineTimespan);
    
    datapts=[px; py]';
    alldists=xt-datapts;
    
    alldists=alldists';
    alldists=sqrt(sum(alldists.^2))/normfac; % L2 norm in m
    
    alln=alldists.^2;
    
    
    Dmat(l,inSplineTimespan)=(alln .* sp);
    Dmat(l,allothers)=1e5;
end

Dmat=uF*Dmat;


Dmat(nLabels,1:nPoints)=dphi;
Dmat(nLabels,1:nPoints)=dphi*allpoints.sp;
%     Dmat=Dmat+1;
Dmat(Dmat>1e6)=1e6;
Dmat(Dmat<-1e5)=-1e5;

end