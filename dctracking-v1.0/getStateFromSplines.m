function stateInfo=getStateFromSplines(splines, stateInfo, onImage)
% convert splines to matrices X and Y
% 
% (C) Anton Andriyenko, 2012
%
% The code may be used free of charge for non-commercial and
% educational purposes, the only requirement is that this text is
% preserved within the derivative work. For any other purpose you
% must contact the authors for permission. This code may not be
% redistributed without written permission from the authors.


global sceneInfo opt
N=length(splines);
F=stateInfo.F;
X=zeros(F,N);
Y=zeros(size(X));

for id=1:N
    tt=splines(id).start:splines(id).end;
    
    allxy=ppval(splines(id),tt)';
    X(tt,id)=allxy(:,1);    Y(tt,id)=allxy(:,2);
    
    
end

stateInfo.X=X;stateInfo.Y=Y;
if nargin<3
    onImage=0;
end

if opt.track3d
    stateInfo.Xgp=X;stateInfo.Ygp=Y;
    if onImage
        [stateInfo.Xi stateInfo.Yi]=projectToImage(stateInfo.X,stateInfo.Y,sceneInfo);    
    end
else
    stateInfo.Xi=X; stateInfo.Yi=Y;
end
end