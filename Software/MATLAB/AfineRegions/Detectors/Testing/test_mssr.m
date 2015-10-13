% test_mssr.m- script to test the MSSR detector
%**************************************************************************
% author: Elena Ranguelova, NLeSc
% date created: 15-05-2015
% last modification date: 1-06-2015
% modification details: added saving of the features and displaying them as ellipses
% last modification date: 12-10-2015
% modification details: using the generic open and save regions function
%**********************************************************
%% paramaters
interactive = false;
verbose = false;
visualize = false;
visualize_major = false;
visualize_minor = false;
lisa = false;

batch_structural = true;
batch_textural = false;
 
detector = 'MSSRA';
save_flag = 1;
vis_flag = 1;
vis_only = false;

%% image filename

if ispc 
    starting_path = fullfile('C:','Projects');
elseif lisa
     starting_path = fullfile(filesep, 'home','elenar');
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
            test_images = {'boat'};
        end
    end
    mask_filename =[];
end

%% run for all test cases
for test_image = test_images
    [image_filenames, features_filenames, regions_filenames] = ...
        get_test_filenames(test_image, detector, data_path, results_path);
    disp('**************************** Testing MSSR detector *****************');
    %% find out the number of test files
    len = length(image_filenames);
    
    %% loop over all test images
    for i = 1:len
       % for i =2
        %% load the image & convertto gray-scale if  color
        image_data = imread(char(image_filenames{i}));
        if ndims(image_data) > 2
            image_data = rgb2gray(image_data);
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
        
        %% run the MSSR detector
        
        tic;
        if not(vis_only)
            if interactive
                saliency_types(1) = input('Detect "holes"? [0/1]: ');
                saliency_types(2) = input('Detect "islands"? [0/1]: ');
                saliency_types(3) = input('Detect "indentations"? [0/1]: ');
                saliency_types(4) = input('Detect "protrusions"? [0/1]: ');
                SE_size_factor = input('Enter the Structuring Element size factor: ');
                Area_factor = input('Enter the Connected Component size factor: ');
                num_levels = input('Enter the number of gray-levels: ');
                thresh = input('Enter the region threshold: ');
            else
                saliency_types = [1 1 1 1];
                SE_size_factor = 0.02;
                Area_factor = 0.03;
                num_levels = 20;
                thresh = 0.6;
                thresh_type = 's';
            end
            
            
            disp('Test case: ');disp(test_image);
            
            disp(detector);
            region_params = [SE_size_factor Area_factor thresh];
            execution_params = [verbose visualize_major visualize_minor];
            [num_regions, features, saliency_masks] = mssr(image_data, ROI, ...
                num_levels, saliency_types, thresh_type, region_params, execution_params);
            toc
            
            %% save the features
            disp('Saving ...');
            
            save_regions(detector,char(features_filenames{i}), ...
                char(regions_filenames{i}), num_regions, features, saliency_masks);
        end
        %% visualize
        if vis_flag
            disp(' Displaying... ');
            
            
            type = 1; % distinguish region's types
            
            % open the saved regions
            
            list_regions = [];     % display all regions
            
            scaling = 1;  % no scaling
            line_width = 2; % thickness of the line
            labels = 0; % no region's labels
            
            col_ellipse = [];
            col_label = [];
            
            original = 0; % no original region's outline
            
            display_features(char(image_filenames{i}), detector,...
                char(features_filenames{i}), mask_filename, ...
                char(regions_filenames{i}),...
                type, list_regions, scaling, labels, col_ellipse, ...
                line_width, col_label, original);
            title(detector);
        end
    end
    close all
end
 disp('--------------- The End ---------------------------------');

