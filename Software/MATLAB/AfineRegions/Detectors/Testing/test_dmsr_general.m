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

batch_structural = false;

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
        test_images = {'graffiti'};
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
%             Area_factor = 0.03;
             num_levels = 255;
%             %steps = [2 5 10 15 20 25 30 40 45 50];
%             steps = [1];
%             thresh_type = 's';
%             %saliency_thresh = [0.05 0.15 0.25 0.5 0.75];
%             saliency_thresh = 0.6;
             pref_offset = 20;
%         end
        
        load('MyColormaps','mycmap'); 
    
        tic;
        disp('Test case: ');disp(test_image);
        disp('DMSR');
        [nrows,ncols] =  size(image_data);
        Area = nrows*ncols;
        lambda = 2* fix(SE_size_factor*sqrt(Area/pi));
        binary_masks = zeros(nrows,ncols, num_levels);
        
        % otsu thresholding
        otsu = fix(num_levels*graythresh(image_data));
        binary_otsu = image_data >= otsu;
        
        
        for level = 1:num_levels
            binary = image_data >= level;
            binary_filt = bwareaopen(binary, lambda, 8);
            binary_filt = 1- bwareaopen(1- binary_filt, lambda, 8);
            binary_masks(:,:,level) = binary_filt;
        end
        
        for l = 1 :num_levels
              CC{l} = bwconncomp(binary_masks(:,:,l),8);
              ncc = CC{l}.NumObjects;
              if ncc > 20
                num_cc(l) = ncc;
              else
                num_cc(l) =NaN;
              end;
             % RP{l} = regionprops( CC , 'Area');
        end
       
        offset = 20; 
        for l = offset+1 : num_levels - offset;
            d = 0;
            for o = 1:offset
              diff_f = abs(num_cc(l) - num_cc(l+o));
              diff_b = abs(num_cc(l) - num_cc(l-o));
              d = [d (diff_f + diff_b)/2];
            end              
              diff(l) = sum(d(:));
        end
                
%         [max_l, max_ind] = max(diff(otsu - offset:otsu + offset));
%         thresh = max_ind + (otsu - (offset + 1));
        
%         [min_l, min_ind] = min(diff(otsu - offset:otsu + offset));
%         thresh = min_ind + (otsu - (offset+1));
        
         cropped_diff = diff(pref_offset:255 - pref_offset); 
         [val, ind] = max(cropped_diff(:));
         thresh = ind + (pref_offset - 1);
       
        
%           disp('Ratio between max and mean of the differences: ');
%           disp(max_l/mean(cropped_diff(:)));
%           disp('Standart deviation of the differences');
%           disp(std(cropped_diff(:)));
          
        [counts, centers]= hist(double(image_data(:)), num_levels); 
        
        figure('Position',get(0,'ScreenSize'))
        subplot(221); bar(centers, counts); title('Gray-level histogram');
                hold on; line('XData',[otsu otsu], ...
                    'YData', [0 max(counts)], 'Color', 'r'); hold off;axis on;grid on;
        subplot(222);imshow(binary_otsu); axis on;grid on;
        title(['Image thresholded at Otsu s level ' num2str(otsu)]);
        
        subplot(223); plot(diff, 'k'); title('Differences num_regions.')
        hold on; line('XData',[thresh thresh], ...
                    'YData', [0 max(diff)], 'Color', 'r'); 
                line('XData',[pref_offset pref_offset], ...
                    'YData', [0 max(diff)], 'Color', 'g'); 
                line('XData',[255- pref_offset 255 - pref_offset], ...
                    'YData', [0 max(diff)], 'Color', 'g');
                hold off;axis on; grid on;
                                                
        subplot(224); imshow(binary_masks(:,:,thresh)); axis on;grid on;
        title(['Image thresholded at diff threshold ' num2str(thresh)]);
    
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
        clear binary binary_otsu binary_masks RP CC image_data
    end
end
disp('--------------- The End ---------------------------------');