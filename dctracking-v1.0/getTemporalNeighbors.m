function TNeighbors=getTemporalNeighbors(allpoints)
% get spatio-temporal neighbors for each detection (Fig. 3)
% 
% (C) Anton Andriyenko, 2012
%
% The code may be used free of charge for non-commercial and
% educational purposes, the only requirement is that this text is
% preserved within the derivative work. For any other purpose you
% must contact the authors for permission. This code may not be
% redistributed without written permission from the authors.



global opt
nPoints=length(allpoints.xp);
TNeighbors=sparse(nPoints,nPoints);

allt=unique(sort(allpoints.tp));
allt=allt(1:end-1);
for t=allt
    thist=find(allpoints.tp==t);
    nextt=find(allpoints.tp==t+1);
    nt=numel(thist);
    ntt=numel(nextt);
    if nt>1
        for np1=1:nt
            for np2=1:ntt
                eucldist=norm([allpoints.xp(thist(np1)) allpoints.yp(thist(np1))] - ...
                    [allpoints.xp(nextt(np2)) allpoints.yp(nextt(np2))]);
                
                if eucldist < opt.tau
                    TNeighbors(thist(np1),nextt(np2))=1;
                end                
            end
            
        end
    end
    
end

% allt=unique(sort(allpoints.tp));
% allt=allt(1:end-2);
% for t=allt
%     thist=find(allpoints.tp==t);
%     nextt=find(allpoints.tp==t+2);
%     nt=numel(thist);
%     ntt=numel(nextt);
%     if nt>1
%         for np1=1:nt
%             for np2=1:ntt
%                 eucldist=norm([allpoints.xp(thist(np1)) allpoints.yp(thist(np1))] - ...
%                     [allpoints.xp(nextt(np2)) allpoints.yp(nextt(np2))])/1000;
%                 
%                 if eucldist < .7
%                     TNeighbors(thist(np1),nextt(np2))=1;
%                 end                
%             end
%             
%         end
%     end
%     
% end

% TNeighbors=1*TNeighbors;
% TNeighbors=TNeighbors+TNeighbors';

end