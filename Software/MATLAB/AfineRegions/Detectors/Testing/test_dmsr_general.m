% test_dmsr_general.m- script to test the DMSR detector on general images
%**************************************************************************
% author: Elena Ranguelova, NLeSc
% date created: 01-10-2015
% last modification date: 
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
        test_images = {'boat', 'bikes', 'graffiti', 'leuven' ,'ubc'};
    else
        test_images = {'boat'};
    end
    mask_filename =[];
    
end

%% run for all test cases
for test_image = test_images
    [image_filenames, features_filenames, regions_filenames] = ...
        get_test_filenames(test_image, 'dmsr', data_path, results_path);
    
    disp('**************************** Testing SMSSR detector *****************');
    %% find out the number of test files
    len = length(image_filenames);
    
    %% loop over all test images
    for i = 1:len
        %for i = 2
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
        
        %% run the DMSR detector
        
%         if interactive
%             preproc_types(1) = input('Smooth? [0/1]: ');
%             preproc_types(2) = input('Histogram equialize? [0/1]: ');
%             SE_size_factor_preproc = input('Enter the Structuring Element size factor (preprocessing): ');
%             saliency_types(1) = input('Detect "holes"? [0/1]: ');
%             saliency_types(2) = input('Detect "islands"? [0/1]: ');
%             saliency_types(3) = input('Detect "indentations"? [0/1]: ');
%             saliency_types(4) = input('Detect "protrusions"? [0/1]: ');
%             SE_size_factor = input('Enter the Structuring Element size factor: ');
%             Area_factor = input('Enter the Connected Component size factor (processing): ');
%             num_levels = input('Enter the number of gray-levels: ');
%             thrsh_type = input('Enter the thresholding type (s(ingle) or h(ysteresis)): ');
%             saliency_thresh = input('Enter the region threshold: ');
%             
%         else
%             preproc_types = [0 0];
%             saliency_types = [1 1 0 0];
%             SE_size_factor = 0.02;
%             SE_size_factor_preproc = 0.002;
%             Area_factor = 0.03;
             num_levels = 255;
%             %steps = [2 5 10 15 20 25 30 40 45 50];
%             steps = [1];
%             thresh_type = 's';
%             %saliency_thresh = [0.05 0.15 0.25 0.5 0.75];
%             saliency_thresh = 0.6;
%         end
        
        load('MyColormaps','mycmap'); 
    
        tic;
        disp('Test case: ');disp(test_image);
        disp('DMSR');
        [r,c] =  size(image_data);
        binary_masks = zeros(r,c, num_levels);
        for level = 1:num_levels
            binary = image_data >= level;
            binary_masks(:,:,level) = binary;
        end
       
        for l = 2:255
        d =  xor( binary_masks(:,:,l-1), binary_masks(:,:,l) ) ;
        m(l) = sum(d(:));
        end
       % figure;plot(m); grid on;
        
        offset = 50;
        [max_l, max_ind] = max(m(offset:num_levels - offset));
        thresh = max_ind + offset;
        figure;imshow(binary_masks(:,:,thresh)); grid on;
    
%         acc_mask = integral_masks(binary_masks);
%         
%         figure; imagesc(acc_mask); axis image;axis on;grid on;
%          set(gcf, 'Colormap',mycmap);title('Acc. masks');colorbar('South');
%         figure; imagesc(acc_mask); axis image;axis on;grid on;
%          set(gcf, 'Colormap',gray(256));title('Acc. masks');colorbar('South');
         
        
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
end
disp('--------------- The End ---------------------------------');