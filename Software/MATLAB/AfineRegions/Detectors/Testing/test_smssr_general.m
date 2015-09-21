% test_smssr_general.m- script to test the SMSSR detector on general images
%**************************************************************************
% author: Elena Ranguelova, NLeSc
% date created: 27-05-2015
% last modification date: 03-06-2015
% modification details: added saving of the features and displaying them as ellipses
%			shorter filenames
%**************************************************************************
%% paramaters
interactive = false;
verbose = false;
visualize = true;
visualize_major = true;
visualize_minor = false;
lisa = false;

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
    image_filename = input('Enter the test image filename: ','s');
    mask_filename = input('Enter the mask filename (.mat): ', 's');
else
    test_image = input('Enter test case: [bark|bikes|boat|graffiti|leuven|trees|ubc|wall]: ','s');
    switch lower(test_image)
        case 'bark'
            image_filename{1} = fullfile(data_path,test_image,'bark1.png');    
            image_filename{2} = fullfile(data_path,test_image,'bark2.png');
            image_filename{3} = fullfile(data_path,test_image,'bark3.png');
            image_filename{4} = fullfile(data_path,test_image,'bark4.png');
            image_filename{5} = fullfile(data_path,test_image,'bark5.png');
            image_filename{6} = fullfile(data_path,test_image,'bark6.png');
            if save_flag
                features_filename{1} = fullfile(results_path,test_image,'bark1.smssr');
                features_filename{2} = fullfile(results_path,test_image,'bark2.smssr');
                features_filename{3} = fullfile(results_path,test_image,'bark3.smssr');
                features_filename{4} = fullfile(results_path,test_image,'bark4.smssr');
                features_filename{5} = fullfile(results_path,test_image,'bark5.smssr');
                features_filename{6} = fullfile(results_path,test_image,'bark6.smssr');
                regions_filename{1} = fullfile(results_path,test_image,'bark1_smartregions.mat');
                regions_filename{2} = fullfile(results_path,test_image,'bark2_smartregions.mat');
                regions_filename{3} = fullfile(results_path,test_image,'bark3_smartregions.mat');
                regions_filename{4} = fullfile(results_path,test_image,'bark4_smartregions.mat');
                regions_filename{5} = fullfile(results_path,test_image,'bark5_smartregions.mat');
                regions_filename{6} = fullfile(results_path,test_image,'bark6_smartregions.mat');   
            end
        case 'boat'
            image_filename{1} = fullfile(data_path,test_image,'boat1.png');    
            image_filename{2} = fullfile(data_path,test_image,'boat2.png');
            image_filename{3} = fullfile(data_path,test_image,'boat3.png');
            image_filename{4} = fullfile(data_path,test_image,'boat4.png');
            image_filename{5} = fullfile(data_path,test_image,'boat5.png');
            image_filename{6} = fullfile(data_path,test_image,'boat6.png');
            if save_flag
                features_filename{1} = fullfile(results_path,test_image,'boat1.smssr');
                features_filename{2} = fullfile(results_path,test_image,'boat2.smssr');
                features_filename{3} = fullfile(results_path,test_image,'boat3.smssr');
                features_filename{4} = fullfile(results_path,test_image,'boat4.smssr');
                features_filename{5} = fullfile(results_path,test_image,'boat5.smssr');
                features_filename{6} = fullfile(results_path,test_image,'boat6.smssr');
                regions_filename{1} = fullfile(results_path,test_image,'boat1_smartregions.mat');
                regions_filename{2} = fullfile(results_path,test_image,'boat2_smartregions.mat');
                regions_filename{3} = fullfile(results_path,test_image,'boat3_smartregions.mat');
                regions_filename{4} = fullfile(results_path,test_image,'boat4_smartregions.mat');
                regions_filename{5} = fullfile(results_path,test_image,'boat5_smartregions.mat');
                regions_filename{6} = fullfile(results_path,test_image,'boat6_smartregions.mat');   
            end
        case 'graffiti'
            image_filename{1} = fullfile(data_path,test_image,'graffiti1.png');    
            image_filename{2} = fullfile(data_path,test_image,'graffiti2.png');
            image_filename{3} = fullfile(data_path,test_image,'graffiti3.png');
            image_filename{4} = fullfile(data_path,test_image,'graffiti4.png');
            image_filename{5} = fullfile(data_path,test_image,'graffiti5.png');
            image_filename{6} = fullfile(data_path,test_image,'graffiti6.png');  
            if save_flag
                features_filename{1} = fullfile(results_path,test_image,'graffiti1.smssr');
                features_filename{2} = fullfile(results_path,test_image,'graffiti2.smssr');
                features_filename{3} = fullfile(results_path,test_image,'graffiti3.smssr');
                features_filename{4} = fullfile(results_path,test_image,'graffiti4.smssr');
                features_filename{5} = fullfile(results_path,test_image,'graffiti5.smssr');
                features_filename{6} = fullfile(results_path,test_image,'graffiti6.smssr');
                regions_filename{1} = fullfile(results_path,test_image,'graffiti1_smartregions.mat');
                regions_filename{2} = fullfile(results_path,test_image,'graffiti2_smartregions.mat');
                regions_filename{3} = fullfile(results_path,test_image,'graffiti3_smartregions.mat');
                regions_filename{4} = fullfile(results_path,test_image,'graffiti4_smartregions.mat');
                regions_filename{5} = fullfile(results_path,test_image,'graffiti5_smartregions.mat');
                regions_filename{6} = fullfile(results_path,test_image,'graffiti6_smartregions.mat');     
            end
        case 'leuven'
            image_filename{1} = fullfile(data_path,test_image,'leuven1.png');    
            image_filename{2} = fullfile(data_path,test_image,'leuven2.png');
            image_filename{3} = fullfile(data_path,test_image,'leuven3.png');    
            image_filename{4} = fullfile(data_path,test_image,'leuven4.png');
            image_filename{5} = fullfile(data_path,test_image,'leuven5.png');    
            image_filename{6} = fullfile(data_path,test_image,'leuven6.png');
            if save_flag
                features_filename{1} = fullfile(results_path,test_image,'leuven1.smssr');
                features_filename{2} = fullfile(results_path,test_image,'leuven2.smssr');
                features_filename{3} = fullfile(results_path,test_image,'leuven3.smssr');
                features_filename{4} = fullfile(results_path,test_image,'leuven4.smssr');
                features_filename{5} = fullfile(results_path,test_image,'leuven5.smssr');
                features_filename{6} = fullfile(results_path,test_image,'leuven6.smssr');
                regions_filename{1} = fullfile(results_path,test_image,'leuven1_smartregions.mat');
                regions_filename{2} = fullfile(results_path,test_image,'leuven2_smartregions.mat');
                regions_filename{3} = fullfile(results_path,test_image,'leuven3_smartregions.mat');
                regions_filename{4} = fullfile(results_path,test_image,'leuven4_smartregions.mat');
                regions_filename{5} = fullfile(results_path,test_image,'leuven5_smartregions.mat');
                regions_filename{6} = fullfile(results_path,test_image,'leuven6_smartregions.mat');    
            end
        case 'bikes'
            image_filename{1} = fullfile(data_path,test_image,'bikes1.png');    
            image_filename{2} = fullfile(data_path,test_image,'bikes2.png');
            image_filename{3} = fullfile(data_path,test_image,'bikes3.png');    
            image_filename{4} = fullfile(data_path,test_image,'bikes4.png');
            image_filename{5} = fullfile(data_path,test_image,'bikes5.png');    
            image_filename{6} = fullfile(data_path,test_image,'bikes6.png');
            if save_flag
               features_filename{1} = fullfile(results_path,test_image,'bikes1.smssr');
                features_filename{2} = fullfile(results_path,test_image,'bikes2.smssr');
                features_filename{3} = fullfile(results_path,test_image,'bikes3.smssr');
                features_filename{4} = fullfile(results_path,test_image,'bikes4.smssr');
                features_filename{5} = fullfile(results_path,test_image,'bikes5.smssr');
                features_filename{6} = fullfile(results_path,test_image,'bikes6.smssr'); 
                regions_filename{1} = fullfile(results_path,test_image,'bikes1_smartregions.mat');
                regions_filename{2} = fullfile(results_path,test_image,'bikes2_smartregions.mat');
                regions_filename{3} = fullfile(results_path,test_image,'bikes3_smartregions.mat');
                regions_filename{4} = fullfile(results_path,test_image,'bikes4_smartregions.mat');
                regions_filename{5} = fullfile(results_path,test_image,'bikes5_smartregions.mat');
                regions_filename{6} = fullfile(results_path,test_image,'bikes6_smartregions.mat');      
            end
            case 'trees'
            image_filename{1} = fullfile(data_path,test_image,'trees1.png');    
            image_filename{2} = fullfile(data_path,test_image,'trees2.png');
            image_filename{3} = fullfile(data_path,test_image,'trees3.png');    
            image_filename{4} = fullfile(data_path,test_image,'trees4.png');
            image_filename{5} = fullfile(data_path,test_image,'trees5.png');    
            image_filename{6} = fullfile(data_path,test_image,'trees6.png');
            if save_flag
               features_filename{1} = fullfile(results_path,test_image,'trees1.smssr');
                features_filename{2} = fullfile(results_path,test_image,'trees2.smssr');
                features_filename{3} = fullfile(results_path,test_image,'trees3.smssr');
                features_filename{4} = fullfile(results_path,test_image,'trees4.smssr');
                features_filename{5} = fullfile(results_path,test_image,'trees5.smssr');
                features_filename{6} = fullfile(results_path,test_image,'trees6.smssr'); 
                regions_filename{1} = fullfile(results_path,test_image,'trees1_smartregions.mat');
                regions_filename{2} = fullfile(results_path,test_image,'trees2_smartregions.mat');
                regions_filename{3} = fullfile(results_path,test_image,'trees3_smartregions.mat');
                regions_filename{4} = fullfile(results_path,test_image,'trees4_smartregions.mat');
                regions_filename{5} = fullfile(results_path,test_image,'trees5_smartregions.mat');
                regions_filename{6} = fullfile(results_path,test_image,'trees6_smartregions.mat');      
            end
            case 'ubc'
            image_filename{1} = fullfile(data_path,test_image,'ubc1.png');    
            image_filename{2} = fullfile(data_path,test_image,'ubc2.png');
            image_filename{3} = fullfile(data_path,test_image,'ubc3.png');    
            image_filename{4} = fullfile(data_path,test_image,'ubc4.png');
            image_filename{5} = fullfile(data_path,test_image,'ubc5.png');    
            image_filename{6} = fullfile(data_path,test_image,'ubc6.png');
            if save_flag
               features_filename{1} = fullfile(results_path,test_image,'ubc1.smssr');
                features_filename{2} = fullfile(results_path,test_image,'ubc2.smssr');
                features_filename{3} = fullfile(results_path,test_image,'ubc3.smssr');
                features_filename{4} = fullfile(results_path,test_image,'ubc4.smssr');
                features_filename{5} = fullfile(results_path,test_image,'ubc5.smssr');
                features_filename{6} = fullfile(results_path,test_image,'ubc6.smssr'); 
                regions_filename{1} = fullfile(results_path,test_image,'ubc1_smartregions.mat');
                regions_filename{2} = fullfile(results_path,test_image,'ubc2_smartregions.mat');
                regions_filename{3} = fullfile(results_path,test_image,'ubc3_smartregions.mat');
                regions_filename{4} = fullfile(results_path,test_image,'ubc4_smartregions.mat');
                regions_filename{5} = fullfile(results_path,test_image,'ubc5_smartregions.mat');
                regions_filename{6} = fullfile(results_path,test_image,'ubc6_smartregions.mat');      
            end
            case 'wall'
            image_filename{1} = fullfile(data_path,test_image,'wall1.png');    
            image_filename{2} = fullfile(data_path,test_image,'wall2.png');
            image_filename{3} = fullfile(data_path,test_image,'wall3.png');    
            image_filename{4} = fullfile(data_path,test_image,'wall4.png');
            image_filename{5} = fullfile(data_path,test_image,'wall5.png');    
            image_filename{6} = fullfile(data_path,test_image,'wall6.png');
            if save_flag
               features_filename{1} = fullfile(results_path,test_image,'wall1.smssr');
                features_filename{2} = fullfile(results_path,test_image,'wall2.smssr');
                features_filename{3} = fullfile(results_path,test_image,'wall3.smssr');
                features_filename{4} = fullfile(results_path,test_image,'wall4.smssr');
                features_filename{5} = fullfile(results_path,test_image,'wall5.smssr');
                features_filename{6} = fullfile(results_path,test_image,'wall6.smssr'); 
                regions_filename{1} = fullfile(results_path,test_image,'wall1_smartregions.mat');
                regions_filename{2} = fullfile(results_path,test_image,'wall2_smartregions.mat');
                regions_filename{3} = fullfile(results_path,test_image,'wall3_smartregions.mat');
                regions_filename{4} = fullfile(results_path,test_image,'wall4_smartregions.mat');
                regions_filename{5} = fullfile(results_path,test_image,'wall5_smartregions.mat');
                regions_filename{6} = fullfile(results_path,test_image,'wall6_smartregions.mat');      
            end
    end
    mask_filename =[];

end

disp('**************************** Testing SMSSR detector *****************');
%% find out the number of test files
len = length(image_filename);

%% loop over all test images
%for i = 1:len
for i = 1
    %% load the image & convertto gray-scale if  color
    image_data = imread(image_filename{i});
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

    %% run the SMSSR detector
    
    if interactive
        preproc_types(1) = input('Smooth? [0/1]: ');
        preproc_types(2) = input('Histogram equialize? [0/1]: ');
        SE_size_factor_preproc = input('Enter the Structuring Element size factor (preprocessing): ');
        saliency_types(1) = input('Detect "holes"? [0/1]: ');
        saliency_types(2) = input('Detect "islands"? [0/1]: ');
        saliency_types(3) = input('Detect "indentations"? [0/1]: ');
        saliency_types(4) = input('Detect "protrusions"? [0/1]: ');
        SE_size_factor = input('Enter the Structuring Element size factor: ');
        Area_factor = input('Enter the Connected Component size factor (processing): ');
        num_levels = input('Enter the number of gray-levels: ');
        thrsh_type = input('Enter the thresholding type (s(ingle) or h(ysteresis)): ');
        saliency_thresh = input('Enter the region threshold: ');
        
    else
        preproc_types = [0 0];
        saliency_types = [1 1 0 0];
        SE_size_factor = 0.05;
        SE_size_factor_preproc = 0.002;
        Area_factor = 0.25;
        %num_levels = 255;
        %steps = [5 10 20 25 35 50];
        num_levels = 100;
        steps = [5];
        thresh_type = 's';
        %saliency_thresh = [0.05 0.15 0.25 0.5 0.75];
        saliency_thresh = [0 1];
    end
    
    tic;
    disp('Test case: ');disp(test_image);
    disp('SMSSR');
      
    execution_params = [verbose visualize_major visualize_minor];
    region_params = [SE_size_factor Area_factor];
    if find(preproc_types)
        image_data = smssr_preproc(image_data, preproc_types);
    end
    [num_smartregions, features, saliency_masks] = smssr(image_data, ROI, ...
        num_levels, steps, saliency_thresh, saliency_types, thresh_type, region_params, execution_params);

    toc
    % save the features
    disp('Saving ...');
    smssr_save(features_filename{i}, regions_filename{i}, num_smartregions, features, saliency_masks);
    
    
    %% visualize
 %   if visualize
 %       f1 = figure; set(f1,'WindowStyle','docked');visualize_mssr(image_data);
 %       f2 = figure; set(f2,'WindowStyle','docked');visualize_mssr(image_data, saliency_masks, saliency_types, region_params);
 %       f3 = figure; set(f3,'WindowStyle','docked');visualize_mssr(image_data, saliency_masks, [1 0 0 0], region_params);
 %       f4 = figure; set(f4,'WindowStyle','docked');visualize_mssr(image_data, saliency_masks, [0 1 0 0], region_params);
 %       f5 = figure; set(f5,'WindowStyle','docked');visualize_mssr(image_data, saliency_masks, [0 0 1 0], region_params);
 %       f6 = figure; set(f6,'WindowStyle','docked');visualize_mssr(image_data, saliency_masks, [0 0 0 1], region_params);
      
 %   end
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

     display_smart_regions(image_filename{i}, features_filename{i}, mask_filename, ...
         regions_filename{i},...
         type, list_smartregions, step_list_regions, scaling, labels, col_ellipse, ...
         line_width, col_label, original);
 end
    
%pause;    
end
disp('--------------- The End ---------------------------------');
