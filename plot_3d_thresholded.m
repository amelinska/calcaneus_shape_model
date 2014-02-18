function plot_3d_thresholded(p,q,r, bones3d, subsampling)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

x=1:p;
y=1:q;
z=1:r;
[X,Y,Z]=meshgrid(x,y,z);
X=X(bones3d);
Y=Y(bones3d);
Z=Z(bones3d);
figure, plot3(X(1:subsampling:end),Y(1:subsampling:end),Z(1:subsampling:end),'r.');


end

