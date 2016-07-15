% smssr_visualise_one.m- displaying the extracted SMSSR regions on 1image
%**************************************************************************
%
% author: Elena Ranguelova, NLeSc
% date created: 26 June 2015
% last modification date:  
% modification details: 
%**************************************************************************
% NOTES: if part of image is processed use the separate ROI mask!!
%**************************************************************************
% EXAMPLES USAGE:
% simply type
%
% smssr_visualise_one
%
%and follow questions.
%**************************************************************************
clc; 
disp('-------------------------------------------------------------------------');
disp(' Visualisation: Smart Morphology-based Stable Salient Regions (SMSSR)    ');
disp('-------------------------------------------------------------------------');
disp('                                                                         ');

% input image and ROI
image_fname = input('Enter the full filename of the input image: ','s');

I_or = imread(image_fname);

% display
im_disp = input('Display image? [y/n]: ','s');

if lower(im_disp)=='y'
    f1 = figure; imshow(I_or); title(image_fname, 'Interpreter','none');
end

% ROI
roi = input('Detection was performed for the whole Image (I) or for Region Of Interest (ROI)? [I/R]: ','s');

if lower(roi)=='r'
    ROI_mask_fname = input('Enter the full filename for the ROI mask file: ','s');
else
    ROI_mask_fname = [];
end

        or = input('Show original region outlines? [y/n]: ','s');
        if lower(or)=='y'
            original = 1;
        else
            original = 0;
        end

% read the saved features
    sav_fnames = input('Automatically generate the features filenames (same path as original images is assumed)? [y/n]: ','s');
    if lower(sav_fnames)=='y'
        i = find(image_fname =='.');
        j = i(end);
        if isempty(j)
            features_fname = [image_fname '.smssr'];   
            if original
                regions_fname = [image_fname '_smartregions.mat'];    
            else 
                regions_fname =[];
            end
        else
            features_fname = [image_fname(1:j-1) '.smssr'];
            if original
                regions_fname = [image_fname(1:j-1) '_smartregions.mat'];    
            else 
                regions_fname = [];
            end
        end
    else
    
        features_fname = input('Enter the full filename for the features (ellipse representation): ','s');
        if original
            regions_fname = input('Enter the full filename for the features (regions masks): ','s');
        else
            regions_fname = [];
        end
    end
    
% visualise
typ = input('Distinguish regions saliency type (hole/island/indentaion/protrusion)? [y/n]: ','s');
if lower(typ)=='y'
     type = 1;
else
    type = 0;
end
        
% enter the visualisation parameters
all = input('Display all regions? [y/n]: ','s');
if lower(all)=='y'
    list_regions = [];
    step_list_regions = [];
else
    n_th = input('Display every Nth region? [y/n]: ','s');
    if lower(n_th) == 'n'
        list_regions = input('Enter the list of region numbers as vector: ');
    else
        step_list_regions = input('Enter the Nth region to be shown: ');
    end

end

scale = input('Scale the ellipses? [y/n]: ','s');
if lower(scale)=='y'
    scaling = input('Enter the scaling factor: ');
else
    scaling = 1;
end

line = input('Thick line? [y/n]: ','s');
if lower(line)=='y'
    line_width = input('Enter line thickness: ');
else
    line_width = 1;
end

lab = input('Show region numbers? [y/n]: ','s');
if lower(lab)=='y'
    labels = 1;
else
    labels = 0;
end

if ~type
    col = input('Different colour for each region? [y/n]: ','s');
    if lower(col)=='y'
        col_ellipse = [];
        load list_col_ellipse.mat
        %        col_ellipse = input('Enter the list of colours (one RGB triple per region): ');
        if lower(all)=='y'
            col_ellipse = list_col_ellipse(1:num_regions,:);
        else
            for i=1:length(list_regions)
                col_ellipse = [col_ellipse; list_col_ellipse(list_regions(i),:)];
            end
        end

    else
        col_ellipse = [];
    end
else
    col_ellipse=[];
end
col_label = 'b'; % use black


display_smart_regions(image_fname, features_fname, ROI_mask_fname, ...
    regions_fname,type, ...
    list_regions, step_list_regions, scaling, labels, col_ellipse, ...
    line_width, col_label, original);

disp('--------------- The End ---------------------------------');


