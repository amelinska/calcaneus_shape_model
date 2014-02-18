

% dicom_cube = gather_dicom_cube;
% INPUT: dicom_images listed in folder - gather_dicom_images needs a folder
% with dicoms in input and it gives in OUTPUT the dicom_cube (threedarray) size of [m n o];
% m n -  size of each image and o number of dicom files

% [bone_contour] = select_bone(dicom_cube);
% function allows you to contour extraction of bones by using region
% growing on all slices. Click button 1 on mouse to a indicate a point that belongs to area of
% bone you are interested. You have to do it on each slice, where you see bone you are interested in.
% To go next (there is no area you are interested in ),
% click button 3 on mouse(next). To break (you finished) click button 2 on mouse. 
% INPUT: dicom_cube 
% OUTUT: struct of contours of bone on each slice


dicom_cube = gather_dicom_cube;
[bone_contour] = select_bone(dicom_cube);  %calcaneus 
plot_3d_bones(bone_contour,1)