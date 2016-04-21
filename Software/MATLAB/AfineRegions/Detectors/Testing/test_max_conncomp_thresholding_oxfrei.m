% test_max_conncomp_thresholding_oxfrei.m- testing the data-driven binarization on Oxfrei dataset
%**************************************************************************
% author: Elena Ranguelova, NLeSc
% date created: 21-04-2016
% last modification date: 
% modification details: 
%**************************************************************************
%% paramaters
interactive = false;
verbose = false;
visualize = false;
visualize_major = false;
visualize_minor = false;
lisa = false;

batch_structural = false;
batch = 2;

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
    saliency_type = [1 1 1 1];
end

if length(find(saliency_type)) > 2
    detector = 'DMSRA';
else
    detector = 'DMSR';
end

save_flag = 0;
vis_flag = 1;
vis_only = true;

%% image filename
if ispc 
    starting_path = fullfile('C:','Projects');
elseif lisa
     starting_path = fullfile(filesep, 'home','elenar');
else
    starting_path = fullfile(filesep,'home','elena');
end
project_path = fullfile(starting_path, 'eStep','LargeScaleImaging');
data_path = fullfile(project_path, 'Data', 'OxFrei');
results_path = fullfile(project_path, 'Results', 'OxFrei');

if interactive
    test_images = input('Enter test case: [01_graffiti|02_freiburg_center|',...
        '\n 03_freiburg_from_munster_crop|04_freiburg_innenstadt|',...
        '\n 05_cool_car|06_freiburg_munster|07_graffiti|',...
        '\n 08_hall| 09_small_palace]: ','s');
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
        test_images = {'05_cool_car'};
    end
end
mask_filename =[];
disp('**************************** Testing binaization *****************');
disp(detector);
% %% run for all test cases
% for test_image = test_images
%     data_path_full = fullfile(data_path, char(test_image),'PNG');
%     results_path_full = fullfile(results_path, char(test_image));
%     [image_filenames, features_filenames, regions_filenames] = ...
%         get_filenames_path(detector, data_path_full, results_path_full);
%      disp('Test case: ');disp(test_image);
%     %% find out the number of test files
%     len = length(image_filenames);
%     
%     %% loop over all test images
%     %for i = 1:len
%          disp('Test image #: ');disp(i);
%     for i = 1
%         %% load the image & convert to gray-scale if  color
%         image_data_or = imread(char(image_filenames{i}));
%         if ndims(image_data_or) > 2
%             image_data = rgb2gray(image_data_or);
%         else
%             image_data = image_data_or;
%         end
%         
%         %% load the mask, if any
%         ROI = [];
%         if ~isempty(mask_filename)
%             s = load(ROI_mask_fname);
%             s_cell = struct2cell(s);
%             for k = 1:size(s_cell)
%                 field = s_cell{k};
%                 if islogical(field)
%                     ROI = field;
%                 end
%             end
%             if isempty(ROI)
%                 error('ROI_mask_fname does not contain binary mask!');
%             end
%         end
%         
%         %% run the DMSR detector
%         if not(vis_only)
%             
%             
%             %% run
%             tic;
%             
%             morphology_parameters = [SE_size_factor Area_factor_very_large ...
%                 Area_factor_large lambda_factor conn];
%             weights = [weight_all weight_large weight_very_large];
%             execution_flags = [verbose visualize_major visualize_minor];
%             
%             [num_regions, features, saliency_masks] = dmsr(image_data,ROI,...
%                 num_levels, offset,...
%                 otsu_only, saliency_type, ...
%                 morphology_parameters, weights, ...
%                 execution_flags);
%             toc
%             % save the features
%             disp('Saving ...');
%             save_regions(detector, char(features_filenames{i}), char(regions_filenames{i}), num_regions, features, saliency_masks);
%         end
%         
%         %% visualize
%         
%         if vis_flag
%             disp('Displaying... ');
%             
%             type = 1; % distinguish region's types
%             
%             list_smartregions = [];     % display all regions
%             
%             scaling = 1;  % no scaling
%             line_width = 2; % thickness of the line
%             labels = 0; % no region's labels
%             
%             col_ellipse = [];
%             col_label = [];
%             step_list_regions = [];
%             
%             original = 0; % no original region's outline
%             
%             display_smart_regions(char(image_filenames{i}), detector, ...
%                 char(features_filenames{i}), mask_filename, ...
%                 char(regions_filenames{i}), type, ...
%                 list_smartregions, step_list_regions, scaling, labels, col_ellipse, ...
%                 line_width, col_label, original);
%         end
%        % if batch_structural
%             %pause(10);
%             %close
%        % end
%     end
%         disp('****************************************************************');
%     if batch_structural
%         close all
%     end
% end
disp('--------------- The End ---------------------------------');