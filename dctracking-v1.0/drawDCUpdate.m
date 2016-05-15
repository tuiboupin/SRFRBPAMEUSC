function    drawDCUpdate(mhs,used,alldpoints,labeling,outlierLabel,TNeighbors,frames)
% plot the minimization iterations
% 
% (C) Anton Andriyenko, 2012
%
% The code may be used free of charge for non-commercial and
% educational purposes, the only requirement is that this text is
% preserved within the derivative work. For any other purpose you
% must contact the authors for permission. This code may not be
% redistributed without written permission from the authors.


global opt
if opt.visOptim
    prepFigure; drawPoints(alldpoints,labeling,outlierLabel,TNeighbors);
    drawSplines(mhs,used,labeling,alldpoints,frames)
end

end