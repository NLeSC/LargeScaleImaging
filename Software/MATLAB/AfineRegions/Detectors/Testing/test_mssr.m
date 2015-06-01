% test_mssr.m- script to test the MSSR detector
%**************************************************************************
% author: Elena Ranguelova, NLeSc
% date created: 15-05-2015
% last modification date: 1-06-2015
% modification details: added saving of the features and displaying them as ellipses
%**********************************************************
%% paramaters
interactive = false;
verbose = false;
visualize = true;
visualize_major = false;
visualize_minor = false;
lisa = true;

otsu = false;

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
if interactive 
    image_filename = input('Enter the test image filename: ','s');
    mask_filename = input('Enter the mask filename (.mat): ', 's');
else
    test_image = input('Enter test case: [boat|phantom|thorax|graffiti|leuven|bikes]: ','s');
    switch lower(test_image)
        case 'boat'
            image_filename{1} = fullfile(starting_path,'eStep','LargeScaleImaging',...
            'Data','AffineRegions','boat','boat1.png');    
            image_filename{2} = fullfile(starting_path,'eStep','LargeScaleImaging',...
            'Data','AffineRegions','boat','boat2.png');
            image_filename{3} = fullfile(starting_path,'eStep','LargeScaleImaging',...
                'Data','AffineRegions','boat','boat3.png');
            image_filename{4} = fullfile(starting_path,'eStep','LargeScaleImaging',...
                'Data','AffineRegions','boat','boat4.png');
            image_filename{5} = fullfile(starting_path,'eStep','LargeScaleImaging',...
                'Data','AffineRegions','boat','boat5.png');
            image_filename{6} = fullfile(starting_path,'eStep','LargeScaleImaging',...
                'Data','AffineRegions','boat','boat6.png');
            if save_flag
                features_filename{1} = fullfile(starting_path,'eStep','LargeScaleImaging',...
                    Results','AffineRegions','boat','boat1.mssr');
                features_filename{2} = fullfile(starting_path,'eStep','LargeScaleImaging',...
                    'Results','AffineRegions','boat','boat2.mssr');
                features_filename{3} = fullfile(starting_path,'eStep','LargeScaleImaging',...
                    'Results','AffineRegions','boat','boat3.mssr');
                features_filename{4} = fullfile(starting_path,'eStep','LargeScaleImaging',...
                    'Results','AffineRegions','boat','boat4.mssr');
                features_filename{5} = fullfile(starting_path,'eStep','LargeScaleImaging',...
                    'Results','AffineRegions','boat','boat5.mssr');
                features_filename{6} = fullfile(starting_path,'eStep','LargeScaleImaging',...
                    'Results','AffineRegions','boat','boat6.mssr');
                regions_filename{1} = fullfile(starting_path,'eStep','LargeScaleImaging',...
                    Results','AffineRegions','boat','boat1_regions.mat');
                regions_filename{2} = fullfile(starting_path,'eStep','LargeScaleImaging',...
                    'Results','AffineRegions','boat','boat2_regions.mat');
                regions_filename{3} = fullfile(starting_path,'eStep','LargeScaleImaging',...
                    'Results','AffineRegions','boat','boat3_regions.mat');
                regions_filename{4} = fullfile(starting_path,'eStep','LargeScaleImaging',...
                    'Results','AffineRegions','boat','boat4_regions.mat');
                regions_filename{5} = fullfile(starting_path,'eStep','LargeScaleImaging',...
                    'Results','AffineRegions','boat','boat5_regions.mat');
                regions_filename{6} = fullfile(starting_path,'eStep','LargeScaleImaging',...
                    'Results','AffineRegions','boat','boat6_regions.mat');   
            end
        case 'graffiti'
            image_filename{1} = fullfile(starting_path,'eStep','LargeScaleImaging',...
            'Data','AffineRegions','graffiti','graffiti1.png');    
            image_filename{2} = fullfile(starting_path,'eStep','LargeScaleImaging',...
            'Data','AffineRegions','graffiti','graffiti2.png');
            image_filename{3} = fullfile(starting_path,'eStep','LargeScaleImaging',...
                'Data','AffineRegions','graffiti','graffiti3.png');
            image_filename{4} = fullfile(starting_path,'eStep','LargeScaleImaging',...
                'Data','AffineRegions','graffiti','graffiti4.png');
            image_filename{5} = fullfile(starting_path,'eStep','LargeScaleImaging',...
                'Data','AffineRegions','graffiti','graffiti5.png');
            image_filename{6} = fullfile(starting_path,'eStep','LargeScaleImaging',...
                'Data','AffineRegions','graffiti','graffiti6.png');  
            if save_flag
                features_filename{1} = fullfile(starting_path,'eStep','LargeScaleImaging',...
                    'Results','AffineRegions','graffiti','graffiti1.mssr');
                features_filename{2} = fullfile(starting_path,'eStep','LargeScaleImaging',...
                    'Results','AffineRegions','graffiti','graffiti2.mssr');
                features_filename{3} = fullfile(starting_path,'eStep','LargeScaleImaging',...
                    'Results','AffineRegions','graffiti','graffiti3.mssr');
                features_filename{4} = fullfile(starting_path,'eStep','LargeScaleImaging',...
                    'Results','AffineRegions','graffiti','graffiti4.mssr');
                features_filename{5} = fullfile(starting_path,'eStep','LargeScaleImaging',...
                    'Results','AffineRegions','graffiti','graffiti5.mssr');
                features_filename{6} = fullfile(starting_path,'eStep','LargeScaleImaging',...
                    'Results','AffineRegions','graffiti','graffiti6.mssr');
                regions_filename{1} = fullfile(starting_path,'eStep','LargeScaleImaging',...
                    Results','AffineRegions','graffiti','graffiti1_regions.mat');
                regions_filename{2} = fullfile(starting_path,'eStep','LargeScaleImaging',...
                    'Results','AffineRegions','graffiti','graffiti2_regions.mat');
                regions_filename{3} = fullfile(starting_path,'eStep','LargeScaleImaging',...
                    'Results','AffineRegions','graffiti','graffiti3_regions.mat');
                regions_filename{4} = fullfile(starting_path,'eStep','LargeScaleImaging',...
                    'Results','AffineRegions','graffiti','graffiti4_regions.mat');
                regions_filename{5} = fullfile(starting_path,'eStep','LargeScaleImaging',...
                    'Results','AffineRegions','graffiti','graffiti5_regions.mat');
                regions_filename{6} = fullfile(starting_path,'eStep','LargeScaleImaging',...
                    'Results','AffineRegions','graffiti','graffiti6_regions.mat');     
            end
        case 'phantom'
            image_filename{1} = fullfile(starting_path,'eStep','LargeScaleImaging',...
            'Data','AffineRegions','Phantom','phantom.png');
            image_filename{2} = fullfile(starting_path,'eStep','LargeScaleImaging',...
            'Data','AffineRegions','Phantom','phantom_affine.png');
            if save_flag
                features_filename{1} = fullfile(starting_path,'eStep','LargeScaleImaging',...
                    'Results','AffineRegions','Phantom','phantom.mssr');
                features_filename{2} = fullfile(starting_path,'eStep','LargeScaleImaging',...
                    'Results','AffineRegions','Phantom','phantom_affine.mssr');
                regions_filename{1} = fullfile(starting_path,'eStep','LargeScaleImaging',...
                    'Results','AffineRegions','Phantom','phantom_regions.mat');
                regions_filename{2} = fullfile(starting_path,'eStep','LargeScaleImaging',...
                    'Results','AffineRegions','Phantom','phantom_affine_regions.mat');    
            end
        case 'thorax'
             image_filename{1} = fullfile(starting_path,'eStep','LargeScaleImaging',...
            'Data','AffineRegions','CT','thorax1.jpg');
            if save_flag
                features_filename{1} = fullfile(starting_path,'eStep','LargeScaleImaging',...
            'Results','AffineRegions','CT','thorax1.mssr');
	      regions_filename{1} = fullfile(starting_path,'eStep','LargeScaleImaging',...
            'Results','AffineRegions','CT','thorax1_regions.mat');
            end
        case 'leuven'
            image_filename{1} = fullfile(starting_path,'eStep','LargeScaleImaging',...
            'Data','AffineRegions','leuven','leuven1.png');    
            image_filename{2} = fullfile(starting_path,'eStep','LargeScaleImaging',...
            'Data','AffineRegions','leuven','leuven2.png');
            image_filename{3} = fullfile(starting_path,'eStep','LargeScaleImaging',...
            'Data','AffineRegions','leuven','leuven3.png');    
            image_filename{4} = fullfile(starting_path,'eStep','LargeScaleImaging',...
            'Data','AffineRegions','leuven','leuven4.png');
            image_filename{5} = fullfile(starting_path,'eStep','LargeScaleImaging',...
            'Data','AffineRegions','leuven','leuven5.png');    
            image_filename{6} = fullfile(starting_path,'eStep','LargeScaleImaging',...
            'Data','AffineRegions','leuven','leuven6.png');
            if save_flag
                features_filename{1} = fullfile(starting_path,'eStep','LargeScaleImaging',...
                    'Results','AffineRegions','leuven','leuven1.mssr');
                features_filename{2} = fullfile(starting_path,'eStep','LargeScaleImaging',...
                    'Results','AffineRegions','leuven','leuven2.mssr');
                features_filename{3} = fullfile(starting_path,'eStep','LargeScaleImaging',...
                    'Results','AffineRegions','leuven','leuven3.mssr');
                features_filename{4} = fullfile(starting_path,'eStep','LargeScaleImaging',...
                    'Results','AffineRegions','leuven','leuven4.mssr');
                features_filename{5} = fullfile(starting_path,'eStep','LargeScaleImaging',...
                    'Results','AffineRegions','leuven','leuven5.mssr');
                features_filename{6} = fullfile(starting_path,'eStep','LargeScaleImaging',...
                    'Results','AffineRegions','leuven','leuven6.mssr');
                regions_filename{1} = fullfile(starting_path,'eStep','LargeScaleImaging',...
                    Results','AffineRegions','leuven','leuven1_regions.mat');
                regions_filename{2} = fullfile(starting_path,'eStep','LargeScaleImaging',...
                    'Results','AffineRegions','leuven','leuven2_regions.mat');
                regions_filename{3} = fullfile(starting_path,'eStep','LargeScaleImaging',...
                    'Results','AffineRegions','leuven','leuven3_regions.mat');
                regions_filename{4} = fullfile(starting_path,'eStep','LargeScaleImaging',...
                    'Results','AffineRegions','leuven','leuven4_regions.mat');
                regions_filename{5} = fullfile(starting_path,'eStep','LargeScaleImaging',...
                    'Results','AffineRegions','leuven','leuven5_regions.mat');
                regions_filename{6} = fullfile(starting_path,'eStep','LargeScaleImaging',...
                    'Results','AffineRegions','leuven','leuven6_regions.mat');    
            end
        case 'bikes'
            image_filename{1} = fullfile(starting_path,'eStep','LargeScaleImaging',...
            'Data','AffineRegions','bikes','bikes1.png');    
            image_filename{2} = fullfile(starting_path,'eStep','LargeScaleImaging',...
            'Data','AffineRegions','bikes','bikes2.png');
            image_filename{3} = fullfile(starting_path,'eStep','LargeScaleImaging',...
            'Data','AffineRegions','bikes','bikes3.png');    
            image_filename{4} = fullfile(starting_path,'eStep','LargeScaleImaging',...
            'Data','AffineRegions','bikes','bikes4.png');
            image_filename{5} = fullfile(starting_path,'eStep','LargeScaleImaging',...
            'Data','AffineRegions','bikes','bikes5.png');    
            image_filename{6} = fullfile(starting_path,'eStep','LargeScaleImaging',...
            'Data','AffineRegions','bikes','bikes6.png');
            if save_flag
               features_filename{1} = fullfile(starting_path,'eStep','LargeScaleImaging',...
                    'Results','AffineRegions','bikes','bikes1.mssr');
                features_filename{2} = fullfile(starting_path,'eStep','LargeScaleImaging',...
                    'Results','AffineRegions','bikes','bikes2.mssr');
                features_filename{3} = fullfile(starting_path,'eStep','LargeScaleImaging',...
                    'Results','AffineRegions','bikes','bikes3.mssr');
                features_filename{4} = fullfile(starting_path,'eStep','LargeScaleImaging',...
                    'Results','AffineRegions','bikes','bikes4.mssr');
                features_filename{5} = fullfile(starting_path,'eStep','LargeScaleImaging',...
                    'Results','AffineRegions','bikes','bikes5.mssr');
                features_filename{6} = fullfile(starting_path,'eStep','LargeScaleImaging',...
                    'Results','AffineRegions','bikes','bikes6.mssr'); 
                regions_filename{1} = fullfile(starting_path,'eStep','LargeScaleImaging',...
                    Results','AffineRegions','bikes','bikes1_regions.mat');
                regions_filename{2} = fullfile(starting_path,'eStep','LargeScaleImaging',...
                    'Results','AffineRegions','bikes','bikes2_regions.mat');
                regions_filename{3} = fullfile(starting_path,'eStep','LargeScaleImaging',...
                    'Results','AffineRegions','bikes','bikes3_regions.mat');
                regions_filename{4} = fullfile(starting_path,'eStep','LargeScaleImaging',...
                    'Results','AffineRegions','bikes','bikes4_regions.mat');
                regions_filename{5} = fullfile(starting_path,'eStep','LargeScaleImaging',...
                    'Results','AffineRegions','bikes','bikes5_regions.mat');
                regions_filename{6} = fullfile(starting_path,'eStep','LargeScaleImaging',...
                    'Results','AffineRegions','bikes','bikes6_regions.mat');      
            end
    end
    mask_filename =[];

end

disp('**************************** Testing MSSR detector *****************');
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

    %% run the MSSR detector
    
    tic;
    
    if interactive
        saliency_types(1) = input('Detect "holes"? [0/1]: ');
        saliency_types(2) = input('Detect "islands"? [0/1]: ');
        saliency_types(3) = input('Detect "indentations"? [0/1]: ');
        saliency_types(4) = input('Detect "protrusions"? [0/1]: ');
        SE_size_factor = input('Enter the Structuring Element size factor: ');
        Area_factor = input('Enter the Connected Component size factor: ');
        num_levels = input('Enter the number of gray-levels: ');
        thresh = input('Enter the region threshold: ');
    else
        saliency_types = [1 1 1 1];
        SE_size_factor = 0.02;
        Area_factor = 0.03;
        num_levels = 20;
        thersh = 0.75;
    end
    
    
    disp('Test case: ');disp(test_image);
    
    disp('MSSR');
    region_params = [SE_size_factor Area_factor];
    execution_params = [verbose visualize_major visualize_minor];
    [num_regions, features, saliency_masks] = mssr(image_data, ROI, ...
        num_levels, otsu, saliency_types, region_params, execution_params);
    toc
    
    %% save the features
    disp('Saving ...');
    
    mssr_save(features_filename{i}, regions_filename{i}, num_regions, features, saliency_masks);
    
    %% visualize
    if vis_flag
	disp(' Displaying... ');
	
       % f1 = figure; set(f1,'WindowStyle','docked');visualize_mssr(image_data);
       % f2 = figure; set(f2,'WindowStyle','docked');visualize_mssr(image_data, saliency_masks, saliency_types, region_params);
       % f3 = figure; set(f3,'WindowStyle','docked');visualize_mssr(image_data, saliency_masks, [1 0 0 0], region_params);
       % f4 = figure; set(f4,'WindowStyle','docked');visualize_mssr(image_data, saliency_masks, [0 1 0 0], region_params);
       % f5 = figure; set(f5,'WindowStyle','docked');visualize_mssr(image_data, saliency_masks, [0 0 1 0], region_params);
       % f6 = figure; set(f6,'WindowStyle','docked');visualize_mssr(image_data, saliency_masks, [0 0 0 1], region_params);
       
       type = 1; % distinguish region's types
   
      % open the saved regions
      [num_regions, features, saliency_masks] = mssr_open(features_filename{i}, regions_filename{1}, type);
    
      list_regions = [];     % display all regions
   
      scaling = 1;  % no scaling
      line_width = 2; % thickness of the line
      labels = 0; % no region's labels
   
      col_ellipse = [];
      col_label = [];
    
      original = 0; % no original region's outline
    
      display_features(image_filename{i}, features_filename{i}, mask_filename, ...
		    regions_filename{i},...  
		    type, list_regions, scaling, labels, col_ellipse, ...
		    line_width, col_label, original);
      title('MSSR');
    end
       
end
 disp('--------------- The End ---------------------------------');

