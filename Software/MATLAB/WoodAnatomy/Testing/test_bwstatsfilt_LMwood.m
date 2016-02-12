% test_regionprops_LMwood- testing the bw region filtering of LMwood data
%**************************************************************************
%
% author: Elena Ranguelova, NLeSc
% date created: 12 Febr 2016
% last modification date: 
% modification details: 
%% paths
data_path = '/home/elena/eStep/LargeScaleImaging/Data/Scientific/WoodAnatomy/LM pictures wood/PNG';
results_path ='/home/elena/eStep/LargeScaleImaging/Results/Scientific/WoodAnatomy/LM pictures wood';
detector  = 'DMSR';
test_case = 'Desmo';
[image_filenames, features_filenames, regions_filenames, regions_props_filenames] = ...
       get_wood_test_filenames(test_case, detector, data_path, results_path);

im_idx = 1;
%% load
image_filename = char(image_filenames{im_idx});
regions_filename = char(regions_filenames{im_idx});
regions_props_filename = char(regions_props_filenames{im_idx});
load(regions_filename);
load(regions_props_filename);
clear histograms regions_properties
bw = logical(saliency_masks);
clear saliency_masks

%% params
stats_types = {'RelativeArea'};
range  = [0.4 1]; % the top 10% ofthe Area
stats_values = cat(1,statistics.(char(stats_types{1})));
max_value  = max(stats_values(:));
lo_thr = range(1)*max_value;
hi_thr = range(2)*max_value;
logic_ops = {};
ranges = {[lo_thr hi_thr]}; %{[0.01 0.015]};

% stats_types = {'Orientation','Orientation','Eccentricity'};
% logic_ops = {'Or','AND'};
% ranges = {[-90 -60],[60 90],[0.8 1]};

%% show
imshow(bw);

%% run
[bw_filt, regions_idx, threshs] = bwstatsfilt(bw, statistics, stats_types, ...
    logic_ops, conn_comp, ranges);
clear conn_comp
%% show
figure;imshow(bw_filt);
%disp('Region indicies: '); disp(regions_idx);
%disp('Threshold values: '); disp(threshs);