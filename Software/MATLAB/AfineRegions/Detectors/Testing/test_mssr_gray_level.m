% test_mssr_gray_level.m- script to test a single gray-level MSSR detector
%**************************************************************************
% author: Elena Ranguelova, NLeSc
% date created: 15-05-2015
% last modification date:
% modification details: 
%**************************************************************************
%% paramaters
interactive = false;
visualize = true;

%% image filename
if interactive 
    image_filename = input('Enter the test image filename: ','s');
else
    test_image = input('Enter test case: [boat]: ','s');
    switch lower(test_image)
        case 'boat'
            image_filename{1} = fullfile(filesep,'home','elena','eStep','LargeScaleImaging',...
            'Data','AffineRegions','boat','boat1.png');    
            image_filename{2} = fullfile(filesep,'home','elena','eStep','LargeScaleImaging',...
            'Data','AffineRegions','boat','boat2.png');
    end


end

%% find out the number of test files
len = length(image_filename);

%% loop over all test images
for i = 1:len
    %% load the image
    image_data = imread(image_filename{i});


    %% run the MSSR detector on the test image
    if interactive
        saliency_types(1) = input('Detect "holes"? [0/1]: ');
        saliency_types(2) = input('Detect "islands"? [0/1]: ');
        saliency_types(3) = input('Detect "indentations"? [0/1]: ');
        saliency_types(4) = input('Detect "protrusions"? [0/1]: ');
        gray_level = input('Enter the gray level: ');
        SE_size_factor = input('Enter the Structuring Element size factor: ');
        Area_factor = input('Enter the Connected Component size factor: ');
    else
        saliency_types = [1 1 1 1];
        gray_level = 128;
        SE_size_factor = 0.02;
        Area_factor = 0.03;
    end
    
%     disp('Version 2008');
%     tic
%     [saliency_masks_2008] = mssr_binary_2008(image_data, Area_factor,...
%         saliency_types, visualize);
%     toc
    
    disp('Version 2015');
    tic
    [saliency_masks] = mssr_gray_level(image_data, gray_level, SE_size_factor,Area_factor,...
        saliency_types, visualize);
    toc
    
    %% visualize
%     % visualize original image
%     f1 = figure; subplot(1, 2, 1); visualize_mssr_binary(image_data); axis on, grid on;
%     % visualize regions
%     figure(f1);subplot(1, 2, 2);visualize_mssr_binary(image_data, saliency_masks_2008,...
%         [1 1 1 1], Area_factor, SE_size_factor); axis on; grid on;
%     
     % visualize original image
    f2 = figure; subplot(1, 2, 1); visualize_mssr_gray_level(image_data); axis on, grid on;
    % visualize regions
    figure(f2);subplot(1, 2, 2);visualize_mssr_gray_level(image_data, saliency_masks,...
        [1 1 1 1], Area_factor, SE_size_factor); axis on; grid on;
end