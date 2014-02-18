
clear all;

dicom_cube = gather_dicom_cube;
[bone_contour] = select_bone(dicom_cube);  %calcaneus 
plot_3d_bones(bone,1)

[cortical_bones, trabecular_bones, p,q,r]= multithresholding_for_3d(dicom_cube,2);
plot_3d_thresholded(p,q,r,cortical_bones,10);



%cortical_cube = save_bones3d_to_3d_matrix_as_bw(cortical_bones);
%bone3d = regionGrowing(cortical_cube, init_pos);
%plot3(bone3d(:,1), bone3d(:,2), bone3d(:,3), '.', 'LineWidth', 2)


%------------for 3d
% [cortical_bones, trabecular_bones, p,q,r]= multithresholding_for_3d(dicom_cube,2);
% cortical_cube = save_bones3d_to_3d_matrix_as_bw(cortical_bones);
% trabecular_cube = save_bones3d_to_3d_matrix_as_bw(trabecular_bones);
% bone3d = select_bone_3d(cortical_cube);
% plot3(bone3d(:,1), bone3d(:,2), bone3d(:,3), '.', 'LineWidth', 2)
