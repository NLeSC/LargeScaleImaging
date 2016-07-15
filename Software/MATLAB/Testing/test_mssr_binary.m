% test_mssr_binary.m- script to test the binary MSSR detector
%**************************************************************************
% author: Elena Ranguelova, NLeSc
% date created: 28-04-2015
% last modification date: 11-03-2016
% modification details: Doesn't work currently! mssr_binary doesn't exist!
%**************************************************************************
%% paramaters
interactive = false;
visualize = false;

%% image filename
if ispc 
    starting_path = fullfile('C:','Projects');
else
    starting_path = fullfile(filesep,'home','elena');
end
if interactive 
    image_filename = input('Enter the test image filename: ','s');
else
    test_image = input('Enter test case: [binary_test|binary_shapes|basic_saliency|frog|device|butterfly|horseshoe]: ','s');
    switch lower(test_image)
        case 'binary_test'
            image_filename{1} = fullfile(starting_path,'eStep','LargeScaleImaging',...
            'Data','Synthetic','Binary','TestBinarySaliency.png');
            image_filename{2} = fullfile(starting_path,'eStep','LargeScaleImaging',...
            'Data','Synthetic','Binary','TestBinarySaliency_affine.png');
        case 'binary_shapes'
            image_filename{1} = fullfile(starting_path,'eStep','LargeScaleImaging',...
            'Data','Synthetic','Binary','binary_shapes.png');
        case 'basic_saliency'
            image_filename{1} = fullfile(starting_path,'eStep','LargeScaleImaging',...
            'Data','Synthetic','Binary','BasicSaliency.png');
            image_filename{2} = fullfile(starting_path,'eStep','LargeScaleImaging',...
            'Data','Synthetic','Binary','BasicSaliency_affine.png');
        case 'frog'
            image_filename{1} = fullfile(starting_path,'eStep','LargeScaleImaging',...
            'Data','BinaryShapes','Selected','frog-15_mod.gif');
            image_filename{2} = fullfile(starting_path,'eStep','LargeScaleImaging',...
            'Data','BinaryShapes','Selected','frog-15_mod_new.gif');
        case 'device'
            image_filename{1} = fullfile(starting_path,'eStep','LargeScaleImaging',...
           'Data','BinaryShapes','Selected','device9-15_mod.gif');   
        case 'butterfly'
            image_filename{1} = fullfile(starting_path,'eStep','LargeScaleImaging',...
            'Data','BinaryShapes','Selected','butterfly-2.gif');
            image_filename{2} = fullfile(starting_path,'eStep','LargeScaleImaging',...
            'Data','BinaryShapes','Selected','butterfly-1.gif'); 
        case 'horseshoe'
            image_filename{1} = fullfile(starting_path,'eStep','LargeScaleImaging',...
            'Data','BinaryShapes','Selected','horseshoe-11.gif');      
            image_filename{2} = fullfile(starting_path,'eStep','LargeScaleImaging',...
            'Data','BinaryShapes','Selected','horseshoe-19.gif'); 
    end


end

%% find out the number of test files
len = length(image_filename);

%% loop over all test images
for i = 1:len
    %% load the image
    image_data = logical(imread(image_filename{i}));


    %% run the MSSR detector on the test image
    if interactive
        saliency_types(1) = input('Detect "holes"? [0/1]: ');
        saliency_types(2) = input('Detect "islands"? [0/1]: ');
        saliency_types(3) = input('Detect "indentations"? [0/1]: ');
        saliency_types(4) = input('Detect "protrusions"? [0/1]: ');
        SE_size_factor = input('Enter the Structuring Element size factor: ');
        Area_factor = input('Enter the Connected Component size factor: ');
    else
        saliency_types = [1 1 1 1];
        SE_size_factor = 0.02;
        Area_factor = 0.03;
    end
    
    disp('Version 2008');
    tic
    [saliency_masks_2008] = mssr_binary_2008(image_data, Area_factor,...
        saliency_types, visualize);
    toc
    
    disp('Version 2015');
    tic
    [saliency_masks] = mssr_binary(image_data, SE_size_factor,Area_factor,...
        saliency_types, visualize);
    toc
    
    %% visualize
    % visualize original image
    f1 = figure; subplot(1, 2, 1); visualize_mssr_binary(image_data); axis on, grid on;
    % visualize regions
    figure(f1);subplot(1, 2, 2);visualize_mssr_binary(image_data, saliency_masks_2008,...
        [1 1 1 1], Area_factor, SE_size_factor); axis on; grid on;
    
     % visualize original image
    f2 = figure; subplot(1, 2, 1); visualize_mssr_binary(image_data); axis on, grid on;
    % visualize regions
    figure(f2);subplot(1, 2, 2);visualize_mssr_binary(image_data, saliency_masks,...
        [1 1 1 1], Area_factor, SE_size_factor); axis on; grid on;
end