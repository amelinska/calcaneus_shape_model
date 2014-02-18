
clear all;
dicom_cube = gather_dicom_cube;
bone = select_bone(dicom_cube);  %calcaneus 
plot_3d_bones(bone,1)