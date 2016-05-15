function drawPoints(allpoints,labeling,outlierLabel,TNeighbors)
% plot detections as points
% 
% (C) Anton Andriyenko, 2012
%
% The code may be used free of charge for non-commercial and
% educational purposes, the only requirement is that this text is
% preserved within the derivative work. For any other purpose you
% must contact the authors for permission. This code may not be
% redistributed without written permission from the authors.



% return;

npts=length(allpoints.xp);
for np=1:min(2000,npts) 
    msize=15;
    if length(labeling)>1,
        IDcol=getColorFromID(labeling(np)); marker='.';
        if labeling(np)==outlierLabel, IDcol='k'; marker='o'; msize=msize/4; end
    else
        IDcol=.6*ones(1,3); marker='.';
    end
%     plot3(allpoints.xp(np),allpoints.yp(np), allpoints.tp(np),marker,'color',IDcol,'MarkerSize',5);
            plot3(allpoints.xp(np),allpoints.yp(np), allpoints.tp(np),marker,'color',IDcol,'MarkerSize',msize*allpoints.sp(np));
    
%             thisneighb=find(TNeighbors(np,:));
%             nthisn=numel(thisneighb);
%             for nn=1:nthisn
%                 plot3([allpoints.xp(np) allpoints.xp(thisneighb(nn))], ...
%                     [allpoints.yp(np) allpoints.yp(thisneighb(nn))], ...
%                     [allpoints.tp(np) allpoints.tp(thisneighb(nn))],'color',.6*ones(1,3))
%             end
end
% randpts=randperm(npts); randpts=randpts(1:100);
% for np=randpts
%     text(allpoints.xp(np),allpoints.yp(np), allpoints.tp(np),sprintf('%.2f',allpoints.sp(np)));
% end

pause(0.001);
end
