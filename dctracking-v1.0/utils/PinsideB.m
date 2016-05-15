function [ result ] = PinsideB( P, B )
%Returns 1 if point P [x y] is inside bbox B [x y width height]
result = 0;
if ( B(1) <= P(1) && B(2) <= P(2) && B(1) + B(3) >= P(1) && B(2) + B(4) >= P(2)),
    result = 1;
end

end

