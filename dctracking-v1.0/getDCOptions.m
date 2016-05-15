function opt=getDCOptions()
% 
% (C) Anton Andriyenko, 2012
%
% The code may be used free of charge for non-commercial and
% educational purposes, the only requirement is that this text is
% preserved within the derivative work. For any other purpose you
% must contact the authors for permission. This code may not be
% redistributed without written permission from the authors.



% general
opt.track3d=1;                  % set to 1 for track estimation on ground plane
opt.verbosity=3;                % 0=silent, 1=short info, 2=long info, 3=all
opt.visOptim=1;                 % visualize optimization
opt.met2d=0;                    % always compute metrics in 2d (slower)
opt.maxModels=20000;            % max number of trajectory hypotheses
opt.keepHistory=3;              % keep unused models for n iterations
opt.cutToTA=0;                  % cut detections, ground truth and result to tracking area


% defaults (2d)
opt.labelCost=      200;
opt.outlierCost=    200;
opt.unaryFactor=    .1;
opt.pairwiseFactor= 100;
opt.goodnessFactor= 10;
opt.proxcostFactor= 0.0;
opt.nInitModels=    50;
opt.minCPs=         1;
opt.ncpsPerFrame=   1/50;   
opt.totalSupFactor= 2;
opt.meanDPFFactor=  2;
opt.meanDPFeFactor= 2;
opt.curvatureFactor=0;
opt.tau =           10;     % threshold (pixel) for spatio-temporal neighbors
opt.borderMargin =  100;   % (pixel) % distance for persistence



if opt.track3d
    opt.labelCost=      20;
    opt.outlierCost=    20;
    opt.unaryFactor=    10;
    opt.pairwiseFactor= 2;
    opt.goodnessFactor= 0.1;
    
    opt.tau =           750;   % threshold (mm) for spatio-temporal neighbors
    opt.borderMargin = 5000;    % distance for persistence
end


end