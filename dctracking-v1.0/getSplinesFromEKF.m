function mhs=getSplinesFromEKF(solfile,frames,alldpoints,T)
% Fit splines through an existing EKF solution
% 
% (C) Anton Andriyenko, 2012
%
% The code may be used free of charge for non-commercial and
% educational purposes, the only requirement is that this text is
% preserved within the derivative work. For any other purpose you
% must contact the authors for permission. This code may not be
% redistributed without written permission from the authors.


mhs=getEmptyModelStruct;



newmods=0;
% for experiment=exp
    % ncps=3;
%     solfile=getSolutionFile(scenario,experiment,'ekf');
%     solfile=fullfile(getHomeFolder,'diss','ekftracking','output',sprintf('s%04d',scenario),sprintf('e%04d.mat',experiment));
    if ~exist(solfile,'file')
        mhs=[];
        
        return;
    end
    
    load(solfile);
    ncps=max(1,round(length(frameNums)/50));
    
    % X=X(1:Fd,:);Y=Y(1:Fd,:);
    % X=removeShorties(X,2);Y=removeShorties(Y,2);
    [F N]=size(X);
    if length(frames)<F
        X=X(frames,:); Y=Y(frames,:);
    end
    
    exthead=2;
    exttail=5;
    [F N]=size(X);
    for id=1:N
        
        
        cptimes=find(X(:,id));
        if length(cptimes)>3
            %% extend to first and last frame
            ff=cptimes(1);  lf=cptimes(end); trl=lf-ff;
            ncps=max(1,round(trl/50));
            
            torig=cptimes';
            xy=[X(cptimes,id) Y(cptimes,id)]';
            
            
            ttail=cptimes(1:4);
            xytail=[X(ttail,id) Y(ttail,id)]';
            
            if length(unique(ttail))>2
                tailline=splinefit(ttail,xytail,1,2);
                tailtime=torig(1)-exttail:torig(1)-1;
                taillinepts=ppval(tailline,tailtime);
                
                xy=[taillinepts xy];
                cptimes=[(cptimes(1)-exttail:cptimes(1)-1)'; cptimes];
            end
            thead=cptimes(end-3:end);
            xyhead=[X(thead,id) Y(thead,id)]';
            
            if length(unique(thead))>2
                headline=splinefit(thead,xyhead,1,2);
                headlinepts=ppval(headline,torig(end)+1:torig(end)+exthead);
                
                xy=[xy headlinepts];
                cptimes=[cptimes; (cptimes(end)+1:cptimes(end)+exthead)'];
            end
            
            
            
            newmods=newmods+1;
            sfit=splinefit(cptimes,xy,ncps);
            sfit.start=ff; sfit.end=lf;
            [sfit.goodness sgc]=getSplineGoodness(sfit,1,alldpoints,T);
            sfit.lastused=0;
            mhs(newmods)=sfit;
        end
    end
% end

%% check for doubles

if ~isempty(mhs)
    dists=Inf*ones(newmods);
    for m1=1:newmods
        for m2=m1+1:newmods
            if mhs(m1).pieces==mhs(m2).pieces
                dists(m1,m2)=sum(sum(abs(mhs(m1).coefs-mhs(m2).coefs)));
            end
        end
    end
    
    redundant=sum(~dists,2);
    mhs=mhs(~redundant);
end

end