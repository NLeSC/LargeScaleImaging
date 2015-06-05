% test_smssr.m- script to test the SMSSR detector
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
visualize_major = false;
visualize_minor = false;
lisa = true;

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
    test_image = input('Enter test case: [boat|phantom|thorax|graffiti|leuven|bikes]: ','s');
    switch lower(test_image)
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
        case 'phantom'
            image_filename{1} = fullfile(data_path,'Phantom','phantom.png');
            image_filename{2} = fullfile(data_path,'Phantom','phantom_affine.png');
            if save_flag
                features_filename{1} = fullfile(results_path,'Phantom','phantom.smssr');
                features_filename{2} = fullfile(results_path,'Phantom','phantom_affine.smssr');
                regions_filename{1} = fullfile(results_path,'Phantom','phantom_smartregions.mat');
                regions_filename{2} = fullfile(results_path,'Phantom','phantom_affine_smartregions.mat');    
            end
        case 'thorax'
             image_filename{1} = fullfile(data_path,'CT','thorax1.jpg');
            if save_flag
                features_filename{1} = fullfile(results_path,'CT','thorax1.smssr');
	      regions_filename{1} = fullfile(results_path,'CT','thorax1_smartregions.mat');
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
    end
    mask_filename =[];

end

disp('**************************** Testing SMSSR detector *****************');
%% find out the number of test files
len = length(image_filename);

%% loop over all test images
for i = 1:len
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
        thresh = input('Enter the region threshold: ');
        
    else
        preproc_types = [0 1];
        saliency_types = [1 1 1 1];
        SE_size_factor = 0.02;
        SE_size_factor_preproc = 0.002;
        Area_factor = 0.03;
        num_levels = 20;
        thersh = 0.75;
    end
    
    tic;
    disp('Test case: ');disp(test_image);
    disp('SMSSR');
      
    execution_params = [verbose visualize_major visualize_minor];
    image_data = smssr_preproc(image_data, preproc_types);
    [num_smartregions, features, saliency_masks] = smssr(image_data, ROI, ...
        num_levels, saliency_types, region_params, execution_params);
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
      disp(' Displaying... ');
      
      type = 1; % distinguish region's types
   
      % open the saved regions
      [num_smartregions, features, saliency_masks] = smssr_open(features_filename{i}, regions_filename{1}, type);
    
      list_smartregions = [];     % display all regions
   
      scaling = 1;  % no scaling
      line_width = 2; % thickness of the line
      labels = 0; % no region's labels
   
      col_ellipse = [];
      col_label = [];
    
      original = 0; % no original region's outline
    
      display_features(image_filename{i}, features_filename{i}, mask_filename, ...
		    regions_filename{i},...  
		    type, list_smartregions, scaling, labels, col_ellipse, ...
		    line_width, col_label, original);
      title('SMSSR');
    end
    
     
end
disp('--------------- The End ---------------------------------');
