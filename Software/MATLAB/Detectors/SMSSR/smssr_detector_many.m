% smssr_detector_many.m- script for applying the SMSSR detector on many images
%**************************************************************************
%
% author: Elena Ranguelova, NLeSc
% date created: 30 June 2015
% last modification date: 
% modification details: 
%**************************************************************************
% NOTES: if masked image is to be processed use the mask from separate file!!
%**************************************************************************
% EXAMPLES USAGE:
% simply type
%
% smssr_detector_many
%
% and follow questions.
%%
%**************************************************************************
clc; 
disp('-------------------------------------------------------------------------');
disp('    Smart Morphology-based Stable Salient Regions (SMSSR) Detection      ');
disp('-------------------------------------------------------------------------');
disp('                                                                         ');

%% parameters
interactive = false;
verbose = false;
visualise_major = false;
visualise_minor = false;
execution_params = [verbose visualise_major visualise_minor];

preproc_types = [0 0];
%saliency_types = [1 1 0 0];
SE_size_factor = 0.05;
SE_size_factor_preproc = 0.002;
Area_factor = 0.25;
num_levels = 20;
thresh_type = 'h';
saliency_thresh = 0.75;
region_params = [SE_size_factor Area_factor saliency_thresh];

 
% saliency type
sal = input('Default saliency types [holes-Yes islands-Yes indent.-Yes protr.-Yes]? Y/N: ','s');

if (lower(sal)=='n')
     hol = input('Holes (Isolated dark on bright BG)? Y/N: ','s');
     if (lower(hol) == 'n')
         holes = 0;
     else
         holes = 1;
     end
     isl = input('Islands (Isolated bright on dark BG)? Y/N: ','s');
     if (lower(isl) == 'n')
         islands = 0;
     else
         islands = 1;
     end
     ind = input('Indentations (Border dark on bright BG)? Y/N: ','s');
     if (lower(ind) == 'n')
         indentations = 0;
     else
         indentations = 1;
     end
     pro = input('Protrusions (Border bright on dark BG)? Y/N: ','s');
     if (lower(pro) == 'n')
         protrusions = 0;
     else
         protrusions = 1;
     end               
 end

saliency_types = [holes islands indentations protrusions];

disp('------------------------------------------------------------------');
disp('                                                                  ');


%% input paths
%input image directory
input_dir = input('Enter the full path to the input image directory: ','s');

fnames_struct = dir([input_dir '*.png']);

if isempty(fnames_struct)
    fnames_struct = dir([input_dir '*.pgm']);    
end
if isempty(fnames_struct)
    fnames_struct = dir([input_dir '*.ppm']);    
end
if isempty(fnames_struct)
    disp('The input directory must contain images in one of these formats: PNG/PPM/PGM!');    
    return;
else
    num_images = length(fnames_struct);
end

for i = 1:num_images
    fnames{i} = fnames_struct(i).name; 
end

% all images?
all = input(['Process all ' num2str(num_images) ' input images [y/n]? '],'s');
if strcmpi(all,'n')
    ind = input('Specify part (P) of images with beginning and end indicies or list (L) [P/L]?: ','s');
    if strcmpi(ind,'p')
        ind_beg = input('Enter the beginning image number: ');  
        ind_end = input('Enter the ending image number: ');
        indicies = ind_beg:ind_end;
    else
        indicies = input('Enter the list of image indicies: ');
    end
else
    indicies = 1:num_images;
end

% output (feature) directory
features_dir = input('Enter the full path to the output features directory: ','s');

%% run for the selected images
for i = indicies
    base_fname = fnames{i};
    image_fname = [input_dir base_fname];
    k = find(base_fname =='.');
    l = k(end);
    if isempty(l)
        features_fname = [features_dir base_fname '.smssr'];
        regions_fname = [features_dir base_fname '_smartregions.mat'];

    else
        features_fname = [features_dir base_fname(1:l-1) '.smssr'];
        regions_fname = [features_dir base_fname(1:l-1) '_smartregions.mat'];
    end
   

    disp([' Processing image index # ' num2str(i) ' out of total ' num2str(length(indicies)) ' images...']);

    %% load the image & convert to gray-scale if  color
    image_data = imread(image_fname);
    if ndims(image_data) > 2
        image_data = rgb2gray(image_data);
    end
    
%     %% load & apply the mask, if any
     ROI = [];
%     if ~isempty(mask_filename)
%         s = load(ROI_mask_fname);
%         s_cell = struct2cell(s);
%         for k = 1:size(s_cell)
%             field = s_cell{k};
%             if islogical(field)
%                 ROI = field;
%             end
%         end
%         if isempty(ROI)
%            error('ROI_mask_fname does not contain binary mask!');
%         end
%     end

    %% SMSSR detector
    tic;
    if find(preproc_types)
        image_data = smssr_preproc(image_data, preproc_types);
    end
    [num_smartregions, features, saliency_masks] = smssr(image_data, ROI, ...
        num_levels, saliency_types, thresh_type, region_params, execution_params);
    toc
    % save the features
    disp('Saving ...');
    smssr_save(features_fname, regions_fname, num_smartregions, features, saliency_masks);

    disp('------------------------------------------------------------------');
    
end







 