function mhsret=mergeSplines(allpoints, mhs, used,labeling,T,E)
% construct new models from existing ones by 
% merging plausible ones
% 
% (C) Anton Andriyenko, 2012
%
% The code may be used free of charge for non-commercial and
% educational purposes, the only requirement is that this text is
% preserved within the derivative work. For any other purpose you
% must contact the authors for permission. This code may not be
% redistributed without written permission from the authors.


mhsnew=getEmptyModelStruct();

global opt
normfac=1;
thr1=25;
thr2=2;
thr3=50;
if opt.track3d
    normfac=1000;
    thr1=.5;
    thr2=2;
    thr3=1;
end

%% merge close ones only
nMaxAddMerged=50;
nCurModels=length(mhs);
addedMerged=0;
nUsed=length(used);
if nUsed>1
    for m1=randperm(nUsed)
        mod1=used(m1);
        mh1=mhs(mod1);
        s1=mh1.start;
        e1=mh1.end;
        for  m2=randperm(nUsed)
            if addedMerged>=nMaxAddMerged, break; end
            
            mod2=used(m2);
            mh2=mhs(mod2);
            s2=mh2.start;
            e2=mh2.end;
            timegap=s2-e1;
            if timegap < -10 || timegap > 10, continue; end
            xyend=ppval(mh1,e1);
            xystart=ppval(mh2,s2);
            xe=xyend(1); ye=xyend(2);
            xs=xystart(1); ys=xystart(2);
            spacegap=norm(xystart-xyend)/normfac;
            if ~timegap, timegap=1; end
            speedpf=abs(spacegap/timegap);
            %                                          speedpf
            if speedpf < thr1 || (abs(timegap) <= thr2 && speedpf < thr3)
                
                % fit through points
                supp1=find(labeling==mod1);
                supp2=find(labeling==mod2);
                allsup=[supp1 supp2];
                
                t=allpoints.tp(allsup);
                % FIXME
                tr=t+0.01*rand(1,length(t))-0.005;
                
                xy=[allpoints.xp(allsup);allpoints.yp(allsup)];
                
                addedMerged=addedMerged+1;
                sfit=splinefit(tr,xy,round(mh1.pieces+mh2.pieces));
                sfit.start=min(t); sfit.end=max(t);
                [sfit.goodness sgc]=getSplineGoodness(sfit,1,allpoints,T);
                sfit.lastused=0;
                mhsnew(addedMerged) = sfit;
                
                %                         drawSplines(sfit,1,0,alldpoints,frames);
                %                         [mod1 mod2]
                %                         [timegap speedpf]
                %                         sg=getSplineGoodness([mhs(mod1) mhs(mod2) sfit],1:3,alldpoints,areaLimits,imageLimits,T,goodnessFactor)
                %                         pause
                
                % fit through splines
                xt1=ppval(mh1,s1:e1); %pts on spline
                xt2=ppval(mh2,s2:e2);
                xy=[xt1 xt2];
                t=[s1:e1 s2:e2];
                tr=t+0.01*rand(1,length(t))-0.005;
                addedMerged=addedMerged+1;
                sfit=splinefit(tr,xy,round(mh1.pieces+mh2.pieces));
                sfit.start=min(t); sfit.end=max(t);
                [sfit.goodness sgc]=getSplineGoodness(sfit,1,allpoints,T);
                sfit.lastused=0;
                mhsnew(addedMerged) = sfit;
                
                
                
            end
        end
    end
    
end

allnewgoodness=[mhsnew.goodness];
mhsnew=mhsnew(E>allnewgoodness);
for m=1:length(mhsnew), mhsnew(m).lastused=0; end

mhsret=mhs;
if ~isempty(mhsnew), mhsret=[mhs mhsnew]; end
end