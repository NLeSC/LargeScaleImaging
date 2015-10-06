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
        test_images = {'boat', 'bikes', 'graffiti', 'leuven'};
    else
        test_images = {'boat'};
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
        %for i = 1
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
             SE_size_factor = 0.02;
%             SE_size_factor_preproc = 0.002;
             Area_factor_very_large = 0.01;
             Area_factor_large = 0.001;
             lambda_factor = 3;
             num_levels = 255;
%             %steps = [2 5 10 15 20 25 30 40 45 50];
%             steps = [1];
%             thresh_type = 's';
%             %saliency_thresh = [0.05 0.15 0.25 0.5 0.75];
%             saliency_thresh = 0.6;
%             pref_offset = 20;
              conn = 8;
              weight_all = 0.33;
              weight_large = 0.33;
              weight_very_large = 0.33;                
                
%         end
        
        load('MyColormaps','mycmap'); 
    
        tic;
        disp('Test case: ');disp(test_image);
        disp('DMSR');
        [nrows,ncols] =  size(image_data);
        Area = nrows*ncols;
        Area_size_large = Area * Area_factor_large;
        Area_size_very_large = Area * Area_factor_very_large;
        lambda = lambda_factor* fix(SE_size_factor*sqrt(Area/pi));      
        binary_masks = zeros(nrows,ncols, num_levels);
        num_cc = zeros(1,num_levels);
        num_large_cc = zeros(1,num_levels);
        num_very_large_cc = zeros(1,num_levels);
        num_combined_cc = zeros(1,num_levels);
        
        % otsu thresholding
        otsu = fix(num_levels*graythresh(image_data));
        binary_otsu = image_data >= otsu;
        
        
        for level = 1:num_levels
           binary = image_data >= level;
           binary_filt = bwareaopen(binary, lambda, conn);
           binary_filt2 = 1- bwareaopen(1- binary_filt, lambda, conn);
           binary_masks(:,:,level) = binary_filt2;
          % binary_masks(:,:,level) = image_data >= level;
        end
        
        for l = 1 :num_levels
              CC = bwconncomp(binary_masks(:,:,l),conn);
              RP = regionprops(CC, 'Area');
              num = CC.NumObjects;
              num_cc(l) = num;
              ln = 0; vln = 0;
              for r = 1:  num
                  regionArea =  RP(r).Area;
                  if regionArea >= Area_size_very_large
                      ln = ln+1;
                      vln = vln + 1;
                  else
                      if regionArea >= Area_size_large
                          ln = ln + 1;
                      end
                  end
              end
              num_large_cc(l) = ln;
              num_very_large_cc(l) = vln;
        end
             
         [max_num, thresh_all] = max(num_cc(:));
         [max_large_num, thresh_large] = max(num_large_cc(:));
         [max_very_large_num, thresh_very_large] = max(num_very_large_cc(:));
         
         % normalize 
         norm_num_cc = num_cc/max_num;
         norm_large_num_cc = num_large_cc/max_large_num;
         norm_very_large_num_cc = num_very_large_cc/max_very_large_num;
         num_combined_cc = (weight_all*norm_num_cc + ...
             weight_large* norm_large_num_cc+ ...
             weight_very_large*norm_very_large_num_cc);

         [max_combined, thresh] = max(num_combined_cc);
          
        [counts, centers]= hist(double(image_data(:)), num_levels); 
        
        figure('Position',get(0,'ScreenSize'))
        subplot(221); plot(centers, counts,'k'); title('Gray-level histogram with Otsu threshold');
                hold on; line('XData',[otsu otsu], ...
                    'YData', [0 max(counts)], 'Color', 'r'); hold off;axis on;grid on;
                legend;
        subplot(222);imshow(binary_otsu); axis on;grid on;
        title(['Image thresholded at Otsu s level ' num2str(otsu)]);
        
        subplot(223); plot(1:num_levels, norm_num_cc, 'k',...
            1:num_levels, norm_large_num_cc,'b',...
            1:num_levels, norm_very_large_num_cc,'m',...
            1:num_levels, num_combined_cc, 'r'); 
        legend('all','large', 'very large', 'combined');
        
        title('Normalized number of Connected Components and maximum');
%         hold on; line('XData',[thresh_all thresh_all], ...
%                     'YData', [0 max_num], 'Color', 'k'); 
%         hold on; line('XData',[thresh_large thresh_large], ...
%                     'YData', [0 max_num], 'Color', 'b');
%         hold on; line('XData',[thresh_very_large thresh_very_large], ...
%                     'YData', [0 max_num], 'Color', 'r');                 
         hold on; line('XData',[thresh thresh], ...
                    'YData', [0 1.2], 'Color', 'r');         
                
        hold off;axis on; grid on;
                                                
        subplot(224); imshow(binary_masks(:,:,thresh)); axis on;grid on;
        title(['Image thresholded at level ' num2str(thresh)]);
    
        
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
        clear binary binary_filt binary_filt2 binary_otsu binary_masks CC RP image_data
    end
end
disp('--------------- The End ---------------------------------');