 function plot_3d_bones(bone,subsampling)
% %UNTITLED Summary of this function goes here
% %   Detailed explanation goes here

field_names = fieldnames(bone);

% if ~exist('number_of_bone', 'var') || isempty(number_of_bone)
    structSize = length(field_names);
% else 
%     structSize = number_of_bone;
% end


for i=1:structSize
    
    poly = bone.(char(field_names(i)));
    %hold all;
    x = poly(:,1);
    y = poly(:,2);
    [m,n]=size(x);
    z=ones(m,1)*i;
  % plot3(x,y,z,'r.')
    plot3(x(1:subsampling:end),y(1:subsampling:end),z(1:subsampling:end), ...
    '.', 'Color', rand(1,3));

    hold on;
end


 end


