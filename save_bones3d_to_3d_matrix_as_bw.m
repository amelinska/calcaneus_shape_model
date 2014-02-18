function [bones_cube] = save_bones3d_to_3d_matrix_as_bw(bones3d)


[m, n]=size(bones3d);
bones_cube = zeros(m,m,n/m);
bones_cube = reshape(bones3d,m,m,n/m);

end
