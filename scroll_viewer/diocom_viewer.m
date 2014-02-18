


function diocom_viewer
close all
f = figure('Visible','off','Position',[0,0,1700,1000],'MenuBar','none');
movegui(f,'center');
backgroundcolor = [0.35 0.35 0.35]; %Background of figure
set(f,'Name','My_dicom_viewer','Color',backgroundcolor);
colormap('Gray'); %Dealing only with grayscaled images (*.DCM)


uicontrol('Style','PushButton','Position',[1010 10 100 50],'String','Find Directory','CallBack',@lookfordicom);
uicontrol('Style','PushButton','Position',[1010 90 100 50],'String','Select Bone','CallBack',@select_bone);


axial = axes('Position',[0.3 0.1 0.26 1.2],'DataAspectRatio',[1 1 1],'XTick',[],'YTick',[],'Box','on');
axtext = uicontrol('Style','Text','Position',[700+520 60 140 25],'String','Axial:','FontSize',13,'HorizontalAlignment','left','BackgroundColor',backgroundcolor);

typestring = ''; %Records when numbered keys are pressed
threedarray = NaN; %The three dimensional array given by the DICOM files
curx=1; cury=1; curz=1; %The cross sections of the current images
[P Q R] = size(threedarray); %Size of the three dimensional array
axvert = NaN; axhorz = NaN; sagvert = NaN; saghorz = NaN; corvert = NaN; corhorz = NaN; %For zooming functionality
x2 = NaN; y2 = NaN; %Current Mouse position when depressed
xthickness = NaN; ythickness = NaN; zthickness = NaN; %For measurement tool
global himage;
global thresholded_dicom_layer;
global bone_contours;
set(f,'Visible','On');



function disp_images(x,y,z)
display_axial(z)

end

    function display_axial(z)
        set(f,'CurrentAxes',axial);
        im = double(squeeze(threedarray(axvert,axhorz,z)));
        im = imadjust(im/max(im(:)),[0 1],[0 1],2*(1-0.5));%(1-get(slide,'Value')));
        [thres, thresholded_dicom_layer] = multithresholding(im,3);
        himage = imshow(thresholded_dicom_layer); axis square;
                
end %end dispay_axial





  function lookfordicom(src, eventdata)
         try
        %folder = uigetdir;
        folder = 'C:\Users\Aleksandra\Desktop\W11\image_proc_proof\01_082013\foot';
        w = cd; cd(folder);
        
    catch %#ok<CTCH>
       return 
    end
    set(f, 'Pointer', 'watch'); pause(0.01);
    threedarray = NaN;
    try
        [threedarray xthickness ythickness zthickness] = gatherImages(folder);
    catch %#ok<CTCH>
        disp('You selected a folder that does not contain .dcm images');
        threedarray = NaN; xthickness = NaN; ythickness = NaN; zthickness = NaN;
        set(f, 'Pointer', 'arrow','KeyPressFcn','','WindowScrollWheelFcn','');
        %set([zoomer measurer maximize contrast slide],'Enable','off');
        cd(w);
        return
    end
    cd(w);
    
    [P Q R] = size(threedarray);
    axvert = 1:P; sagvert = 1:P; corvert = 1:Q;
    axhorz = 1:Q; saghorz = 1:R; corhorz = 1:R;
    curx = ceil(P/2); 
    cury = ceil(Q/2); 
    curz = ceil(R/2);
    set(axtext,'String',['Axial: ' num2str(curz) '/' num2str(R)]);
    disp_images(curx,cury, curz)
    set(f, 'Pointer', 'arrow');
    %set([zoomer measurer maximize contrast slide export],'Enable','on');
    %Press Buttons
    set(f,'KeyPressFcn',@(h_obj,evt) keymove(evt.Key));
    set(f,'WindowScrollWheelFcn',@(h_obj,evt) keymove(evt.VerticalScrollCount));
    
end %end lookfordicom


function keymove(key)
    if strcmp(key,'uparrow') || sum(key)==-1 %If the uparrow is pressed or the mouse wheel is turned
        if (gca == axial && curz<R) %And we're not out of bounds
            curz = curz+1; display_axial(curz); set(f,'CurrentAxes',axial); set(axtext,'String',['Axial: ' num2str(curz) '/' num2str(R)]);
        end
    elseif strcmp(key,'downarrow') || sum(key)==1 %If the down arrow or mouse wheel is turned
        if (gca == axial && curz>1) %And we're not out of bounds
            curz = curz-1; display_axial(curz); set(f,'CurrentAxes',axial); set(axtext,'String',['Axial: ' num2str(curz) '/' num2str(R)]);
        end
    elseif sum(strcmp(key,{'1','2','3','4','5','6','7','8','9','0'})) && length(typestring)<4 %If a numbered key is pressed and not too 
        typestring = strcat(typestring,key); %Add the number to the string typed              %many have already been pressed
        if (gca == axial), set(axtext,'String',['Axial: ' typestring '/' num2str(R)]);
        end
    elseif strcmp(key,'return') && ~isempty(typestring) %If a return is pressed then update the current cross section
        if (gca == axial)
            curz = round(str2double(typestring));
            if curz>R, curz=R;
            elseif curz<1, curz=1;   
            end
            set(axtext,'String',['Axial: ' num2str(curz) '/' num2str(R)]);
            display_axial(curz);
        end
        typestring = '';
    else %If the wrong key was pressed act is if no button had ever been pressed
        typestring = '';
        if (gca == axial), set(axtext,'String',['Axial: ' num2str(curz) '/' num2str(R)]);
        end
    end
end

function slide_move(src,eventdata) %#ok<INUSD> %If the slider moves change the label
    set(contrast,'String',round(100*get(slide,'Value'))/100);
    disp_images(curx,cury,curz); %Update all images
end


function [threedarray xthickness ythickness zthickness] = gatherImages(folder)
%GATHERIMAGES looks through a folder, gets all DICOM files and assembles
%them into a viewable 3d format.

d = sortDirectory(folder); %Sort in ascending order of instance number
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

end %end gatherImages(folder)

function d = sortDirectory(folder)
%SORTDIRECTORY sorts based on instance number

cd(folder);
d = ls('*.dcm');
m = size(d,1);

[group, element] = dicomlookup('InstanceNumber');
sdata(m) = struct('imagename','','instance',0);

for i = 1:m
    metadata = dicominfo(d(i,:));
    position = metadata.(dicomlookup(group, element));
    sdata(i) = struct('imagename',d(i,:),'instance',position);
end

[unused order] = sort([sdata(:).instance],'ascend');
sorted = sdata(order).';

for i = 1:m
    d(i,:) = sorted(i).imagename;
end

end %end sortDirectory(dir)

function bone = find_bone(current_image)
[thres, thresholded_dicom_layer] = multithresholding(current_image,2);
end


    function select_bone(src, eventdata)
        set(f,'CurrentAxes',axial);
        [x,y,button]=ginput(1)
        if button == 1
            display('wywo?ujesz region growing')
            init_x = round(axes2pix(size(thresholded_dicom_layer, 2), get(himage, 'XData'), x));
            init_y = round(axes2pix(size(thresholded_dicom_layer, 1), get(himage, 'YData'), y));
            init_pos= [init_y, init_x, curz];
            save('init_pos.mat','init_pos')
            bone_contours = regionGrowing(threedarray, [init_y, init_x, curz]);
            save('bone_contours.mat','bone_contours')
        elseif button == 2
            display('podlacz inne funkcje')
        elseif button == 3
            display('podlacz cos')
        end
    end



end %end dicom viewer
