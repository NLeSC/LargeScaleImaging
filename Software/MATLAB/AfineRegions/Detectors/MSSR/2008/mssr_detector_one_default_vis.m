% mssr_detector_one_default_vis.m- script for applying MSSR detector on 1
%                                  image with default visualisation
%**************************************************************************
%
% author: Elena Ranguelova, TNO
% date created: 17 Feb 10
% last modification date: 
% modification details: 
%**************************************************************************
% EXAMPLES USAGE:
% simply type
%
% mssr_detector_one_default_vis
%
% and follow questions.
% See also mssr_detector_one
%**************************************************************************
clc; 
disp('------------------------------------------------------------------');
disp('    Morphology-based Stable Salient Regions (MSSR) Detection      ');
disp('------------------------------------------------------------------');
disp('                                                                  ');

% input image and ROI
image_fname = input('Enter the full filename of the input image: ','s');

I_or = imread(image_fname);

% no ROI- always whole image is processed
ROI_mask_fname = [];

% saliency type- all
holes = 1; islands = 1; indentations = 1; protrusions = 1;

saliency_type = [holes islands indentations protrusions];

% execusion flags
verbose = 0;
visualise_major = 0;
visualise_minor = 0;

execution_flags = [verbose visualise_major visualise_minor];

disp(' MSSR...                                                                 ');

% Saliency detector
[num_regions, features, saliency_masks] = mssr(image_fname, ...
                            ROI_mask_fname, saliency_type, execution_flags);
      
disp(' Saving...                                                                 ');

% saving the results
save_flag = 1;

if save_flag
    sav_fnames = 'y';
    if lower(sav_fnames)=='y'
        i = find(image_fname =='.');
        j = i(end);
        if isempty(ROI_mask_fname)
            if isempty(j)
                features_fname = [image_fname '.mssr'];    
                regions_fname = [image_fname '_regions.mat'];    
            else
                features_fname = [image_fname(1:j-1) '.mssr'];
                regions_fname = [image_fname(1:j-1) '_regions.mat'];    
            end          
        end
    end
    
    mssr_save(features_fname, regions_fname, num_regions, features, saliency_masks);
end
    
% display the saved regions
 vis_flag = 1; 

if vis_flag
    % default values
    type = 1; % distinguish region's types
    disp(' Displaying...                                                                 ');
   
    % open the saved regions
    [num_regions, features, saliency_masks] = mssr_open(features_fname, regions_fname, type);
    
    list_regions = [];     % display all regions
   
    scaling = 1;  % no scaling
    line_width = 2; % thickness of the line
    labels = 0; % no region's labels
   
    col_ellipse = [];
    col_label = [];
    
    original = 0; % no original region's outline
    
    display_features(image_fname, features_fname, ROI_mask_fname, ...
                  regions_fname,...  
                  type, list_regions, scaling, labels, col_ellipse, ...
                  line_width, col_label, original);
  title('MSSR');

    disp('--------------- The End ---------------------------------');
end

