function mh=getSplineProposals(alldpoints,n,T)
% generate splines from the set of detections
% 
% (C) Anton Andriyenko, 2012
%
% The code may be used free of charge for non-commercial and
% educational purposes, the only requirement is that this text is
% preserved within the derivative work. For any other purpose you
% must contact the authors for permission. This code may not be
% redistributed without written permission from the authors.


mh=getEmptyModelStruct;

global sceneInfo

ndp=length(alldpoints.xp);

assert(ndp>4,'at least 4 points needed to generate proposals...');
% relpercent=10;
q=2;


speedThreshold = sceneInfo.targetSize;
tauThreshold = sceneInfo.targetSize/2;

maxtries=1e3;
maxtries2=1e3;
generated=0;
trygen2=0;
while generated<n
    trygen2=trygen2+1;
    trygen=0;
    while 1
        trygen=trygen+1;
        randorder=randi(q-1)+1;
        %         randorder=4;
%         randPointsO=unique(randi(ndp,1,randorder)); % pick up to q unique random points
%         randPoints=randperm(ndp,randorder);
        %%%% CAREFUL, THIS IS FOR q=2 ONLY
        while 1
            randPoints=randi(ndp,1,randorder);
            if diff(randPoints), break; end
        end
%         randPoints=randperm(ndp);
%         randPoints=randPoints(1:randorder);
%         randPoints=randsample(ndp,randorder)';
        [sortedt sidx]=sort(alldpoints.tp(randPoints));
%         randorder
%         uniquetO=unique(alldpoints.tp(randPoints));
%         sortedt
        uniquet=sum(~~diff(sortedt))+1;
%         randPointsO
%         uniquetO
%         randPoints
%         uniquet
%         pause
        timegap=sortedt(end)-sortedt(1);
        ener=max(0,(timegap-4));
        prob=exp(-ener);
%         randnum=rand;
        %         fprintf('ener: %.2f, prob: %2.f, rand: %.2f\n',ener,prob,randnum);
        if prob < rand && trygen<maxtries, continue; end
        
        %         sortedt
        %         sidx
        p1=[alldpoints.xp(randPoints(sidx(1))); alldpoints.yp(randPoints(sidx(1)))];
        p2=[alldpoints.xp(randPoints(sidx(end))); alldpoints.yp(randPoints(sidx(end)))];
        spacegap=norm(p2-p1);
        speedpf=spacegap/timegap;
        if speedpf>speedThreshold && trygen<maxtries, continue; end
        
        %         [timegap        spacegap        speedpf]
        %         generated
        
        if uniquet>=randorder %&& min(alldpoints.tp(randPoints))<T/relpercent && max(alldpoints.tp(randPoints))>T-T/relpercent
            break
        end
    end
    
    xy=[alldpoints.xp(randPoints);alldpoints.yp(randPoints)];
    t=alldpoints.tp(randPoints);
%     confs=alldpoints.sp(randPoints);
    
    order=numel(randPoints);
    tryfit=splinefit(t,xy,1,order);
    if numel(find(isnan(tryfit.coefs))), continue; end %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % make cubic
    if order~=4
        sortedt=sort(t);
        t=linspace(sortedt(1),sortedt(end),4);
        xy=ppval(tryfit,t);
        cubicspline=splinefit(t,xy,1,4);
    else
        cubicspline=tryfit;
    end
    
    if numel(find(isnan(cubicspline.coefs))), continue; end %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    cubicspline.start=min(t);    cubicspline.end=max(t);
    
    %     cubicspline.start=1;    cubicspline.end=10;
    
    if trygen2<maxtries2
%         dwi=getDetsForTraj(cubicspline,alldpoints,T,tauThreshold);
%         if mean(dwi(dwi>=0)) < rand, continue; end
    end
    
    generated=generated+1;
    [sg, ~]=getSplineGoodness(cubicspline,1,alldpoints,T);
    cubicspline.goodness=sg;
    cubicspline.lastused=0;
    mh(generated)=cubicspline;
    %         tgap(generated)=diff([min(t) max(t)]);
end

% mean(tgap)
end