%The function dicom_viewer is a dicom viewer (1 column of windows) that
%include bone segmentation (2 column of windows)
%and bone contours methods (3 column of winndows)
% it is used DICOM_VIEWER of
%Author: Eric Johnston
%email: ejohnst@stanford.edu
%Release: 1.2
%Date: July 31, 2010

% additinally, this function allows to build models from segmented
% bone images in 3 planes. Now is needed to know and implement how to
% compare these three models.


function diocom_viewer
close all
f = figure('Visible','off','Position',[0,0,1700,1000],'MenuBar','none');
movegui(f,'center');
backgroundcolor = [0.35 0.35 0.35]; %Background of figure
set(f,'Name','My_dicom_viewer','Color',backgroundcolor);
colormap('Gray'); %Dealing only with grayscaled images (*.DCM)


uicontrol('Style','PushButton','Position',[1150 600 100 50],'String','Find Directory','CallBack',@lookfordicom);

%uicontrol('Style','PushButton','Position',[1120 70 100 20],'String','Build 3D Axial Model','CallBack',@axial_model);
%uicontrol('Style','PushButton','Position',[1120 40 100 20],'String','Build 3D Sagittal Model','CallBack',@sagittal_model);
%uicontrol('Style','PushButton','Position',[1120 10 100 20],'String','Build 3D Coronal Model','CallBack',@coronal_model);



%uicontrol('Style','PushButton','Position',[1100 170 200 20],'String','Build_axial_model_from_contours','CallBack',@axial_model_from_contours_data);
%uicontrol('Style','PushButton','Position',[1100 140 200 20],'String','Build_axial_model_from_contours','CallBack',@sagittal_model_from_contours_data);
%uicontrol('Style','PushButton','Position',[1100 110 200 20],'String','Build_axial_model_from_contours','CallBack',@coronal_model_from_contours_data);


maintextA = uicontrol('Style','Text','Position', [1 600 20 50] ,'String', 'A', 'FontSize',13,'HorizontalAlignment','left','BackgroundColor',backgroundcolor);
maintextS = uicontrol('Style','Text','Position', [1 200 20 200] ,'String', 'S', 'FontSize',13,'HorizontalAlignment','left','BackgroundColor',backgroundcolor);
maintextC = uicontrol('Style','Text','Position', [1 10 20 180] ,'String', 'C', 'FontSize',13,'HorizontalAlignment','left','BackgroundColor',backgroundcolor);

axtext = uicontrol('Style','Text','Position',[700+520 60 140 25],'String','Axial:','FontSize',13,'HorizontalAlignment','left','BackgroundColor',backgroundcolor);
sagtext = uicontrol('Style','Text','Position',[700+520 35 140 25],'String','Sagittal:','FontSize',13,'HorizontalAlignment','left','BackgroundColor',backgroundcolor);
cortext = uicontrol('Style','Text','Position',[700+520 10 140 25],'String','Coronal:','FontSize',13,'HorizontalAlignment','left','BackgroundColor',backgroundcolor);

axial = axes('Position',[0.02 0.2 0.16 1.2],'DataAspectRatio',[1 1 1],'XTick',[],'YTick',[],'Box','on');
axial_bones = axes('Position',[0.2 0.2 0.16 1.2],'DataAspectRatio',[1 1 1],'XTick',[],'YTick',[],'Box','on');
axial_contour = axes('Position',[0.38 0.2 0.16 1.2],'DataAspectRatio',[1 1 1],'XTick',[],'YTick',[],'Box','on');
%axial_contour_coor = axes('Position',[0.56 0.2 0.16 1.2],'DataAspectRatio',[1 1 1],'XTick',[],'YTick',[],'Box','on');

sagittal = axes('Position',        [0.02 0.17 0.16 0.6],'DataAspectRatio',[1 1 1],'XTick',[],'YTick',[],'Box','on');
sagittal_bones = axes('Position',  [0.2 0.17 0.16 0.6],'DataAspectRatio',[1 1 1],'XTick',[],'YTick',[],'Box','on');
sagittal_contour = axes('Position',[0.38 0.17 0.16 0.6],'DataAspectRatio',[1 1 1],'XTick',[],'YTick',[],'Box','on');
%sagittal_contour_coor = axes('Position',[0.56 0.17 0.16 1.2],'DataAspectRatio',[1 1 1],'XTick',[],'YTick',[],'Box','on');

coronal = axes('Position',[0.02 0.001 0.16 0.3],'DataAspectRatio',[1 1 1],'XTick',[],'YTick',[],'Box','on');
coronal_bones = axes('Position',[0.2 0.001 0.16 0.3],'DataAspectRatio',[1 1 1],'XTick',[],'YTick',[],'Box','on');
coronal_contour = axes('Position',[0.38 0.001 0.16 0.3],'DataAspectRatio',[1 1 1],'XTick',[],'YTick',[],'Box','on');
%coronal_contour_coor = axes('Position',[0.56 0.001 0.16 1.2],'DataAspectRatio',[1 1 1],'XTick',[],'YTick',[],'Box','on');



typestring = ''; %Records when numbered keys are pressed
threedarray = NaN; %The three dimensional array given by the DICOM files
curx=1; cury=1; curz=1; %The cross sections of the current images
[P Q R] = size(threedarray); %Size of the three dimensional array
axvert = NaN; axhorz = NaN; sagvert = NaN; saghorz = NaN; corvert = NaN; corhorz = NaN; %For zooming functionality
x2 = NaN; y2 = NaN; %Current Mouse position when depressed
xthickness = NaN; ythickness = NaN; zthickness = NaN; %For measurement tool

set(f,'Visible','On');

function disp_images(x,y,z)
display_axial(z)
display_axial_bone(z)
select_bone(z)
%display_axial_contour_from_cooridinates(z)

display_sagittal(y)
display_sagittal_bone(y)

%display_sagittal_contour_from_cooridinates(y)

display_coronal(x)
display_coronal_bone(x)

%display_coronal_contour_from_cooridinates(x)


end

    function display_axial(z)
        set(f,'CurrentAxes',axial);
        im = double(squeeze(threedarray(axvert,axhorz,z)));
        im = imadjust(im/max(im(:)),[0 1],[0 1],2*(1-0.5));%(1-get(slide,'Value')));
        imshow(im); axis square;
                
    end %end dispay_axial
    function display_axial_bone(z)
         set(f,'CurrentAxes',axial_bones);
         im = squeeze(threedarray(axvert,axhorz,z));
         im = imadjust(im/max(im(:)),[0 1],[0 1],2*(1-0.5));%(1-get(slide,'Value')));
         bone_axial = find_bone(im);
         imshow(bone_axial); axis square;
                  
    end %end display_axial_bone

    function select_bone(z)
    
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
        
    end
    end

    function display_axial_contour(z)
        set(f,'CurrentAxes',axial_contour);
        
        im = squeeze(threedarray(axvert,axhorz,z));
        axial_bw = double(imadjust(im/max(im(:)),[0 1],[0 1],2*(1-0.5)));
        axial_bw_bone = find_bone(axial_bw);
        imcontour(axial_bw_bone,1); axis square;
        
        
    end %end dispay_axial_contour
    function display_axial_contour_from_cooridinates(z)
        set(f,'CurrentAxes',axial_contour_coor);
        
        im = squeeze(threedarray(axvert,axhorz,z));
        axial_bw = double(imadjust(im/max(im(:)),[0 1],[0 1],2*(1-0.5)));
        axial_bw_bone = find_bone(axial_bw);
        c = imcontour(axial_bw_bone,1); axis square;
        x=c(1,:);
        y=c(2,:);
        plot(x,y,'.'); axis square;
        
    end %end dispay_axial_contour
 
    function display_sagittal(y)
        set(f,'CurrentAxes',sagittal);
        im = double(squeeze(threedarray(sagvert,y,saghorz)));
        im = imresize(im, [512 512]);
        im = imadjust(im/max(im(:)),[0 1],[0 1],2*(1-0.5));%(1-get(slide,'Value')));
        imshow(im); %axis square;
    end  
    function display_sagittal_bone(y)
        set(f,'CurrentAxes',sagittal_bones);
        im = double(squeeze(threedarray(sagvert,y,saghorz)));
        im = imresize(im, [512 512]);
        im = imadjust(im/max(im(:)),[0 1],[0 1],2*(1-0.5));%(1-get(slide,'Value')));
        bone_sagittal = find_bone(im);
        imshow(bone_sagittal); %axis square;
        
    end  
    function display_sagittal_contour(y)
         set(f,'CurrentAxes',sagittal_contour);
        im = squeeze(threedarray(sagvert,y,saghorz));
        im = double(imadjust(im/max(im(:)),[0 1],[0 1],2*(1-0.5)));%(1-get(slide,'Value')));
        sagittal_bone = find_bone(im);
        imcontour(sagittal_bone,1); axis square;
        
        
    end %end dispay_sagittal_contour
    function display_sagittal_contour_from_cooridinates(y)
        set(f,'CurrentAxes',sagittal_contour_coor);
        im = squeeze(threedarray(sagvert,y,saghorz));
        im = double(imadjust(im/max(im(:)),[0 1],[0 1],2*(1-0.5)));%(1-get(slide,'Value')));
        sagittal_bone = find_bone(im);
        c = imcontour(sagittal_bone,1); axis square;
        x=c(1,:);
        y=c(2,:);
        plot(x,y,'.'); axis square;
        
    end

    function display_coronal(x)
        set(f,'CurrentAxes',coronal);
        im = double(squeeze(threedarray(x, corvert, corhorz)));
        im = imresize(im, [512 512]);
        im = imadjust(im/max(im(:)),[0 1],[0 1],2*(1-0.5));%(1-get(slide,'Value')));
        imshow(im); axis square;
    end  
    function display_coronal_bone(x)
        set(f,'CurrentAxes',coronal_bones);
        im = squeeze(threedarray(x, corvert, corhorz));
        im = imresize(im, [512 512]);
        im = imadjust(im/max(im(:)),[0 1],[0 1],2*(1-0.5));%(1-get(slide,'Value')));
        bone_coronal = find_bone(im);
        imshow(bone_coronal); axis square;
    end  
    function display_coronal_contour(x)
        
        set(f,'CurrentAxes',coronal_contour);
        im = squeeze(threedarray(x, corvert, corhorz));
        im = double(imadjust(im/max(im(:)),[0 1],[0 1],2*(1-0.5)));
        coronal_bone = find_bone(im);
        imcontour(coronal_bone,1); axis square;
        
%       
    end %end_display_coronal_contour
    function display_coronal_contour_from_cooridinates(x)
        set(f,'CurrentAxes',coronal_contour_coor);
        im = squeeze(threedarray(x, corvert, corhorz));
        im = double(imadjust(im/max(im(:)),[0 1],[0 1],2*(1-0.5)));
        coronal_bone = find_bone(im);
        c = imcontour(coronal_bone,1); axis square;
        x=c(1,:);
        y=c(2,:);
        plot(x,y,'.'); axis square;
        
    end



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
    set(sagtext,'String',['Sagittal:' num2str(cury) '/' num2str(Q) ]);
    set(cortext,'String',['Coronal: ' num2str(curx) '/' num2str(P)]);
    disp_images(curx,cury, curz) %dispIm(curx,cury,curz);
    set(f, 'Pointer', 'arrow');
    %set([zoomer measurer maximize contrast slide export],'Enable','on');
    %Press Buttons
    set(f,'KeyPressFcn',@(h_obj,evt) keymove(evt.Key));
    set(f,'WindowScrollWheelFcn',@(h_obj,evt) keymove(evt.VerticalScrollCount));
    
    
    end %end lookfordicom
% function keymove(key)
%     if strcmp(key,'uparrow') || sum(key)==-1 %If the uparrow is pressed or the mouse wheel is turned
%         if (gca == axial && curz<R) %And we're not out of bounds
%             curz = curz+1; display_axial(curz); display_axial_bone(curz); display_axial_contour(curz); display_axial_contour_from_cooridinates(curz); set(f,'CurrentAxes',axial); set(axtext,'String',['Axial: ' num2str(curz) '/' num2str(R)]);
%         elseif (gca == sagittal && cury<P)
%             cury = cury+1; display_sagittal(cury);display_sagittal_bone(cury); display_sagittal_contour(cury); display_sagittal_contour_from_cooridinates(cury); set(f,'CurrentAxes',sagittal); set(sagtext,'String',['Sagittal: ' num2str(cury) '/' num2str(Q)]);
%         elseif (gca == coronal && curx<Q)
%             curx = curx+1; display_coronal(curx); display_coronal_bone(curx); display_coronal_contour(curx); display_coronal_contour_from_cooridinates(curx); set(f,'CurrentAxes',coronal); set(cortext,'String',['Coronal: ' num2str(curx) '/' num2str(P)]);
%         end
%     elseif strcmp(key,'downarrow') || sum(key)==1 %If the down arrow or mouse wheel is turned
%         if (gca == axial && curz>1) %And we're not out of bounds
%             curz = curz-1; display_axial(curz); display_axial_bone(curz); display_axial_contour(curz); set(f,'CurrentAxes',axial); display_axial_contour_from_cooridinates(curz); set(axtext,'String',['Axial: ' num2str(curz) '/' num2str(R)]);
%         elseif (gca == sagittal && cury>1)
%             cury = cury-1; display_sagittal(cury); display_sagittal_bone(cury);display_sagittal_contour(cury);  display_sagittal_contour_from_cooridinates(cury); set(f,'CurrentAxes',sagittal); set(sagtext,'String',['Sagittal: ' num2str(cury) '/' num2str(Q)]);
%          elseif (gca == coronal && curx>1)
%              curx = curx-1; display_coronal(curx);display_coronal_bone(curx); display_coronal_contour(curx); display_coronal_contour_from_cooridinates(curx); set(f,'CurrentAxes',coronal); set(cortext,'String',['Coronal: ' num2str(curx) '/' num2str(P)]);
%         end
%     elseif sum(strcmp(key,{'1','2','3','4','5','6','7','8','9','0'})) && length(typestring)<4 %If a numbered key is pressed and not too 
%         typestring = strcat(typestring,key); %Add the number to the string typed              %many have already been pressed
%         if (gca == axial), set(axtext,'String',['Number of slice in axial plane: ' typestring '/' num2str(R)]);
%           elseif (gca == sagittal), set(sagtext,'String',['Sagittal: ' typestring '/' num2str(Q)]);
%          elseif (gca == coronal), set(cortext,'String',['Coronal: ' typestring '/' num2str(P)]);
%         end
%     elseif strcmp(key,'return') && ~isempty(typestring) %If a return is pressed then update the current cross section
%         if (gca == axial)
%             curz = round(str2double(typestring));
%             if curz>R, curz=R;
%             elseif curz<1, curz=1;   
%             end
%             set(axtext,'String',['Axial: ' num2str(curz) '/' num2str(R)]);
%             display_axial(curz);
%         elseif (gca == sagittal)
%             cury = round(str2double(typestring));
%             if cury>P, cury=P;
%             elseif cury<1, cury=1;   
%             end
%             set(sagtext,'String',['Sagittal: ' num2str(cury) '/' num2str(Q)]);
%             display_sagittal(cury);
%         elseif (gca == coronal)
%             curx = round(str2double(typestring));
%             if curx>Q, curx=Q;
%             elseif curx<1, curx=1;   
%             end
%             set(cortext,'String',['Coronal: ' num2str(curx) '/' num2str(P)]);
%             display_coronal(curx);
%         end
%         typestring = '';
%     else %If the wrong key was pressed act is if no button had ever been pressed
%         typestring = '';
%         if (gca == axial), set(axtext,'String',['Axial: ' num2str(curz) '/' num2str(R)]);
%           elseif (gca == sagittal), set(sagtext,'String',['Sagittal: ' num2str(cury) '/' num2str(Q)]);
%          elseif (gca == coronal), set(cortext,'String',['Coronal: ' num2str(curx) '/' num2str(P)]);
%         end
%     end
% end

function keymove(key)
    if strcmp(key,'uparrow') || sum(key)==-1 %If the uparrow is pressed or the mouse wheel is turned
        if (gca == axial && curz<R) %And we're not out of bounds
            curz = curz+1; display_axial(curz); display_axial_bone(curz); select_bone(curz); set(f,'CurrentAxes',axial); set(axtext,'String',['Axial: ' num2str(curz) '/' num2str(R)]);
        elseif (gca == sagittal && cury<P)
            cury = cury+1; display_sagittal(cury);display_sagittal_bone(cury);  set(f,'CurrentAxes',sagittal); set(sagtext,'String',['Sagittal: ' num2str(cury) '/' num2str(Q)]);
        elseif (gca == coronal && curx<Q)
            curx = curx+1; display_coronal(curx); display_coronal_bone(curx);  set(f,'CurrentAxes',coronal); set(cortext,'String',['Coronal: ' num2str(curx) '/' num2str(P)]);
        end
    elseif strcmp(key,'downarrow') || sum(key)==1 %If the down arrow or mouse wheel is turned
        if (gca == axial && curz>1) %And we're not out of bounds
            curz = curz-1; display_axial(curz); display_axial_bone(curz); select_bone(curz); set(f,'CurrentAxes',axial); set(axtext,'String',['Axial: ' num2str(curz) '/' num2str(R)]);
        elseif (gca == sagittal && cury>1)
            cury = cury-1; display_sagittal(cury);display_sagittal_bone(cury);  set(f,'CurrentAxes',sagittal); set(sagtext,'String',['Sagittal: ' num2str(cury) '/' num2str(Q)]);
        elseif (gca == coronal && curx>1)
            curx = curx-1; display_coronal(curx); display_coronal_bone(curx);  set(f,'CurrentAxes',coronal); set(cortext,'String',['Coronal: ' num2str(curx) '/' num2str(P)]);
        end
    elseif sum(strcmp(key,{'1','2','3','4','5','6','7','8','9','0'})) && length(typestring)<4 %If a numbered key is pressed and not too 
        typestring = strcat(typestring,key); %Add the number to the string typed              %many have already been pressed
        if (gca == axial), set(axtext,'String',['Axial: ' typestring '/' num2str(R)]);
        elseif (gca == sagittal), set(sagtext,'String',['Sagittal: ' typestring '/' num2str(Q)]);
        elseif (gca == coronal), set(cortext,'String',['Coronal: ' typestring '/' num2str(P)]);
        end
    elseif strcmp(key,'return') && ~isempty(typestring) %If a return is pressed then update the current cross section
        if (gca == axial)
            curz = round(str2double(typestring));
            if curz>R, curz=R;
            elseif curz<1, curz=1;   
            end
            set(axtext,'String',['Axial: ' num2str(curz) '/' num2str(R)]);
            dispAxial(curz);
        elseif (gca == sagittal)
            cury = round(str2double(typestring));
            if cury>P, cury=P;
            elseif cury<1, cury=1;   
            end
            set(sagtext,'String',['Sagittal: ' num2str(cury) '/' num2str(Q)]);
            dispSagittal(cury);
        elseif (gca == coronal)
            curx = round(str2double(typestring));
            if curx>Q, curx=Q;
            elseif curx<1, curx=1;   
            end
            set(cortext,'String',['Coronal: ' num2str(curx) '/' num2str(P)]);
            dispCoronal(curx);
        end
        typestring = '';
    else %If the wrong key was pressed act is if no button had ever been pressed
        typestring = '';
        if (gca == axial), set(axtext,'String',['Axial: ' num2str(curz) '/' num2str(R)]);
        elseif (gca == sagittal), set(sagtext,'String',['Sagittal: ' num2str(cury) '/' num2str(Q)]);
        elseif (gca == coronal), set(cortext,'String',['Coronal: ' num2str(curx) '/' num2str(P)]);
        end
    end
end

function slide_move(src,eventdata) %#ok<INUSD> %If the slider moves change the label
    set(contrast,'String',round(100*get(slide,'Value'))/100);
    dispIm(curx,cury,curz); %Update all images
end

function exportfigure(src,eventdata) %#ok<INUSD>
    if (gca==axial)
        figure('Position',[552 86 676 598],'Visible','off'); movegui(gcf,'center'); set(gcf,'Visible','on');
        set(gca,'DataAspectRatio',[1 1 1],'Position',[0.1212 0.0936 0.7574 0.8562],'XTick',[],'YTick',[],'Box','on');
        im = double(squeeze(threedarray(axvert,axhorz,curz)));
        im = imadjust(im/max(im(:)),[0 1],[0 1],2*(1-get(slide,'Value')));
        imshow(im); axis square;
    elseif (gca==sagittal)
        figure('Position',[552 86 676 598],'Visible','off'); movegui(gcf,'center'); set(gcf,'Visible','on');
        set(gca,'DataAspectRatio',[1 1 1],'Position',[0.1212 0.0936 0.7574 0.8562],'XTick',[],'YTick',[],'Box','on');
        im = double(squeeze(threedarray(sagvert,cury,saghorz)));
        im = imadjust(im.'/max(im(:)),[0 1],[0 1],2*(1-get(slide,'Value')));
        imshow(im); axis square;
    elseif (gca==coronal)
        figure('Position',[552 86 676 598],'Visible','off'); movegui(gcf,'center'); set(gcf,'Visible','on');
        set(gca,'DataAspectRatio',[1 1 1],'Position',[0.1212 0.0936 0.7574 0.8562],'XTick',[],'YTick',[],'Box','on');
        im = double(squeeze(threedarray(curx,corvert,corhorz)));
        im = imadjust(im.'/max(im(:)),[0 1],[0 1],2*(1-get(slide,'Value')));
        imshow(im); axis square;
    end
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
[level em] = graythresh(current_image);
level=0.57;
%bone = im2bw(current_image,level);
[thres, bone] = multithresholding(current_image,2);
end
function bone = find_bone2(current_image)
[level em] = graythresh(current_image);
level=0.67;
bone = im2bw(current_image,level);
end

%multithreshold 
    function bone = find_bone_with_multithresholding(current_image)
    
        [thres, thresholded_dicom_layer] = multithresholding(current_image,2);

    end






%------------------build_models_from_threedaraay_in slices----------

function axial_model(src,eventdata)
    folder = 'C:\Users\Aleksandra\Desktop\W11\image_proc_proof\01_082013\foot';
    [threedarray xthickness ythickness zthickness] = gatherImages(folder);
    
    [p q r] = size(threedarray);
    result_model = zeros(p,q,r);
    
    distance = zthickness
    figure
    for i=1:r
    im = double(squeeze(threedarray(:,:,i)));
    im = imadjust(im/max(im(:)),[0 1],[0 1],2*(1-0.5));
    im_bone = find_bone2(im);
    dist=distance*i;
    plot_reconstruction(im_bone,dist)
    result_model(:,:,i) = im_bone;
    end
    %zapisa? result_model
    savefile = 'result_model_bones_ola_from_axial.mat';
    save(savefile, 'result_model','-v7');    
      
   
end
function axial_model_from_contours_data(src,eventdata)
    folder = 'C:\Users\Aleksandra\Desktop\W11\image_proc_proof\01_082013\foot';
    [threedarray xthickness ythickness zthickness] = gatherImages(folder);
    
    [p q r] = size(threedarray);
    result_model = zeros(p,q,r);
    
    distance = zthickness
    figure
    for i=1:r
    im = double(squeeze(threedarray(:,:,i)));
    im = imadjust(im/max(im(:)),[0 1],[0 1],2*(1-0.5));
    im_bone = find_bone2(im);
    c = imcontour(im_bone,1);
    x=c(1,:);
    y=c(2,:);
    dist=distance*i;
    plot_reconstruction_from_contours(x,y,dist)
    %result_model(:,:,i) = im_bone;
    end
    %zapisa? result_model
    %savefile = 'result_model_bones_ola_from_axial_contours.mat';
    %save(savefile, 'result_model','-v7');    
      
   
end

function sagittal_model(src,eventdata)
    folder = 'C:\Users\Aleksandra\Desktop\W11\image_proc_proof\01_082013\foot';
    [threedarray xthickness ythickness zthickness] = gatherImages(folder);
    
    [p q r] = size(threedarray);
    result_model = zeros(p,q,r);
    
    distance = ythickness
    figure
    for i=1:q
    im = double(squeeze(threedarray(:,i,:)));
    im = imadjust(im/max(im(:)),[0 1],[0 1],2*(1-0.5));
    im_bone = find_bone2(im);
    dist=distance*i;
    plot_reconstruction(im_bone,dist)
    result_model(:,i,:) = im_bone;
    end
    %zapisa? result_model
    %savefile = 'result_model_bones_ola_from_sagittal.mat';
    %save(savefile, 'result_model','-v7');
      
   
end
function sagittal_model_from_contours_data(src,eventdata)
    folder = 'C:\Users\Aleksandra\Desktop\W11\image_proc_proof\01_082013\foot';
    [threedarray xthickness ythickness zthickness] = gatherImages(folder);
    
    [p q r] = size(threedarray);
    result_model = zeros(p,q,r);
    
    distance = ythickness
    figure
    for i=1:q
    im = double(squeeze(threedarray(:,i,:)));
    im = imadjust(im/max(im(:)),[0 1],[0 1],2*(1-0.5));
    im_bone = find_bone2(im);
    dist=distance*i;
    plot_reconstruction_from_contours(x,y,dist)
    result_model(:,:,i) = im_bone;
    end
    %zapisa? result_model
    %savefile = 'result_model_bones_ola_from_axial_contours.mat';
    %save(savefile, 'result_model','-v7');    
      
   
end

function coronal_model(src,eventdata)
    folder = 'C:\Users\Aleksandra\Desktop\W11\image_proc_proof\01_082013\foot';
    [threedarray xthickness ythickness zthickness] = gatherImages(folder);
    
    [p q r] = size(threedarray);
    result_model = zeros(p,q,r);
    
    distance = xthickness
    figure
    for i=1:p
    im = double(squeeze(threedarray(i,:,:)));
    im = imadjust(im/max(im(:)),[0 1],[0 1],2*(1-0.5));
    im_bone = find_bone2(im);
    dist=distance*i;
    c = imcontour(im_bone,1);
    x=c(1,:);
    y=c(2,:);
    plot_reconstruction(im_bone,dist)
    result_model(i,:,:) = im_bone;
    end
    %zapisa? result_model
    %savefile = 'result_model_bones_ola_from_coronal.mat';
    %save(savefile, 'result_model','-v7');
      
   
end
function coronal_model_from_contours_data(src,eventdata)
    folder = 'C:\Users\Aleksandra\Desktop\W11\image_proc_proof\01_082013\foot';
    [threedarray xthickness ythickness zthickness] = gatherImages(folder);
    
    [p q r] = size(threedarray);
    result_model = zeros(p,q,r);
    
    distance = xthickness
    figure
    for i=1:p
    im = double(squeeze(threedarray(i,:,:)));
    im = imadjust(im/max(im(:)),[0 1],[0 1],2*(1-0.5));
    im_bone = find_bone2(im);
    dist=distance*i;
    c = imcontour(im_bone,1);
    x=c(1,:);
    y=c(2,:);
    plot_reconstruction_from_contours(x,y,dist)
    result_model(i,:,:) = im_bone;
    end
    %zapisa? result_model
    %savefile = 'result_model_bones_ola_from_axial_contours.mat';
    %save(savefile, 'result_model','-v7');    
      
   
end
%------------------------------------------------------------------


function plot_reconstruction(image,dist)
        pixels = getcoord(1,image);
        [m n]= size(pixels);
     
    if (m ==0)  && (n==0)
    
        else
    x=pixels(:,1);
    y=pixels(:,2);
    z=ones(m,1)*dist;
   
    hold on
    plot3(x,y,z,'.')
    end
    
end
function plot_reconstruction_from_contours(x,y,dist)
    m = length(x);
    z=ones(m,1)*dist;
    hold on 
    plot3(x,y,z,'.')
    
end


function out = getcoord(coordval,matrix,varargin)
% GETCOORD Get coordinates
%   getcoord(COORDVAL,MATRIX) finds the value inside a matrix containing
%   it.  Imput first the value, then the matrix, and the output will be in
%   the form of a vector [r c] with r being the row of the value and c
%   being the column.
%
%   getcoord(COORDVAL,MATRIX,RANGEROW,RANGECOL) where rangerow and rangecol
%   are increasing vector of integers less than or equal to the dimension
%   of the matrix finds the coordinates in the specified area.
if size(varargin,2) == 2    %Set optional variables
    rangeRow = varargin{1}; %Only specific rows and columns will be searched
    rangeCol = varargin{2};
elseif size(varargin,2) == 0
    rangeRow = 1:size(matrix,1);    %The entire matrix will be searched
    rangeCol = 1:size(matrix,2);
else
    disp('Incorrect number of input arguments');    %Error message for wrong number of inputs
end

out = [];
for i = rangeRow    %For the range of rows...
    for j = rangeCol    %For the range of columns...
        if matrix(i,j) == coordval  %If the value is found... 
            out = [out;i,j];        %Save it.
        end
    end
end

if size(out,1) < 1
    disp('Value not found in matrix')   %Error message if value is not in matrix
end
    
    end
function s = get_contour(c)

    sz = size(c,2);     % Size of the contour matrix c
    ii = 1;             % Index to keep track of current location
    jj = 1;             % Counter to keep track of # of contour lines

    while ii < sz       % While we haven't exhausted the array
        n = c(2,ii);    % How many points in this contour?
        s(jj).v = c(1,ii);        % Value of the contour
        s(jj).x = c(1,ii+1:ii+n); % X coordinates
        s(jj).y = c(2,ii+1:ii+n); % Y coordinates
        ii = ii + n + 1;          % Skip ahead to next contour line
        jj = jj + 1;              % Increment number of contours
    end

end      




end %end dicom viewer
