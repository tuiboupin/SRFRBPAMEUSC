function [ result ] = YinsideX( X, Y )
%Returns:
% 1 if box Y is inside box X
% 2 if box Y also above center of X
% 3 if box Y inside and touches center
% 4 if box Y inside, above center of X and touces horizontal center
result = 0;
if ( X(1) < Y(1) ) && ( X(2) < Y(2) ) && (( X(4) + X(2) ) > ( Y(4) + Y(2) )),
    Xcx = X(1) + X(3)/2;
    Xcy = X(2) + X(4)/2;
    if ((X(4)+X(2))>(Y(4)+Y(2)))
        result = 1;
        if (Xcx > Y(1) && Xcx < Y(3) + Y(1) && Xcy > Y(2) && ...
                Xcy < Y(4) + Y(2))
            result = 3;
        end
    end
    if ( X(4) + X(2)/2 > Y(4) + Y(2) )
        result = 2;
        if Xcx > Y(1) && Xcx < Y(3) + Y(1)
            result = 4;
        end
    end
end

end

