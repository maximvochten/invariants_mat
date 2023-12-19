function R = rot_y(alpha)
%ROT_X Summary of this function goes here
%   Detailed explanation goes here

alpha = alpha*pi/180;
R = [cos(alpha) 0 sin(alpha) ; 0 1 0 ; -sin(alpha) 0 cos(alpha)];

end

