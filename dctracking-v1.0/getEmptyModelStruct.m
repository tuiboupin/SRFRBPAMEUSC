function ret=getEmptyModelStruct()
% trajectory model
% same as pmpp object plus temporal start and end points
% as well as the corresponding label cost and a counter
% that states how many iterations ago this trajectory was used last time
% 
% (C) Anton Andriyenko, 2012
%
% The code may be used free of charge for non-commercial and
% educational purposes, the only requirement is that this text is
% preserved within the derivative work. For any other purpose you
% must contact the authors for permission. This code may not be
% redistributed without written permission from the authors.



ret = struct('form',{},'breaks',{},'coefs',{},'pieces',{},'order',{},'dim',{},'start',{},'end',{},'goodness',{},'lastused',{});

end