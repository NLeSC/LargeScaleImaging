% test_mssr_binary.m- script to the binary MSSR detector
%**************************************************************************
% author: Elena Ranguelova, NLeSc
% date created: 28-04-2015
% last modification date:
% modification details: 
%**************************************************************************
%% parmaters
interactive = false;
visualize = true;

%% image filename
if interactive 
    image_filename = input('Enter the test image filename: ','s');
else
    image_filename = fullfile('home','elena','eStep','LargeScaleImaging',...
        'Data','Synthetic','Binary','BasicSaliency.png');
end

%% load the image 
image_data = logical(imread(image_filename));

% %% visualize 
% if visualize
%     f=figure;
%     subplot(1,2,1);
%     imshow(logical(image_data));
%     title('Original image');
% end

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
    SE_size_factor = 0.05;
    Area_factor = 0.02;
end

[saliency_masks] = mssr_binary(image_data, Area_factor, SE_size_factor,...
    saliency_types, visualize);
