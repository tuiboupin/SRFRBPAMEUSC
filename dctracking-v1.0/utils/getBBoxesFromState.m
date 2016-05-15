function stateInfo=getBBoxesFromState(stateInfo)
% for visualization and for 2D evaluation
% we need the bounding boxes of the targets
% To this end, we check for corresponding detections
% and interpolate them to get the solution boxes
% 
% (C) Anton Andriyenko, 2012
%
% The code may be used free of charge for non-commercial and
% educational purposes, the only requirement is that this text is
% preserved within the derivative work. For any other purpose you
% must contact the authors for permission. This code may not be
% redistributed without written permission from the authors.

global detections sceneInfo
% [~, N F targetsExist X Y]=getStateInfo(stateInfo);
X=stateInfo.X; Y=stateInfo.Y;

[F,N]=size(X);
stateInfo.asscDet = zeros(F,N);
targetsExist=getTracksLifeSpans(X);

W=zeros(size(X));
H=zeros(size(Y));


for id=1:N
    sid=targetsExist(id,1);
    eid=targetsExist(id,2);
    frames=sid:eid;
    asscDet=zeros(1,F); % which detection is close by?
    widths=zeros(1,F);
    heights=zeros(1,F);
    scores=zeros(1,F);
    
    
    % find closest detections
    for t=frames
        ndets=length(detections(t).xp); % how many dets in this frame
        if ndets
            xy=[X(t,id); Y(t,id)];
            dets=[detections(t).xp; detections(t).yp];
        
            alldist=sqrt(sum((repmat(xy,1,ndets)-dets).^2)); % distance to all        
            [mindist,mindet]=min(alldist);
            if mindist<=sceneInfo.targetSize
                asscDet(t)=mindet;
                widths(t)=detections(t).wd(mindet);
                heights(t)=detections(t).ht(mindet);
                scores(t)=detections(t).sc(mindet);
            end
        end        
    end
    stateInfo.asscDet(:,id) = asscDet; % add associated detection to stateInfo
    detsAssc=find(asscDet); % which detections associated
    detsAsscWobble=detsAssc;%+0.01*rand(1,length(t))-0.005; % add random noise to avoid NaN in fitting (LOOK INTO THIS!)    
    
    if numel(unique(detsAssc))>1
    polydeg=min(9,max(1,floor(numel(detsAssc)/100)));
    polystr=sprintf('poly%d',polydeg);
    
%     global gdetsAssc gwidths
%     gdetsAssc=detsAssc; gwidths=widths(detsAssc);
%     detsAssc
%     unique(detsAssc)
%     heights(detsAssc)
%     numel(detsAssc)
%     
%     polydeg
%     
%     polystr
%     p=polyfit(detsAssc,widths(detsAssc),max(1,floor(numel(detsAssc)/100)));
%     p=fit(detsAssc',widths(detsAssc)',polystr,'Normalize','on','Robust','on');
    
%     ipolwidths = polyval(p,frames);
%     ipolwidths = feval(p,frames);
%     W((sid:eid)',id)=ipolwidths';



    
    
%     
%     
%     numel(detsAssc)
%     p=polyfit(detsAssc,heights(detsAssc),max(1,round(numel(detsAssc)/100)));
%     [p,~,~,~]=fit(detsAssc',heights(detsAssc)',polystr,'Normalize','on','Robust','on');
      sp=splinefit(detsAsscWobble, heights(detsAssc),1,max(1,floor(numel(detsAssc)/100))+1,'r',scores(detsAssc));
%     pause
    
%     ipolheights = polyval(p,frames);
%     ipolheights = feval(p,frames);
        ipolheights=ppval(sp,frames);
    
    
    H((sid:eid)',id)=ipolheights';
    
    if ~isfield(sceneInfo,'targetAR') % if no aspect ratio given, estimate widths        
%         [p,~,~,~]=fit(detsAssc',widths(detsAssc)',polystr,'Normalize','on','Robust','on');
        sp=splinefit(detsAsscWobble, widths(detsAssc),1,max(1,floor(numel(detsAssc)/100))+1,'r',scores(detsAssc));
%         ipolwidths = feval(p,frames);
        ipolwidths = ppval(sp,frames);

        W((sid:eid)',id)=ipolwidths';
        
    end
    
    else % strange trajectory with < 3 detections
        detwidthmean=[]; detheightmean=[];
%         sid
%         eid
        for t=sid:eid
            detwidthmean=[detwidthmean mean(detections(t).wd)];
            detheightmean=[detheightmean mean(detections(t).ht)];
        end
%         detwidthmean
%         detheightmean
        detwidthmean(isnan(detwidthmean))=mean(detwidthmean(~isnan(detwidthmean)));
        detheightmean(isnan(detheightmean))=mean(detheightmean(~isnan(detheightmean)));
%         detwidthmean
%         detheightmean
        W((sid:eid)',id)=detwidthmean;
        H((sid:eid)',id)=detheightmean;
    end
    
    
    
%     detsAsscWobble
% 
%     detsAssc
%     unique(detsAssc)
%     heights(detsAssc)
%     numel(detsAssc)
% 
%     clf
%     hold on
% %     size(frames)
% %     size(ipolwidths)
%     plot(detsAssc,heights(detsAssc),'o')
%     plot(frames,ipolheights,'r')
%     plot(frames,ppval(sp,frames),'k');
%     
% %     global HP
% %     plot(frames,HP((sid:eid)',id),'--');
%     
% %     plot(frames,lincomb,':');
%     
% %     size(sid:eid)
% %     size(ipolheights)
%     pause
    
    
end

% if we have camera calibration
% lets assume all people are 1.7m tall and push
% the heights of bboxes towards that value
if isfield(sceneInfo,'camPar')
    heightPrior=getHeightPrior(stateInfo);
    prwght=.8;
    H=(1-prwght)*H + prwght*heightPrior;   
    
end



% aspectRatio= 1/2;
% aspectRatio= 1/3;
% aspectRatio=1;

% normalize ratio to dataset mean?
if sceneInfo.gtAvailable
    global gtInfo
    arithmean=mean(gtInfo.W(~~gtInfo.W)./gtInfo.H(~~gtInfo.H));    
    aspectRatio= arithmean; 
end

stateInfo.H=H;

% at least 30 pixels heigh
stateInfo.H(stateInfo.H<30)=30;


% if aspect ratio provided by user, take it
if isfield(sceneInfo,'targetAR')
    stateInfo.W=H*sceneInfo.targetAR;
%     stateInfo.W=H*sceneInfo.targetAR; % or take data set mean
else
    stateInfo.W=W;
end


% at least 15 pixels wide
stateInfo.W(stateInfo.W<15)=15;

% clean up mess
stateInfo.W(~X)=0; stateInfo.H(~X)=0;

% WTF?
% isnanH=find(isnan(stateInfo.H));
% isnumH=setdiff(find(stateInfo.H),isnanH);
% stateInfo.H(isnanH)=mean(stateInfo.H(isnumH));
% isnanW=find(isnan(stateInfo.W));
% isnumW=setdiff(find(stateInfo.W),isnanW);
% stateInfo.W(isnanW)=mean(stateInfo.W(isnumW));


    

end