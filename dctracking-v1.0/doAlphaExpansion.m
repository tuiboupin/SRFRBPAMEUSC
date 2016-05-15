function [E D S L labeling]=doAlphaExpansion(Dcost, Scost, Lcost, Neighborhood)
% minimize E(f,T) wrt. f by alpha expansion
% 
% (C) Anton Andriyenko, 2012
%
% The code may be used free of charge for non-commercial and
% educational purposes, the only requirement is that this text is
% preserved within the derivative work. For any other purpose you
% must contact the authors for permission. This code may not be
% redistributed without written permission from the authors.


% The gco code is available at
% http://vision.csd.uwo.ca/code/


% set up GCO structure
[nLabels nPoints]=size(Dcost);

h=setupGCO(nPoints,nLabels,Dcost,Lcost,Scost,Neighborhood);


GCO_Expansion(h);
labeling=GCO_GetLabeling(h)';
[E D S L] = GCO_ComputeEnergy(h);
GCO_Delete(h);
end