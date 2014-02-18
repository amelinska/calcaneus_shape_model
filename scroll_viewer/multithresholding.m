function [thresh, segmented_image] = multithresholding(image, level_num)

thresh = multithresh(image,level_num);
segmented_image = imquantize(image, thresh);


segmented_image = segmented_image*max(image(:))/(level_num+1);
%rgb = label2rgb(segmented_image);
%gray_segmented_image = rgb2gray(rgb);
%figure, imshowpair(image,segmented_image,'montage')
%figure, imshowpair(image, rgb,'montage')



end