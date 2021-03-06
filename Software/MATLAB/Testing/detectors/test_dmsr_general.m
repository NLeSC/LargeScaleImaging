% test_dmsr_general.m- script to test the DMSR detector on general images
%**************************************************************************
% author: Elena Ranguelova, NLeSc
% date created: 01-10-2015
% last modification date: 21-07-2016
% modification details: brought from the git history & adapted
% last modification date: 12-10-2015
% modification details: this version tests the DMSR detector
%**************************************************************************
%% paramaters
interactive = false;
verbose = false;
visualize = true;
visualize_major = false;
visualize_minor = false;

batch_structural = true;
batch_textural = false;

detector = 'DMSR';

save_flag = 1;
vis_flag_exact = 0;
vis_flag_elliptic = 1;
vis_only = false;

%% image filename
if ispc
    starting_path = fullfile('C:','Projects');
else
    starting_path = fullfile(filesep,'home','elena');
end
project_path = fullfile(starting_path, 'eStep','LargeScaleImaging');
data_path = fullfile(project_path, 'Data', 'AffineRegions');
results_path = fullfile(project_path, 'Results', 'AffineRegions');

if interactive
    test_images = input('Enter test case: [bark|bikes|boat|graffiti|leuven|trees|ubc|wall]: ','s');
    mask_filename = input('Enter the mask filename (.mat): ', 's');
else
    if batch_structural
        test_images = {'boat', 'bikes', 'graffiti', 'leuven'};
    else if batch_textural
            test_images = {'bark', 'trees', 'ubc', 'wall'};
        else
            %test_images = {'graffiti'};
            test_images = {'leuven'};
        end
    end
    mask_filename =[];
    
end

%% run for all test cases
for test_image = test_images
    [image_filenames, features_filenames, regions_filenames] = ...
        get_test_filenames(test_image, detector, data_path, results_path);
    
    disp('**************************** Testing DMSR detector *****************');
    %% find out the number of test files
    len = length(image_filenames);
    
    %% loop over all test images    
    for i = 1:len
        %    for i = 1
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
        
        %% run the DMSR detector
        if not(vis_only)
            if interactive
                saliency_types(1) = input('Detect "holes"? [0/1]: ');
                saliency_types(2) = input('Detect "islands"? [0/1]: ');
                saliency_types(3) = input('Detect "indentations"? [0/1]: ');
                saliency_types(4) = input('Detect "protrusions"? [0/1]: ');
                SE_size_factor = input('Enter the Structuring Element size factor: ');
                Area_factor_large = input('Enter the Large Connected Component size factor: ');
                Area_factor_very_large = input('Enter the Very Large Connected Component size factor: ');
                lambda_factor = input('Enter the morphological opening size factor: ');
                conn = input('Enter the connectivity [4|8]: ');
                step_size = input('Enter the gray-level step size');
                offset = input('Enter the offset from Otsu of levels to consider for thresholding: ');
                otsu_only = input('Use Otsu only thresholding (no data-driven binarization?) [true|false]: ');
                weight_all = input('Enter the weight of all CC nubmer (weight_all + weight_large + weight_very_large = 1): ');
                weight_large = input('Enter the weight of large CC number (weight_all + weight_large + weight_very_large = 1): ');
                weight_very_large = input('Enter the weight of very large CC number (weight_all + weight_large + weight_very_large = 1): ');
            else
                %% parameters
                SE_size_factor = 0.02;
                Area_factor_very_large = 0.01;
                Area_factor_large = 0.001;
                lambda_factor = 3;
                step_size = 1;
                offset = 80;
                otsu_only = false;
                conn = 8;
                weight_all = 0.33;
                weight_large = 0.33;
                weight_very_large = 0.33;
                python_test = 0;
                saliency_types = [1 1 0 0];
            end
            
            %% run
            tic;
            disp('Test case: ');disp(test_image);
            disp(detector);
            
            morphology_parameters = [SE_size_factor Area_factor_very_large ...
                Area_factor_large lambda_factor conn];
            weights = [weight_all weight_large weight_very_large];
            execution_flags = [verbose visualize_major visualize_minor];
            
            [num_regions, features, saliency_masks] = dmsr(image_data,ROI,...
                step_size, offset,...
                otsu_only, saliency_types, ...
                morphology_parameters, weights, ...
                execution_flags);
            toc
            % save the features
            if save_flag
                disp('Saving ...');
                save_regions(detector, char(features_filenames{i}), char(regions_filenames{i}), num_regions, features, saliency_masks);
            end
        end
        
        %% visualize
        
        if vis_flag_elliptic
            disp('Displaying elliptic regions... ');
            
            type = 1; % distinguish region's types
            
            list_smartregions = [];     % display all regions
            
            scaling = 1;  % no scaling
            line_width = 2; % thickness of the line
            labels = 0; % no region's labels
            
            col_ellipse = [];
            col_label = [];
            step_list_regions = [];
            
            original = 0; % no original region's outline
            f = figure(i);
            set(gcf, 'Position', get(0, 'Screensize'));
            display_smart_regions(char(image_filenames{i}), detector, ...
                char(features_filenames{i}), mask_filename, ...
                char(regions_filenames{i}), type, ...
                list_smartregions, step_list_regions, scaling, labels, col_ellipse, ...
                line_width, col_label, original, f,[]);
           % pause(1);
        end
        if vis_flag_exact
            disp('Displaying exact regions... ');
            type = 1; % distinguish region's types
             
            f = figure(i);
            set(gcf, 'Position', get(0, 'Screensize'));
            image_data = imread(char(image_filenames{i}));
            [~, ~, saliency_masks] = ...
                open_regions(detector, char(features_filenames{i}), char(regions_filenames{i}), type);
            visualize_regions_overlay(image_data, saliency_masks, saliency_types, f,(122));
            
           % pause(1);
        end
    end
    if batch_structural
        close all
    end
end
disp('--------------- The End ---------------------------------');