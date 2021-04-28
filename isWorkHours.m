function [ w ] = isWorkHours( t )
%ISWORKHOURS Outputs true if t is between 9am and 5pm on a weekday
%   t is day of the year, we assume that the year starts on a monday
w = zeros(size(t));
w([mod(floor(t),7)<6 & (mod(t,1) > 0.375 & mod(t,1) < 0.7083)]) = 1;
end

