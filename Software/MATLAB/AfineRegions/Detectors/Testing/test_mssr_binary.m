% test_mssr_binary.m- script to test the binary MSSR detector
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
         'Data','Synthetic','Binary','shapes_holes.png');
%     image_filename = fullfile('home','elena','eStep','LargeScaleImaging',...
%         'Data','Synthetic','Binary','BasicSaliency.png');
%      image_filename = fullfile('home','elena','eStep','LargeScaleImaging',...
%          'Data','BinaryShapes','Selected','frog-15_mod.gif');
%      image_filename = fullfile('home','elena','eStep','LargeScaleImaging',...
%          'Data','BinaryShapes','Selected','frog-15_mod_new.gif');
%       image_filename = fullfile('home','elena','eStep','LargeScaleImaging',...
%           'Data','BinaryShapes','Selected','horseshoe-11.gif');
%        image_filename = fullfile('home','elena','eStep','LargeScaleImaging',...
%            'Data','BinaryShapes','Selected','device9-15_mod.gif');
%      image_filename = fullfile('home','elena','eStep','LargeScaleImaging',...
%          'Data','BinaryShapes','Selected','butterfly-2.gif');
end

%% load the image 
image_data = logical(imread(image_filename));


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

tic
[saliency_masks] = mssr_binary(image_data, SE_size_factor,Area_factor,...
    saliency_types, visualize);
toc
%% visualize
% visualize original image
f = figure; subplot(1, 2, 1); visualize_mssr_binary(image_data); axis on, grid on;
% visualize regions
figure(f);subplot(1, 2, 2);visualize_mssr_binary(image_data, saliency_masks,...
    [1 1 1 1], Area_factor, SE_size_factor); axis on; grid on;
