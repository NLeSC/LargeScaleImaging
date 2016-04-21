% test_max_conncomp_thresholding.m- testing the data-driven binarization 
%**************************************************************************
% author: Elena Ranguelova, NLeSc
% date created: 21-04-2016
% last modification date:
% modification details:
%**************************************************************************
%% paramaters
verbose = false;
visualize = true;

batch_structural = false;


%% parameters
SE_size_factor = 0.02;
Area_factor_very_large = 0.01;
Area_factor_large = 0.001;
lambda_factor = 3;
num_levels = 255;
offset = 80;
otsu_only = false;
conn = 8;
weight_all = 0.33;
weight_large = 0.33;
weight_very_large = 0.33;


detector = 'DMSR';
save_flag = 0;
vis_flag = 1;

%% image filename
if ispc
    starting_path = fullfile('C:','Projects');
else
    starting_path = fullfile(filesep,'home','elena');
end
project_path = fullfile(starting_path, 'eStep','LargeScaleImaging');
data_path = fullfile(project_path, 'TestData');
results_path = fullfile(project_path, 'Results', 'AffineRegions');


if batch_structural
    switch batch
        
    end
else
    test_images = {'Gray'};
end

mask_filename =[];

disp('**************************** Testing data-driven binaization *****************');
%% run for all test cases
for test_image = test_images
    data_path_full = fullfile(data_path, char(test_image));
    results_path_full = fullfile(results_path, char(test_image));
    [image_filenames, features_filenames, regions_filenames] = ...
        get_filenames_path(detector, data_path_full, results_path_full);
    disp('Test case: ');disp(test_image);
    %% find out the number of test files
    len = length(image_filenames);
    
    %% loop over all test images
    %for i = 1:len
    for i = 1
        disp('Test image #: ');disp(i);
        disp(image_filenames{i});
        %% load the image & convert to gray-scale if  color
        image_data_or = imread(char(image_filenames{i}));
        if ndims(image_data_or) > 2
            image_data = rgb2gray(image_data_or);
        else
            image_data = image_data_or;
        end
        
        %% load the mask, if any
        ROI = [];
        if ~isempty(mask_filename)
            s = load(ROI_mask_fname);
            s_cell = struct2cell(s);
            for k = 1:size(s_cell)
                field = s_cell{k};
                if islogical(field)
                    ROI = field;
                end
            end
            if isempty(ROI)
                error('ROI_mask_fname does not contain binary mask!');
            end
        end
        
        %% run the binarization
        
        tic;
        
        morphology_parameters = [SE_size_factor Area_factor_very_large ...
            Area_factor_large lambda_factor conn];
        weights = [weight_all weight_large weight_very_large];
        execution_flags = [verbose visualize];
        
        [binary_image, otsu, num_combined_cc, thresh] = max_conncomp_thresholding(image_data, ...
            num_levels, offset, otsu_only, ...
            morphology_parameters, weights, ...
            execution_flags);
        
        toc
    end
    disp('****************************************************************');
    if batch_structural
        close all
    end
end
disp('--------------- The End ---------------------------------');