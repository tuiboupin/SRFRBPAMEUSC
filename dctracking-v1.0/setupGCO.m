function h=setupGCO(nPoints,nLabels,Dcost,Lcost,Scost,Neighborhood)
% set up and return handle for a GCO structure
% to be optimized via GCO alpha expansion
% 
% (C) Anton Andriyenko, 2012
%
% The code may be used free of charge for non-commercial and
% educational purposes, the only requirement is that this text is
% preserved within the derivative work. For any other purpose you
% must contact the authors for permission. This code may not be
% redistributed without written permission from the authors.



h = GCO_Create(nPoints,nLabels);
GCO_SetDataCost(h,int32(Dcost));
GCO_SetLabelCost(h,int32(Lcost));

if ~isempty(Scost) && any(any(Scost))
    GCO_SetSmoothCost(h,int32(Scost));
    GCO_SetNeighbors(h,Neighborhood);
end

end