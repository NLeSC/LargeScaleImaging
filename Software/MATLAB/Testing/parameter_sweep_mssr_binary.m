% parameter_sweep_mssr_binary.m- script to test the MSSR detector with
%                                different parameters
%**************************************************************************
% author: Elena Ranguelova, NLeSc
% date created: 30-04-2015
% last modification date:
% modification details: 
%**************************************************************************
%% parmaters
interactive = false;
visualize = false;

%% image filename
if interactive 
    image_filename = input('Enter the test image filename: ','s');
else
    image_filename = fullfile('home','elena','eStep','LargeScaleImaging',...
        'Data','Synthetic','Binary','BasicSaliency.png');
end

%% load the image 
image_data = logical(imread(image_filename));


%% set up MSSR parameters
if interactive
    saliency_types(1) = input('Detect "holes"? [0/1]: ');
    saliency_types(2) = input('Detect "islands"? [0/1]: ');
    saliency_types(3) = input('Detect "indentations"? [0/1]: ');
    saliency_types(4) = input('Detect "protrusions"? [0/1]: ');
    SE_size_factor = input('Enter the Structuring Element size factor: ');
    Area_factor = input('Enter the Connected Component size factor: ');
else
    saliency_types = [1 1 1 1];
end

%% parameter sweeps
Area_factor_sweep = (0.01:0.01:0.1);
SE_size_factor_sweep = (0.01:0.01:0.1);
%len = length(Area_factor_sweep);
len = length(SE_size_factor_sweep);%*length(Area_factor_sweep);
% visualize original image
nrows = 4; ncols = round(len/nrows);
f = figure; %subplot(nrows, ncols, 1); visualize_mssr_binary(image_data);

%% run the MSSR detector on the test image

%SE_size_factor = 0.05;
%Area_factor = 0.05;
for Area_factor = Area_factor_sweep
    f = figure;
    count=  0;
    for SE_size_factor = SE_size_factor_sweep

        disp(['Iteration: ', num2str(count)]);
        count = count +1;

        tic
        [saliency_masks] = mssr_binary(image_data, SE_size_factor,Area_factor, ...
            saliency_types, visualize);
        toc

        % visualize regions
        figure(f);subplot(nrows, ncols, count);visualize_mssr_binary(image_data, saliency_masks,...
            [1 1 1 1], Area_factor, SE_size_factor);
    end
end