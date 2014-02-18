  function  [bone] = select_bone(dicom_cube)

[m,n,o]=size(dicom_cube);

for i=100:o
    close all;
    dicom_layer = dicom_cube(:,:,i);
    [thres, thresholded_dicom_layer] = multithresholding(dicom_layer,2);
    
    %if left_click  
     himage = imshow(thresholded_dicom_layer, []);
    % himage = imshow(dicom_layer, []);
    
    title(sprintf('slice %d/%d',i,o))
    [x,y,button] = ginput(1);
    
    if(button == 1)
        init_x = round(axes2pix(size(thresholded_dicom_layer, 2), get(himage, 'XData'), x));
        init_y = round(axes2pix(size(thresholded_dicom_layer, 1), get(himage, 'YData'), y));
        bone_contours = region_growing(thresholded_dicom_layer, 1, [init_y, init_x, 1]);
        name = fieldnames(bone_contours);
        name= name{1};
        slice = sprintf('slice%d',i); 
       % figure,
       % plot(calcaneus_contours.(name)(:,1), calcaneus_contours.(name)(:,2), 'LineWidth', 2)
        bone.(slice)= [bone_contours.(name)(:,1), bone_contours.(name)(:,2)];
        continue
    end
  close all
    % w region growing zrob tak zeby nie trzeba bylo podac konturu i przejs
    % dalej oraz zeby mozna bylo podac dowolna liczbe konturow
    % x = calcaneus_contours.contour1(:,1);
    % y = calcaneus_contours.contour1(:,2);
    
    
end    

close all
  end
  