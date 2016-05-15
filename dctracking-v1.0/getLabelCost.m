function Lcost=getLabelCost(splines)
% Compute the label cost for all splines
% 
% (C) Anton Andriyenko, 2012
%
% The code may be used free of charge for non-commercial and
% educational purposes, the only requirement is that this text is
% preserved within the derivative work. For any other purpose you
% must contact the authors for permission. This code may not be
% redistributed without written permission from the authors.


global opt

nCurModels=length(splines);

lc1=opt.labelCost*ones(1,nCurModels); % standard uniform
lc2=opt.goodnessFactor*[splines.goodness]; % hdyn, hfid, hper,...
lc3=0;%proxcostFactor*proxcost;
Lcost =[lc1+lc2+lc3 0];
    
end