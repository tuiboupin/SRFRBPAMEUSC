function [s]=TimeStamp
%[s]=TimeStamp
% time stamp in the format
% year-month-day-hours-h-minutes-m-second-s

tmp = strrep(datestr(clock), ':' , '-' );
s = strrep(tmp, ':' , '-' );

