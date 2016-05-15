function splines=reestimateSplines(allpoints,used,labeling,nLabels,mhsall,DcostAll,T)
% refit splines to data points
% minimize continuous variables T
% 
% (C) Anton Andriyenko, 2012
%
% The code may be used free of charge for non-commercial and
% educational purposes, the only requirement is that this text is
% preserved within the derivative work. For any other purpose you
% must contact the authors for permission. This code may not be
% redistributed without written permission from the authors.


if isempty(used)
    splines=mhsall;
    return
end

global opt

nPoints=length(allpoints.xp);
minCPs=opt.minCPs;
ncpsPerFrame=opt.minCPs;

exttail=2;
exthead=2;
nUsed=length(used);
Eold=zeros(0,4);Enew=zeros(0,4);
splines=mhsall;
for m=used
%     mhsallnew=mhsall;
    
    mhsold=splines(m);
    
    %%%  Consistency check!
    % compute old energy
    Dcost=DcostAll;
    Lcost = getLabelCost(splines);    
    h=setupGCO(nPoints,nLabels,Dcost,Lcost,[],[]);
    GCO_SetLabeling(h,labeling);
    [E D S L] = GCO_ComputeEnergy(h);    
    GCO_Delete(h);
%     Eold=[Eold; E D S L];
    
    % find all points labeled m
    supportPts=find(labeling==m);
    nSP=length(supportPts);
    
    % careful! if less than 2 points, make standing object
    if nSP<1
        error('This cannot happen... I think');
    elseif nSP==1
        xy=[allpoints.xp(supportPts);allpoints.yp(supportPts)];        xy=[xy xy];
        t=allpoints.tp(supportPts); 
        confs=allpoints.sp(supportPts); 
        if t==1,
            t=[t t+1];
        else
            t=[t-1 t];
        end
        torig=t;
        confsorig=confs;

        supPtsFrames=t;
    else
        xy=[allpoints.xp(supportPts);allpoints.yp(supportPts)];
        t=allpoints.tp(supportPts);
        confs=allpoints.sp(supportPts); 
        [supPtsFrames sortind]=sort(allpoints.tp(supportPts));    
               
        % try here this...
        % take n first and last points and fit a line to extrapolate
        % add these to support
        takenpts=4;
        torig=t;
        confsorig=confs;
        if nSP>=takenpts
            if exttail
                ntail=sortind(1:takenpts);     
                tailpts=supportPts(ntail);
                xytail=[allpoints.xp(tailpts);allpoints.yp(tailpts)];
                ttail=allpoints.tp(tailpts);
                ctail=allpoints.sp(tailpts);
            
                if length(unique(ttail))>2
                    tailline=splinefit(ttail,xytail,1,2,ctail);
                    taillinepts=ppval(tailline,supPtsFrames(1)-exttail:supPtsFrames(1)-1);
                    xy=[taillinepts xy];
                    t=[supPtsFrames(1)-exttail:supPtsFrames(1)-1 torig];
                    confs=[ones(1,exttail) confsorig];
                end
            end
            
            if exthead
                nhead=sortind(end-takenpts+1:end);
                headpts=supportPts(nhead);
                xyhead=[allpoints.xp(headpts);allpoints.yp(headpts)];
                thead=allpoints.tp(headpts);
                chead=allpoints.sp(headpts);
                if length(unique(thead))>2
                    headline=splinefit(thead,xyhead,1,2,chead);
                    headlinepts=ppval(headline,supPtsFrames(end)+1:supPtsFrames(end)+exthead);

                    xy=[xy headlinepts];
                    t=[t supPtsFrames(end)+1:supPtsFrames(end)+exthead];
                    confs=[confs ones(1,exthead)];
                end
            end
        end
    end
    
    splineorder=4;        
    order=min(nSP,splineorder);
    
    
    
    trackLength(m)=supPtsFrames(end)-supPtsFrames(1);            
    ncps=max(minCPs,round(trackLength(m)*ncpsPerFrame));
    
    tr=t+0.01*rand(1,length(t))-0.005; % add random noise to avoid NaN in fitting (LOOK INTO THIS!)    
    breaks=linspace(supPtsFrames(1),supPtsFrames(end),ncps);
    tryfit=splinefit(tr,xy,mhsold.pieces,mhsold.order,confs);

    % force cubic spline
    if order<splineorder
        sortedt=sort(tr);
        t=linspace(sortedt(1),sortedt(end),splineorder);
        xy=ppval(tryfit,t);
        sfit=splinefit(t,xy,1,splineorder);        
    else
        sfit=tryfit;
    end
    
    sfit.start=min(torig);    sfit.end=max(torig);
    sfit.start=mhsold.start;    sfit.end=mhsold.end;
    [sfit.goodness sgc]=getSplineGoodness(sfit,1,allpoints,T);
    sfit.lastused=0;
    
    % consistency check
    % compute new energy
    spl2=splines; spl2(m)=sfit;
    DcostNew=getUnarySpline(2,nPoints,sfit,allpoints,opt.outlierCost,opt.unaryFactor,T);
    Dcost=DcostAll;
    Dcost(m,:)=DcostNew(1,:);
    Lcost = getLabelCost(spl2);
    h=setupGCO(nPoints,nLabels,Dcost,Lcost,[],[]);
    GCO_SetLabeling(h,labeling);
    [E_ D_ S_ L_] = GCO_ComputeEnergy(h);    
    GCO_Delete(h);
%     Enew=[Enew; E_ D_ S_ L_];
       
    % only if continuous optimization reduced
    if E_<=E
        splines(m)=sfit;
    end

    
    
end

end