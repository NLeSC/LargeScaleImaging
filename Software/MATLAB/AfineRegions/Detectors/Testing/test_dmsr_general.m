% test_dmsr_general.m- script to test the DMSR detector on general images
%**************************************************************************
% author: Elena Ranguelova, NLeSc
% date created: 01-10-2015
% last modification date: cl
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

save_flag = 1;
vis_flag = 1;

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
    else
        test_images = {'leuven'};
    end
    mask_filename =[];
    
end

%% run for all test cases
for test_image = test_images
    [image_filenames, features_filenames, regions_filenames] = ...
        get_test_filenames(test_image, 'dmsr', data_path, results_path);
    
    disp('**************************** Testing DMSR detector *****************');
    %% find out the number of test files
    len = length(image_filenames);
    
    %% loop over all test images
    for i = 1:len
       % for i = 1
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
        
        if interactive
           %             SE_size_factor = input('Enter the Structuring Element size factor: ');
            %             Area_factor = input('Enter the Connected Component size factor (processing): ');
            %             num_levels = input('Enter the number of gray-levels: ');
        else
            
            SE_size_factor = 0.02;
            Area_factor_very_large = 0.01;
            Area_factor_large = 0.001;
            lambda_factor = 3;
            num_levels = 255;
            pref_offset = 80;
            conn = 8;
            weight_all = 0.33;
            weight_large = 0.33;
            weight_very_large = 0.33;
            verbose = 0;
            visualize = 0;
            
        end
        
    
        tic;
        disp('Test case: ');disp(test_image);
        disp('DMSR');
        
        morphology_parameters = [SE_size_factor Area_factor_very_large ...
            Area_factor_large lambda_factor conn];
        weights = [weight_all weight_large weight_very_large];
        execution_flags = [verbose visualize];
        
        [binary_image, otsu, num_cc, thresh] = max_conncomp_thresholding(image_data, ...
                               num_levels, pref_offset, ...
                               morphology_parameters, weights, ... 
                               execution_flags);
                           
        if vis_flag
            figure('Position',get(0,'ScreenSize'));
            
            subplot(221); imshow(image_data_or); title('Original image'); axis on, grid on;
            subplot(222);imshow(image_data); title('Gray-scale image'); axis on, grid on;
            
            subplot(223); plot(1:num_levels, num_cc, 'b');
            title('Normalized number of Connected Components');
            hold on; line('XData',[thresh thresh], ...
                'YData', [0 1.2], 'Color', 'r');
            hold on; line('XData',[otsu otsu], ...
                'YData', [0 1.2], 'Color', 'b');
            
            hold off;axis on; grid on;
            
            subplot(224); imshow(binary_image); axis on;grid on;
            title(['Binarized image at level ' num2str(thresh)]);
        end
                           
%         execution_params = [verbose visualize_major visualize_minor];
%         region_params = [SE_size_factor Area_factor];
%         if find(preproc_types)
%             image_data = smssr_preproc(image_data, preproc_types);
%         end
%         [num_smartregions, features, saliency_masks] = smssr(image_data, ROI, ...
%             num_levels, steps, saliency_thresh, saliency_types, thresh_type, region_params, execution_params);
%         
%         toc
%         % save the features
%         disp('Saving ...');
%         smssr_save(char(features_filenames{i}), char(regions_filenames{i}), num_smartregions, features, saliency_masks);
%         
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
%             display_smart_regions(char(image_filenames{i}), char(features_filenames{i}), mask_filename, ...
%                 char(regions_filenames{i}), type, ...
%                 list_smartregions, step_list_regions, scaling, labels, col_ellipse, ...
%                 line_width, col_label, original);
%         end
    end
    close all
end
disp('--------------- The End ---------------------------------');