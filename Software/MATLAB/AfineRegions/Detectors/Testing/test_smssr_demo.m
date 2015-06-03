%% test_smssr_demo.m- script to test the SMSSR detector for demo purposes
%**************************************************************************
% author: Elena Ranguelova, NLeSc
% date created: 03-06-2015
% last modification date: 
% modification details: 
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
data_path = fullfile(project_path, 'Data', 'Scientific');
results_path = fullfile(project_path, 'Results', 'Scientific');

test_domain = input('Enter test domain: [AnimalBiometrics|Medical|Forestry]: ','s');

switch lower(test_domain)
  case 'animalbiometrics'
    domain_path = fullfile(data_path,'AnimalBiometrics');
    domain_results_path = fullfile(results_path,'AnimalBiometrics');
    test_case = input('Enter test case: [turtle|whale|newt]: ','s');
    switch lower(test_case)
      case 'turtle'
	test_case_name = 'leatherback'
      case 'whale'
	test_case_name = 'tails'
      case 'newt'
	test_case_name = 'newt images'
    end
  case 'medical'
    domain_path = fullfile(data_path,'Medical');
    domain_results_path = fullfile(results_path,'Medical');
    test_case_name = input('Enter test case: [MRI|CT|retina]: ','s');
  case 'forestry'
    domain_path = fullfile(data_path,'Forestry');
    domain_results_path = fullfile(results_path,'Forestry');
    test_case_name = '';
end

data_test_path = fullfile(domain_path, test_case_name);
results_domain_path = fullfile(domain_results_path,test_case_name); 
images_list = dir(data_test_path);
mask_filename =[];

disp('**************************** Demo SMSSR detector *****************');
%% find out the number of test files
len = length(images_list);

%% loop over all test images
for i = 1:len
    if not(images_list(i).isdir)
      image_filename = fullfile(data_test_path, images_list(i).name);
      [pathstr,name,ext] = fileparts(image_filename);
      features_filename = fullfile(results_domain_path, [name '.smssr');
      regions_filename = fullfile(results_domain_path, [name '._smartregions.mat');
      %% load the image & convertto gray-scale if  color
      image_data = imread(image_filename);
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
      
      tic;
      
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
      
      
      disp('Test case: ');disp(test_case_name);
      disp('SMSSR');
	
      region_params = [SE_size_factor Area_factor];
      execution_params = [verbose visualize_major visualize_minor];
      image_data = smssr_preproc(image_data, preproc_types);
      [num_smartregions, features, saliency_masks] = smssr(image_data, ROI, ...
	  num_levels, saliency_types, region_params, execution_params);
      toc
      % save the features
      disp('Saving ...');
      
      smssr_save(features_filename, regions_filename, num_smartregions, features, saliency_masks);
      
      
      %% visualize

      if vis_flag
	    disp(' Displaying... ');
	
	    type = 1; % distinguish region's types
        
	    % display the saved region
          
	    list_smartregions = [];     % display all regions
        
	    scaling = 1;  % no scaling
	    line_width = 2; % thickness of the line
	    labels = 0; % no region's labels
        
	    col_ellipse = [];
	    col_label = [];
          
	    original = 0; % no original region's outline
          
	    display_smart_regions(image_filename, features_filename, mask_filename, ...
		          regions_filename,...  
		          type, list_smartregions, scaling, labels, col_ellipse, ...
		          line_width, col_label, original);
	    title('SMSSR');
      end
    end
     
end
disp('--------------- The End ---------------------------------');