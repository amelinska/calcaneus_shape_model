function [P, J] = region_growing_2d(input_image, initial_position, threshold, maximal_distance, region_mean, fill_holes, subsampling)



    himage = findobj('Type', 'image');
    input_image = get(himage, 'CData');
    himage = findobj('Type', 'image');
    himage = imshow(input_image, []);
  
    
    % graphical user input for the initial position
    p = ginput(1);
    
    % get the pixel position concerning to the current axes coordinates
    initial_position(1) = round(axes2pix( size(input_image, 2), get(himage, 'XData'), p(2) ));
    initial_position(2) = round(axes2pix( size(input_image, 1), get(himage, 'YData'), p(1) ));



    threshold = double((max(input_image(:)) - min(input_image(:)))) * 0.05;


    region_value = double(input_image(initial_position(1), initial_position(2)));
    [nRow, nCol] = size(input_image);
    maximal_distance = Inf;
    region_mean = false;
    fill_holes = true;
    subsampling = true;
    simplifyTolerance = 1;
    

    % preallocate array
    J = false(nRow, nCol);
    queue = [initial_position(1), initial_position(2)];
    
    %%% START OF REGION GROWING ALGORITHM
while size(queue, 1)
  % the first queue position determines the new values
  xv = queue(1,1);
  yv = queue(1,2);
%   zv = queue(1,3);
 
  % .. and delete the first queue position
  queue(1,:) = [];
    
  % check the neighbors for the current position
  for i = -1:1
    for j = -1:1
        if xv+i > 0  &&  xv+i <= nRow &&...          % within the x-bounds?
           yv+j > 0  &&  yv+j <= nCol &&...          % within the y-bounds?          
           any([i, j])       &&...      % i/j/k of (0/0/0) is redundant!
           ~J(xv+i, yv+j)    &&...          % pixelposition already set?
           sqrt( (xv+i-initial_position(1))^2 +...
                 (yv+j-initial_position(2))^2)  < maximal_distance &&...   % within distance?
           input_image(xv+i, yv+j) <= (region_value + threshold) &&...% within range
           input_image(xv+i, yv+j) >= (region_value - threshold) % of the threshold?

           % current pixel is true, if all properties are fullfilled
           J(xv+i, yv+j) = true; 

           % add the current pixel to the computation queue (recursive)
           queue(end+1,:) = [xv+i, yv+j];

           if region_mean
               region_value = mean(mean(input_image(J > 0))); 
           end
        
        end
    end  
  end
end
%%% END OF REGION GROWING ALGORITHM


% loop through each slice, fill holes and extract the polygon vertices
P = [];
% for cSli = 1:nSli
%     if ~any(J(:,:,cSli))
%         continue
%     end
%     
% 	% use bwboundaries() to extract the enclosing polygon
%     if fill_holes
%         % fill the holes inside the mask
%         J(:,:,cSli) = imfill(J(:,:,cSli), 'holes');    
%         B = bwboundaries(J(:,:,cSli), 8, 'noholes');
%     else
%         B = bwboundaries(J(:,:,cSli));
%     end
%     
	newVertices = [B{1}(:,2), B{1}(:,1)];
% 	
%     % simplify the polygon via Line Simplification
  if subsampling
    newVertices = dpsimplify(newVertices, simplifyTolerance);        
  end
%     
    % number of new vertices to be added
    nNew = size(newVertices, 1);
    P(end+1:end+nNew, :) = newVertices;
%     % append the new vertices to the existing polygon matrix
%     if isequal(nSli, 1) % 2D
%        
%     else                % 3D
%         P(end+1:end+nNew, :) = [newVertices, repmat(cSli, nNew, 1)];
%     end
% end

% text output with final number of vertices
disp(['RegionGrowing Ending: Found ' num2str(length(find(J)))...
      ' pixels within the threshold range (' num2str(size(P, 1))...
      ' polygon vertices)!'])
    
    
    
% % 
% % if ~exist('threshold', 'var') || isempty(threshold)
% %     threshold = double((max(input_image(:)) - min(input_image(:)))) * 0.05;
% % end
% % 
% % if ~exist('maximal_distance', 'var') || isempty(maximal_distance)
% %     maximal_distance = Inf;
% % end
% % 
% % if ~exist('region_mean', 'var') || isempty(region_mean)
% %     region_mean = false;
% % end
% % 
% % if ~exist('fill_holes', 'var')
% %     fill_holes = true;
% % end
% % 
% % if isequal(ndims(input_image), 2)
% %     initial_position(3) = 1;
% % elseif isequal(ndims(input_image),1) || ndims(input_image) > 3
% %     error('There are only 2D images and 3D image sets allowed!')
% % end
% % 
% % [nRow, nCol, nSli] = size(input_image);
% % 
% % if initial_position(1) < 1 || initial_position(2) < 1 ||...
% %    initial_position(1) > nRow || initial_position(2) > nCol
% %     error('Initial position out of bounds, please try again!')
% % end
% % 
% % if threshold < 0 || maximal_distance < 0
% %     error('Threshold and maximum distance values must be positive!')
% % end
% % 
% % if ~isempty(which('dpsimplify.m'))
% %     if ~exist('subsampling', 'var')
% %         subsampling = true;
% %     end
% %     simplifyTolerance = 1;
% % else
% %     subsampling = false;
% % end



% % % text output with initial parameters
% % disp(['RegionGrowing Opening: Initial position (' num2str(initial_position(1))...
% %       '|' num2str(initial_position(2)) '|' num2str(initial_position(3)) ') with '...
% %       num2str(region_value) ' as initial pixel value!'])



% add the initial pixel to the queue



