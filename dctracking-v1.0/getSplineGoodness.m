function [goodness components]=getSplineGoodness(mh,used,alldpoints,T)
% compute the goodness (label cost) of each trajectory
% 
% (C) Anton Andriyenko, 2012
%
% The code may be used free of charge for non-commercial and
% educational purposes, the only requirement is that this text is
% preserved within the derivative work. For any other purpose you
% must contact the authors for permission. This code may not be
% redistributed without written permission from the authors.


goodness=zeros(1,length(used));
components=zeros(length(used),10);
global sceneInfo opt

gF=opt.goodnessFactor;
% no need to compute if coefficient is 0 anyway
if ~gF, return; end


areaLimits=sceneInfo.trackingArea;


tau=sceneInfo.targetSize/2;
% if ~opt.track3d, tau=10; end



tt=1:T;
global dwi;

stateInfo=getStateFromSplines(mh, struct('F',T));

for m=used
    confpermodel=[];
    distpermodel=[];
    mhs=mh(m);
    tt=mhs.start:mhs.end;
    %     tt
    TT=length(tt);
%     m
%     mhs
%     splinexy=ppval(mhs,1:T);
    splinexy=[stateInfo.X(:,m)';stateInfo.Y(:,m)'];

    
    detsWithin=-1*ones(1,T);
    insideAL=zeros(1,T); % inside areaLimits
%     insideIM=zeros(1,T); % inside imageLimits
    
    for t=tt
        sx=splinexy(1,t); sy=splinexy(2,t);
        
        
%         if sx>minX && sx<maxX && sy>minY && sy<maxY
        
            % find all detections in this frame
            %             eval(sprintf('detind=detind%i;',t));
            detind=find(alldpoints.tp==t);
            %         t
            insideAL(t)=1;
            detsWithin(t)=0;
            
            
            %             sp=repmat([sx;sy],1,numel(detind));
            sp=[sx*ones(1,numel(detind)); sy*ones(1,numel(detind))];
            dp=[alldpoints.xp(detind);alldpoints.yp(detind)];
            d=sp-dp;
            
            alldist=sqrt(sum(d.^2));
%             alldist=sqrt(sum(d.^2))/10;
            
            inthisframe= alldist < tau;
            
%             alldistinframe(inthisframe)=alldist(inthisframe);
%             alldistinframe(alldist>=tau)=tau;
%             if ~isempty(alldistinframe)
%                 alldistinframe=mean(alldistinframe);
%                 distpermodel=[distpermodel alldistinframe];
%             end

            
            confinframe=alldpoints.sp(detind(inthisframe>0));
            confpermodel=[confpermodel confinframe];
            %             [t confinframe]
            detsWithin(t)=sum(inthisframe);
            %             for np=detind
            %                 dp=[alldpoints.xp(np);alldpoints.yp(np)];
            %                 sp=[sx;sy];
            %                 eucl = norm(dp-sp);
            %     %             eucl
            %     %             pause
            %                 if eucl < tau
            % %                     plot3(dp(1),dp(2),t,'o');
            % %     %                 plot3(sp(1),sp(2),t,'+');
            % %     pause
            %
            %                     detsWithin(t)=detsWithin(t)+1;
            %                 end
            %             end
%         end
        
    end
    %     if m==6 || m==32 || m==36
    %         detsWithin
    %         insideAL
    %     end
    
    
    %     [m    dpm]
    
    
    dwi=detsWithin;
    
    detsinta=detsWithin(insideAL>0);
    detsinta=detsWithin;
%     goodness(m)=sum(abs(detsWithin(insideAL>0)-1)); % simple per frame number of detections
    
    % occlusion gaps
    nodetframes=[0 ~detsWithin(insideAL>0) 0];
    multdetframes=[0 detsinta>1 0];
    %     nodetframes
    %     multdetframes
    c=find(diff(nodetframes)==1); d=find(diff(nodetframes)==-1);
    e=find(diff(multdetframes)==1); f=find(diff(multdetframes)==-1);
    occgaps=(d-c);
    muldetgaps=(f-e);
    %     d
    %     c
    %     occgaps
    %     detsWithin(insideAL>0)
    % muldetgaps
    % detsWithin
    % occgaps
    occgapspen=0;
    occgapsfac=1;
    occgapspen=occgapsfac*sum(occgaps.^3);% + ...
    %sum(muldetgaps.^2);% + ...
    
    notonedets=0;
%     notonedets=sum(abs(detsWithin(insideAL>0)-1));
    
    
%     g=find(diff(~insideAL)==1); h=find(diff(~insideAL)==-1);
%     outsidegaps=(h-g);
    outsideAL=0;   
%     outsideAL=sum(outsidegaps.^2);
%     outsideAL=5 *sum(~insideAL);
    
    %     cfpm=median(confpermodel);
    %     sigcfpm=100/(1+exp(-25+50*cfpm));
    %     goodness(m)=goodness(m)+sigcfpm;
    
    %% disttodets
    distfac=10;
%     dpm=tau;
%     if ~isempty(distpermodel), dpm=mean(distpermodel); end    
%     dpm=dpm/tau; dpm=dpm^4;

    
    disttodets=0;
%     disttodets=distfac*dpm;
    
    %     piecefac=.1;
    %     goodness(m)=goodness(m)+piecefac*mhs.pieces^2;
    
    mhs=mh(m);

    %% persistence
    perfac=.1;

    persistencestart=0;
    persistenceend=0;
    s=mhs.start; e=mhs.end;
%     xy=ppval(mh(m),[s e]);
    xy=[stateInfo.X([s e],m)';stateInfo.Y([s e],m)'];
    
    if s>1
        xs=xy(1,1); ys=xy(2,1);
        if opt.track3d
            [dms ci si]=min_dist_im(xs,ys,sceneInfo.imOnGP);
        else
            [dms ci si]=min_distances(xs,ys,sceneInfo.trackingArea);
        end
        
        dms=min(dms,opt.borderMargin);
        persistencestart=perfac*dms;
    end
    
    if e<T
        xe=xy(1,2); ye=xy(2,2);
        if opt.track3d
            [dme ci si]=min_dist_im(xe,ye,sceneInfo.imOnGP);
        else
            [dme ci si]=min_distances(xe,ye,sceneInfo.trackingArea);
        end
        dme=min(dme,opt.borderMargin);
        persistenceend=perfac*dme;
    end    
    
    %% speed
    speedfac=1.;
    speedpen=0;
    speedpen=speedfac*max(abs(mhs.coefs(:,1)));
 
    %% standing object most likely a false positive
    standing=0;
%     c1_3=max(max(abs(mhs.coefs(:,1:3))));
%     if c1_3<10,        standing=1e5;    end
    
    %% penalize short ones
    shorties=0;
    trl=mh(m).end-mh(m).start;
    shorties=10*1/trl;
    
    %% penalize number of pieces
    piecespen=0;
    piecefac=50;
%     piecespen=piecefac*mh(m).pieces;
 
    
 allpens=[occgapspen notonedets outsideAL disttodets persistencestart persistenceend speedpen standing shorties piecespen];
 components(m,:)=allpens;
%  allpens
    goodness(m)=sum(allpens);    
end
%% d(p,L) = (y0-y1)*x + (x1-x0)*y + (x0*y1-x1*y0) ) / (sqrt((x1-x0)^2 + (y1-y0)^2) )

goodness=goodness(used);
goodness(goodness>1e5)=1e5;
end

function [dm ci si]=min_dist_im(x,y,imOnGP)

% left
x0=imOnGP(1);y0=imOnGP(2);
x1=imOnGP(3);y1=imOnGP(4);
dl = p2l(x,y,x0,x1,y0,y1);

% top
x0=imOnGP(3);y0=imOnGP(4);
x1=imOnGP(5);y1=imOnGP(6);
du = p2l(x,y,x0,x1,y0,y1);

% right
x0=imOnGP(5);y0=imOnGP(6);
x1=imOnGP(7);y1=imOnGP(8);
dr = p2l(x,y,x0,x1,y0,y1);

% bottom
x0=imOnGP(7);y0=imOnGP(8);
x1=imOnGP(1);y1=imOnGP(2);
dd = p2l(x,y,x0,x1,y0,y1);

distances=abs([dl dr du dd]);

% choose the closest one
[dm ci]=min(distances);


si=1;
% if x<minX || x>maxX || y<minY || y>maxY
%     si=-1;
% end
end

function dl=p2l(x,y,x0,x1,y0,y1)
dl = ((y0-y1)*x + (x1-x0)*y + (x0*y1-x1*y0) ) / (sqrt((x1-x0)^2 + (y1-y0)^2) );
end

function [dm ci si]=min_distances(x,y,areaLimits)
% returns min distance from x,y to border and index ci

minX=areaLimits(1); % left border
maxX=areaLimits(2); % right border
minY=areaLimits(3); % bottom border
maxY=areaLimits(4); % top border

% determine distance to all four borders

% dist left
dl=abs(minX-x); % dl=x-minX;
% dist right
dr=abs(maxX-x); %dr=maxX-x;
% dist up
du=abs(minY-y); %du=y-minY;
% dist down
dd=abs(maxY-y); %dd=maxY-y;
distances=[dl dr du dd];

% choose the closest one
[dm ci]=min(distances);

si=1;
if x<minX || x>maxX || y<minY || y>maxY
    si=-1;
end

end