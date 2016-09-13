% test_mssr_combined.m- test an MSSR-like detector on the Combined dataset
%**************************************************************************
% author: Elena Ranguelova, NLeSc
% date created: 16-11-2015
% last modification date:
% modification details:
%**********************************************************
%% paramaters
interactive = false;
verbose = false;
visualize = false;
visualize_major = false;
visualize_minor = false;
lisa = false;

batch_structural = true;
batch = 1;

if interactive
    saliency_types(1) = input('Detect "holes"? [0/1]: ');
    saliency_types(2) = input('Detect "islands"? [0/1]: ');
    saliency_types(3) = input('Detect "indentations"? [0/1]: ');
    saliency_types(4) = input('Detect "protrusions"? [0/1]: ');
    SE_size_factor = input('Enter the Structuring Element size factor: ');
    Area_factor = input('Enter the Connected Component size factor: ');
    step_size = input('Enter the gray-level step size');
    thresh = input('Enter the region threshold: ');
else
    saliency_types = [1 1 1 1];
    SE_size_factor = 0.02;
    Area_factor = 0.03;
    step_size = 10;
    thresh = 0.6;
    thresh_type = 's';
end
            
if length(find(saliency_types)) > 2
    detector = 'MSSRA';
else
    detector = 'MSSR';
end
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
data_path = fullfile(project_path, 'Data', 'CombinedGenerated');
results_path = fullfile(project_path, 'Results', 'CombinedGenerated');

if interactive
     test_images = input('Enter test case: [01_graffiti|02_freiburg_center|',...
        '\n 03_freiburg_from_munster_crop|04_freiburg_innenstadt|',...
        '\n 05_cool_car|06_freiburg_munster|07_graffiti|',...
        '\n 08_hall|09_small_palace]: ','s');
  
    mask_filename = input('Enter the mask filename (.mat): ', 's');
else
    
    if batch_structural
        switch batch
           case 1
                test_images = {'01_graffiti',...
                    '02_freiburg_center',...
                    '03_freiburg_from_munster_crop'};
            case 2
                test_images = {'04_freiburg_innenstadt',...
                    '05_cool_car',...
                    '06_freiburg_munster'};
            case 3
                test_images = {'07_graffiti',...
                    '08_hall',...
                    '09_small_palace'};
                
        end
    else
        test_images = {'01_graffiti'};
    end
end
mask_filename =[];
disp('**************************** Testing detector *****************');
disp(detector);
%% run for all test cases
for test_image = test_images
    data_path_full = fullfile(data_path, char(test_image),'PNG');
    results_path_full = fullfile(results_path, char(test_image));
    [image_filenames, features_filenames, regions_filenames] = ...
        get_filenames_path(detector, data_path_full, results_path_full);
    
    disp('Test case: ');disp(test_image);
    
    %% find out the number of test files
    len = length(image_filenames);
    
    %% loop over all test images
    for i = 1:len
        disp('Test image #: ');disp(i);
        % for i =2
        %% load the image & convert to gray-scale if  color
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
            
                       
            region_params = [SE_size_factor Area_factor thresh];
            execution_params = [verbose visualize_major visualize_minor];
            [num_regions, features, saliency_masks] = mssr(image_data, ROI, ...
                step_size, saliency_types, thresh_type, region_params, execution_params);
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
    disp('****************************************************************');
    if batch_structural
        close all
        pause(2);
    end
end
disp('--------------- The End ---------------------------------');

