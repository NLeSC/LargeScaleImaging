% test_smssr.m- script to test the SMSSR detector
%**************************************************************************
% author: Elena Ranguelova, NLeSc
% date created: 27-05-2015
% last modification date: 29-05-2015
% modification details: 
%**************************************************************************
%% paramaters
interactive = false;
verbose = false;
visualize = true;
visualize_major = false;
visualize_minor = false;
lisa = true;


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
        case 'phantom'
            image_filename{1} = fullfile(starting_path,'eStep','LargeScaleImaging',...
            'Data','AffineRegions','Phantom','phantom.png');
            image_filename{2} = fullfile(starting_path,'eStep','LargeScaleImaging',...
            'Data','AffineRegions','Phantom','phantom_affine.png');
        case 'thorax'
            image_filename{1} = fullfile(starting_path,'eStep','LargeScaleImaging',...
            'Data','AffineRegions','CT','thorax1.jpg');
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
    end
    mask_filename =[];

end

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


disp('Version 2015');

region_params = [SE_size_factor Area_factor];
execution_params = [verbose visualize_major visualize_minor];
image_data = smssr_preproc(image_data, preproc_types);
[num_regions, features, saliency_masks] = smssr(image_data, ROI, ...
    num_levels, saliency_types, region_params, execution_params);
toc

%% visualize
if visualize
    figure;
    subplot(3,2,1); visualize_mssr(image_data);
    subplot(3,2,2);visualize_mssr(image_data, saliency_masks, saliency_types, region_params);
    subplot(3,2,3);visualize_mssr(image_data, saliency_masks, [1 0 0 0], region_params);
    subplot(3,2,4);visualize_mssr(image_data, saliency_masks, [0 1 0 0], region_params);
    subplot(3,2,5);visualize_mssr(image_data, saliency_masks, [0 0 1 0], region_params);
    subplot(3,2,6);visualize_mssr(image_data, saliency_masks, [0 0 0 1], region_params);
end

     code with results
     
end

