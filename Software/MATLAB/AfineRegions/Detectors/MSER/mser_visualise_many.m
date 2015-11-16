% mser_visualise_many.m- displaying the extracted MSER detector on many images
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
% mser_visualise_many
%
% and follow questions.
%**************************************************************************
clc; 
disp('------------------------------------------------------------------');
disp('      Visualisation: Maximally Stable Extremal Regions (MSER)     ');
disp('------------------------------------------------------------------');
disp('                                                                  ');

% fixed choice for visualization parameters (see mser_visualizatio_one for interactive version)
list_regions =[];
step_list_regions = 1;
scaling = 1;
line_width = 1;
labels = 0;
col_ellipse = 'y';
col_label = 'g';

% input image directory
%input_dir = input('Enter the full path to the input image directory: ','s');
input_dir = '/home/elena/eStep/LargeScaleImaging/Data/CombinedGenerated/04_freiburg_innenstadt/PNG/'
features_dir = '/home/elena/eStep/LargeScaleImaging/Results/CombinedGenerated/04_freiburg_innenstadt/';

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
%all = input(['Show all ' num2str(num_images) ' images [y/n]? '],'s');
all = 'y';
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
%features_dir = input('Enter the full path to the features (ellipse representation) directory: ','s');

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
    display_features_mser(image_fname, features_fname, [],[],0, ...
        list_regions, step_list_regions, scaling, labels, ...
        col_ellipse, line_width, col_label, 0);

    disp('------------------------------------------------------------------');
    
end
    disp('--------------- The End ---------------------------------');


