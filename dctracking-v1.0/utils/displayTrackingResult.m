function displayTrackingResult(sceneInfo, stateInfo)
% Display Tracking Result
%
% Take scene information sceneInfo and
% the tracking result from stateInfo
% 
% 
% (C) Anton Andriyenko, 2012
%
% The code may be used free of charge for non-commercial and
% educational purposes, the only requirement is that this text is
% preserved within the derivative work. For any other purpose you
% must contact the authors for permission. This code may not be
% redistributed without written permission from the authors.

% [~, ~, ~, ~, X Y]=getStateInfo(stateInfo);
W=stateInfo.W;
H=stateInfo.H;
Xi=stateInfo.Xi;
Yi=stateInfo.Yi;
recog_result=stateInfo.recog_result;

options.defaultColor=[.1 .2 .9];
options.grey=.7*ones(1,3);
options.framePause=0.01; % pause between frames

options.traceLength=1000; % overlay track from past n frames
options.dotSize=20;
options.boxLineWidth=2;
options.traceWidth=2;

options.hideBG=0;

% what to display
options.displayDots=1;
options.displayBoxes=1;
options.displayID=1;
options.displayRecogResult=1;
options.displayCropouts=0;
options.displayConnections=1;
options.displayVisits=1;
options.logVisits=1;
options.logPasses=1;
options.logRecogResults=1;

% Location boxes
options.B = [217,241,23,30;690,261,248,65;1021,286,102,24;1154,312,38,17; ...
    1638,344,70,2;305,339,117,37;773,313,96,111;1039,345,65,9; ...
    1540,410,42,83;292,368,25,32;750,494,75,86;1130,511,19,76];
options.BSize = size(options.B);
options.numLocations = options.BSize(1);
options.drawLocations = 1;

% max movement when stationary
options.dx = 18;
options.dy = 7;
options.frames2beStationary = 10;

% save?
options.outFolder='.\test\Results';

reopenFig('Tracking Results')
displayBBoxes(sceneInfo,stateInfo.frameNums,Xi,Yi,W,H,recog_result,options)


end