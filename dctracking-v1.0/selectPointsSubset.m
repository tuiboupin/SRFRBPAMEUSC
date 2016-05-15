function outpts=selectPointsSubset(alldpoints,selection)
% TODO
% 
% (C) Anton Andriyenko, 2012
%
% The code may be used free of charge for non-commercial and
% educational purposes, the only requirement is that this text is
% preserved within the derivative work. For any other purpose you
% must contact the authors for permission. This code may not be
% redistributed without written permission from the authors.



    Field = fieldnames(alldpoints);

        for iField = 1:length(Field)
            fcontent=alldpoints.(char(Field(iField)));
            outpts.(char(Field(iField)))=fcontent(selection);
        end

end