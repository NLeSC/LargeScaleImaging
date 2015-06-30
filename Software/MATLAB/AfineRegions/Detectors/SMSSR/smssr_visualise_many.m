% smssr_visualise_many.m- displaying the extracted SMSSR regions on manyimages
%**************************************************************************
%
% author: Elena Ranguelova, NLeSc
% date created: 30 June 2015
% last modification date: 
% modification details: 
%**************************************************************************
% NOTES: for now produces only regions in ellipse output format
%        input directory is assumed to contain ONLY input images
%       fornow the choise for visualization parametersis fixed
%**************************************************************************
% EXAMPLES USAGE:
% simply type
%
% smssr_visualise_many
%
% and follow questions.
%**************************************************************************
clc; 
disp('-------------------------------------------------------------------------');
disp(' Visualisation: Smart Morphology-based Stable Salient Regions (SMSSR)    ');
disp('-------------------------------------------------------------------------');
disp('                                                                         ');

% fixed choice for visualization parameters (see smssr_visualization_one for interactive version)
list_regions =[];
step_list_regions = [];
scaling = 1;
line_width = 1;
labels = 1;
type = 1;
col_ellipse = 'y';
col_label = 'g';
original = 0;

% input image directory
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
all = input(['Show all ' num2str(num_images) ' images [y/n]? '],'s');
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
features_dir = input('Enter the full path to the features (ellipse representation) directory: ','s');

% no masks for now
ROI_mask_fname = [];

% visualise the selected images
for i = indicies
    base_fname = fnames{i};
        image_fname = [input_dir base_fname];
        k = find(base_fname =='.');
        l = k(end);
        if isempty(l)
            features_fname = [features_dir base_fname '.mser'];
        else
            features_fname = [features_dir base_fname(1:l-1) '.mser'];
        end
   

    disp([' Visualising image index # ' num2str(i) ' out of total ' num2str(length(indicies)) ' images...']);

    % Show one image    
    display_smart_regions(image_fname, features_fname, ROI_mask_fname, ...
                  regions_fname,type, ...
                  list_regions, step_list_regions, ...
                  scaling, labels, col_ellipse, ...
                  line_width, col_label, original);

    disp('------------------------------------------------------------------');
    
end
    disp('--------------- The End ---------------------------------');


