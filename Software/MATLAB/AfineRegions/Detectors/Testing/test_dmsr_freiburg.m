% test_dmsr_freiburg.m- testing the DMSR detector on Freiburg dataset
%**************************************************************************
% author: Elena Ranguelova, NLeSc
% date created: 29-10-2015
% last modification date: 1
% modification details: 
%**************************************************************************
%% paramaters
interactive = false;
verbose = false;
visualize = true;
visualize_major = false;
visualize_minor = false;
lisa = false;

batch_structural = true;

detector = 'DMSR';
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
data_path = fullfile(project_path, 'Data', 'Freiburg');
results_path = fullfile(project_path, 'Results', 'Freiburg');

if interactive
    test_images = input('Enter test case: [01_graffiti|03_freiburg_center|',...
        '\n 04_freiburg_from_munster_crop|05_freiburg_innerstadt|',...
        '\n 09_cool_car|17_freiburg_munster|18_graffiti|',...
        '\n 20_hall2|22_small_palace]: ','s');
    mask_filename = input('Enter the mask filename (.mat): ', 's');
else
    
    if batch_structural
        test_images = {'01_graffiti',...
            '03_freiburg_center',...
            '04_freiburg_from_munster_crop',...
            '05_freiburg_innerstadt',...
            '09_cool_car',...
            '17_freiburg_munster',...
            '18_graffiti',...
            '20_hall2',...
            '22_small_palace'};
        
    else
        test_images = {'03_freiburg_center'};
    end
end
mask_filename =[];
%% run for all test cases
for test_image = test_images
    data_path_full = fullfile(data_path, char(test_image),'PNG');
    results_path_full = fullfile(results_path, char(test_image));
    [image_filenames, features_filenames, regions_filenames] = ...
        get_filenames_path(detector, data_path_full, results_path_full);
    
    disp('**************************** Testing DMSR detector *****************');
    %% find out the number of test files
    len = length(image_filenames);
    
    %% loop over all test images
    for i = 1:len
        %for i = 1
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
                %             SE_size_factor = input('Enter the Structuring Element size factor: ');
                %             Area_factor = input('Enter the Connected Component size factor (processing): ');
                %             num_levels = input('Enter the number of gray-levels: ');
            else
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
                %verbose = 1;
                %visualize_major = 1;
                %visualize_minor = 1;
                saliency_type = [1 1 0 0];
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
                num_levels, offset,...
                otsu_only, saliency_type, ...
                morphology_parameters, weights, ...
                execution_flags);
            toc
            % save the features
            disp('Saving ...');
            save_regions(detector, char(features_filenames{i}), char(regions_filenames{i}), num_regions, features, saliency_masks);
        end
        
        %% visualize
        
        if vis_flag
            disp('Displaying... ');
            
            type = 1; % distinguish region's types
            
            list_smartregions = [];     % display all regions
            
            scaling = 1;  % no scaling
            line_width = 2; % thickness of the line
            labels = 0; % no region's labels
            
            col_ellipse = [];
            col_label = [];
            step_list_regions = [];
            
            original = 0; % no original region's outline
            
            display_smart_regions(char(image_filenames{i}), detector, ...
                char(features_filenames{i}), mask_filename, ...
                char(regions_filenames{i}), type, ...
                list_smartregions, step_list_regions, scaling, labels, col_ellipse, ...
                line_width, col_label, original);
        end
%         if batch_structural
%             close all
%         end
    end
    if batch_structural
        close all
    end
end
disp('--------------- The End ---------------------------------');