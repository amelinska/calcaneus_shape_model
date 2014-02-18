
function [threedarray,xthickness, ythickness,zthickness] = gather_dicom_cube() 
close all
clear all
current_folder = pwd;
folder = 'C:\Users\Aleksandra\Desktop\W11\image_proc_proof\01_082013\foot';
%folder = uigetdir('D:\piety_dicom');
cd(folder);
d = ls('*.dcm');
m = size(d,1);
topimage = dicomread(d(1,:));
metadata = dicominfo(d(1,:));

[group1 element1] = dicomlookup('PixelSpacing');
[group2 element2] = dicomlookup('SliceThickness');
resolution = metadata.(dicomlookup(group1, element1));
xthickness = resolution(1);
ythickness = resolution(2);
zthickness = metadata.(dicomlookup(group2, element2));

threedarray = zeros(size(topimage,1),size(topimage,2),size(d,1));
threedarray(:,:,1) = topimage;
for i = 2:size(d,1)
    threedarray(:,:,i) = dicomread(d(i,:));
    
end
% save temp threedarray
% save temp xthickness
% save temp ythickness
% save temp zthickness

%return_folder = 'C:\Users\Aleksandra\Desktop\W11\image_proc_proof\STLRead\stl_with_shadows_reader\3dedge_detection\reg_grow';
cd(current_folder);
end