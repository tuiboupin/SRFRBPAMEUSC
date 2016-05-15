% Discrete-Continuous Optimization for Multi-Target Tracking
%
% This code contains minor modifications compared
% to the one that was used
% to produce results for our CVPR 2012 paper
% 
% (C) Anton Andriyenko, 2012
%
% The code may be used free of charge for non-commercial and
% educational purposes, the only requirement is that this text is
% preserved within the derivative work. For any other purpose you
% must contact the authors for permission. This code may not be
% redistributed without written permission from the authors.



clear all
global dcStartTime
dcStartTime=tic;

addpath(genpath('../contracking/utils/'))
homefolder='d:'; if ~ispc, homefolder=['~' filesep]; end
addpath(genpath(fullfile(homefolder,'software','gco-v3.0')));

%% seed random for deterministic results
rng(1);

%% declare global variables
global detections nPoints sceneInfo opt globiter gtInfo;
globiter=0;

global LOG_allens LOG_allmets2d LOG_allmets3d %for debug output


% fill options struct
opt=getDCOptions;

% fill scene info
scenario=23;
sceneInfo=getSceneInfo(scenario);
% sceneInfo=getSceneInfoDCDemo;

frames=1:length(sceneInfo.frameNums);
frames=651:750; % do a part of the whole sequence
sceneInfo.frameNums=sceneInfo.frameNums(frames);


%% cut GT to tracking area
if  sceneInfo.gtAvailable && opt.track3d && opt.cutToTA
    gtInfo=cutGTToTrackingArea(gtInfo);
end

%% remove unnecessary frames from GT
if sceneInfo.gtAvailable
    gtInfo.frameNums=gtInfo.frameNums(frames);
    gtInfo.X=gtInfo.X(frames,:);gtInfo.Y=gtInfo.Y(frames,:);
    gtInfo.W=gtInfo.W(frames,:);gtInfo.H=gtInfo.H(frames,:);
    if opt.track3d
        gtInfo.Xgp=gtInfo.Xgp(frames,:);gtInfo.Ygp=gtInfo.Ygp(frames,:);
    end
    gtInfo=cleanGT(gtInfo);

end

%
if opt.visOptim,  reopenFig('optimization'); end
%% load detections
[detections nPoints]=parseDetections(sceneInfo,frames); 
[detections nPoints]=cutDetections(detections,nPoints);
detMatrices=getDetectionMatrices(detections);

%% top image limit
sceneInfo.imTopLimit=min([detections(:).yi]);
computeImBordersOnGroundPlane;

% evaluateDetections(detMatrices,gtInfo);

T=size(detections,2);                   % length of sequence
stateInfo.F=T; stateInfo.frameNums=sceneInfo.frameNums;

%% put all detections into a single vector
alldpoints=createAllDetPoints(detections);

%% create spatio-temporal neighborhood graph
TNeighbors=getTemporalNeighbors(alldpoints);

%% init solution
% generate initial spline trajectories
mhs=getSplineProposals(alldpoints,opt.nInitModels,T);

%
%% get splines from EKF
mhsekf=getSplinesFromEKF(scenario,1:5,frames,alldpoints,T);
mhs=[mhs mhsekf];
nCurModels=length(mhs);
nInitModels=nCurModels;


%% set initial labeling to all outliers
nCurModels=length(mhs);
nLabels=nCurModels+1; outlierLabel=nLabels;
labeling=nLabels*ones(1,nPoints); % all labeled as outliers


%% initialize labelcost
[splineGoodness goodnessComp]=getSplineGoodness(mhs,1:opt.nInitModels,alldpoints,T);
% [prox proxt proxcost]=getSplineProximity(mhs,1:nInitModels,alldpoints,labeling,T,proxcostFactor,splineGoodness);

% unary is constant to outlierCost
Dcost = opt.outlierCost * ones(nLabels,nPoints);
Scost=opt.pairwiseFactor-opt.pairwiseFactor*eye(nLabels);
Lcost=getLabelCost(mhs);

[inE inD inS inL] = getGCO_Energy(Dcost, Scost, Lcost, TNeighbors, labeling);
bestE=inE; E=inE; D=inD; S=inS; L=inL;

%%
printDCUpdate(stateInfo,mhs,[],0,0,0,D,S,L);

%% first plot
drawDCUpdate(mhs,1:length(mhs),alldpoints,0,outlierLabel,TNeighbors,frames);


nAddRandomModels=10; % random models
nAddModelsOutliers=10;

nAdded=0; nRemoved=0;

%% start energy minimization loop
itcnt=0; % only count one discrete-continuous cycle as one iteration
iteachcnt=0; % count each discrete and each continuous optimization step
used=[];
mhsafterrefit=[];
lcorig=opt.labelCost;
while 1
%     opt.labelCost=itcnt*lcorig;
    oldN=length(mhs);
    for m=1:length(mhs)
        if ~isempty(intersect(m,used))
            mhs(m).lastused=0; 
        else
            mhs(m).lastused=mhs(m).lastused+1;
        end
    end
    
    mhs_=mhs;
    tokeep=find([mhs.lastused]<3);
    mhs=mhs(tokeep);   
    
    nRemoved=oldN-length(tokeep);
    nCurModels=length(mhs); nLabels=nCurModels+1; outlierLabel=nLabels;


    
    % old labeling
    l_ = labeling;
    E_=E; D_=D; S_=S; L_=L;
    
    %% relabel
    % minimize discrete Energy E(f), (Eq. 4)
    Dcost=getUnarySpline(nLabels,nPoints,mhs,alldpoints,opt.outlierCost,opt.unaryFactor,T);
    Lcost=getLabelCost(mhs);
    Scost=opt.pairwiseFactor-opt.pairwiseFactor*eye(nLabels);
    [E D S L labeling]=doAlphaExpansion(Dcost, Scost, Lcost, TNeighbors);
    
    % if new energy worse (or same), restore previous labeling and done
    if E >= bestE
        printMessage(2, 'Discrete Optimization did not find a lower energy\n');
        labeling=l_;
        mhs=mhsafterrefit;
        E=E_; D=D_; S=S_; L=L_;
        nCurModels=length(mhs); nLabels=nCurModels+1; outlierLabel=nLabels;
        
        used=setdiff(unique(labeling),outlierLabel); nUsed=numel(used);
        break;
    end
    
    % otherwise refit and adjust models
    bestE=E;
    itcnt=itcnt+1;
    iteachcnt=iteachcnt+1;
    
    outlierLabel=nLabels;
    used=setdiff(unique(labeling),outlierLabel); nUsed=numel(used);
    

    
    % print update
    drawDCUpdate(mhs,used,alldpoints,labeling,outlierLabel,TNeighbors,frames);
    [m2d m3d]=printDCUpdate(stateInfo,mhs,used,nAdded,nRemoved,iteachcnt,D,S,L);
    LOG_allens(iteachcnt,:)=double([D S L]);LOG_allmets2d(iteachcnt,:)=m2d;LOG_allmets3d(iteachcnt,:)=m3d;
    
    % now refit models (Eq. 1)
    mhsbeforerefit=mhs;
    mhsusedbeforerefit=mhs(used);
    mhsnew=reestimateSplines(alldpoints,used,labeling,nLabels,mhs,Dcost,T);
    %     mhsnew=reestimateSplines(allpoints,used,labeling,minCPs,ncpsPerFrame);
    mhsafterrefit=mhsnew;
    
    Dcost=getUnarySpline(nLabels,nPoints,mhsnew,alldpoints,opt.outlierCost,opt.unaryFactor,T);
    Lcost = getLabelCost(mhsnew);
    Scost=opt.pairwiseFactor-opt.pairwiseFactor*eye(nLabels);
    h=setupGCO(nPoints,nLabels,Dcost,Lcost,Scost,TNeighbors);
    GCO_SetLabeling(h,labeling);
    [E D S L] = GCO_ComputeEnergy(h);    
    GCO_Delete(h);
    
    
    mhs(used)=mhsnew(used);
    nCurModels=length(mhs);
    clear Scost Dcost Lcost
    
    iteachcnt=iteachcnt+1;

    % print update
    drawDCUpdate(mhs,1:length(mhs),alldpoints,0,outlierLabel,TNeighbors,frames);
%     pause(.2);
    drawDCUpdate(mhs,used,alldpoints,labeling,outlierLabel,TNeighbors,frames);
    printDCUpdate(stateInfo,mhs,used,nAdded,nRemoved,iteachcnt,D,S,L);
    LOG_allens(iteachcnt,:)=double([D S L]);LOG_allmets2d(iteachcnt,:)=m2d;LOG_allmets3d(iteachcnt,:)=m3d;
    
%     %% Expand the hypothesis space
    if nCurModels<opt.maxModels
        nModelsBeforeAdded=nCurModels;
        
        %% get random new proposals
        mhsnew=getSplineProposals(alldpoints,nAddRandomModels,T);
        mhs=[mhs mhsnew];
        
        %% get new proposals from outliers
        outlierPoints=find(labeling==outlierLabel); % indexes
        if length(outlierPoints)>4
            outlpts=selectPointsSubset(alldpoints,outlierPoints);
            mhsnew=getSplineProposals(outlpts,nAddRandomModels,T);
            mhs=[mhs mhsnew];
        end
        
        %% extend existing
        mhs=extendSplines(alldpoints,mhs,used,labeling,T,E);
        
        %% merge existing
        mhs=mergeSplines(alldpoints,mhs,used,labeling,T,E);
        
    end
    nCurModels=length(mhs); nLabels=nCurModels+1; outlierLabel=nLabels;
    nAdded=nCurModels-length(mhsbeforerefit);
    

end
% basically we are done
printMessage(1,'All done (%.2f min = %.2fh = %.2f sec per frame)\n',toc(dcStartTime)/60,toc(dcStartTime)/3600,toc(dcStartTime)/stateInfo.F);

%% final plot
drawDCUpdate(mhs,used,alldpoints,labeling,outlierLabel,TNeighbors,frames);


%%
stateInfo=getStateFromSplines(mhs(used), stateInfo);
stateInfo=postProcessState(stateInfo);

%% if we have ground truth, evaluate results
printFinalEvaluation(stateInfo)



% you can display the results with
% displayTrackingResult(sceneInfo,stateInfo)