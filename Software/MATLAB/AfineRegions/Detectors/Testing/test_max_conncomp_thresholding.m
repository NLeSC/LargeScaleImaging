% test_max_conncomp_thresholding.m- testing the data-driven binarization
%**************************************************************************
% author: Elena Ranguelova, NLeSc
% date created: 21-04-2016
% last modification date: 26-04-2006
% modification details: another test case; removed the batch flag
%**************************************************************************
%% paramaters
verbose = false;
visualize = true;
if visualize
    set(0,'Units','pixels')
    scnsize = get(0,'ScreenSize');
end


%% parameters
SE_size_factor = 0.02;
Area_factor_very_large = 0.01;
Area_factor_large = 0.001;
lambda_factor = 3;
%num_levels = 255;
step_size = 1;
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
data_path = fullfile(project_path, 'Data','AffineRegions');
results_path = fullfile(project_path, 'Results', 'AffineRegions');


test_images = {'boat'};


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
        %disp(image_filenames{i});
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
        
        j = 0;
        %loop over all possible weights
%         for weight_all= 0.1:0.23:0.6
%             for weight_large = 0.1:0.23:0.6
%                 for weight_very_large = 0.1:0.23:0.6
%                     if (abs(weight_all + weight_large + weight_very_large - 1) < 0.1) 
%                         j = j+1;
%                         if i == 1
%                             wegihts(j,1) = weight_all;
%                             weights(j,2) = weight_large;
%                             weights(j,3) = weight_very_large;
%                         end
%                         disp('Weight combination # :');
%                         disp(j);
%                         disp('Weight all:');disp(weight_all);
%                         disp('Weight large:');disp(weight_large);
%                         disp('Weight very large:');disp(weight_very_large);
%                         tic;
                        
                        morphology_parameters = [SE_size_factor Area_factor_very_large ...
                            Area_factor_large lambda_factor conn];
                        weights = [weight_all weight_large weight_very_large];
                        execution_flags = [verbose visualize];
                        
                        [binary_image, otsu, num_combined_cc, thresh] = max_conncomp_thresholding(image_data, ...
                            step_size, offset, otsu_only, ...
                            morphology_parameters, weights, ...
                            execution_flags);
%                         [max_num_cc(i,j), ~] = max(num_combined_cc);
%                     end
%                 end
%             end
%         end
        end
    %% visualization 
    if visualize
                    figure('Position',scnsize);
        
                    subplot(221); imshow(image_data); title('Gray-scale image'); axis on, grid on;
                    %subplot(222);imshow(ROI_only); title('ROI'); axis on, grid on;
        
                    subplot(223); plot(1:length(num_combined_cc), num_combined_cc, 'b');
                    title('Normalized number of Combined Connected Components');
                    hold on; line('XData',[thresh thresh], ...
                        'YData', [0 1.2], 'Color', 'r');
                    hold on; line('XData',[otsu otsu], ...
                        'YData', [0 1.2], 'Color', 'b');
        
                    hold off;axis on; grid on;
        
                    subplot(224); imshow(double(binary_image)); axis on;grid on;
                    title(['Binarized image at level ' num2str(thresh)]);
%         figure('Position',scnsize);
%         for k = 2:6
%             diff(k-1,:) = max_num_cc(k,:) - max_num_cc(1,:);
%         end
%         for j = 1:7
%             plot((diff(:,j))); hold on;
%         end
%         legend('Weights 1', 'Weights 2', 'Weights 3', 'Weights 4', 'Weights 5', 'Weights 6', 'Weights 7');

    end
    
    toc

        
  
    disp('****************************************************************');
end
disp('--------------- The End ---------------------------------');