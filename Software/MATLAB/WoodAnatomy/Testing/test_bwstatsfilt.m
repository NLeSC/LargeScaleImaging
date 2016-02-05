% script to test the bwstatsfilt function
%% paths
data_path = '/home/elena/eStep/LargeScaleImaging/Data/Scientific/WoodAnatomy/LM pictures wood/PNG';
results_path ='/home/elena/eStep/LargeScaleImaging/Results/Scientific/WoodAnatomy/LM pictures wood';
detector  = 'DMSR';
test_case = 'Desmo';
[image_filenames, features_filenames, regions_filenames, regions_props_filenames] = ...
       get_wood_test_filenames(test_case, detector, data_path, results_path);
%% params   
i = 2;
stats_type = 'Eccentricity';
range = [0.90 1];
%% load
image_filename = char(image_filenames{i});
regions_filename = char(regions_filenames{i});
regions_props_filename = char(regions_props_filenames{i});
load(regions_filename);
load(regions_props_filename);
clear histograms regions_properties
bw = logical(saliency_masks);
clear saliency_masks
%% show
%imshow(bw);
%% run
[bw_filt, regions_idx, thresh] = bwstatsfilt( bw, statistics, stats_type, conn_comp, range);
clear conn_comp
%% show
figure;imshow(bw_filt);
disp('Region indicies: '); disp(regions_idx);
disp('Threshold values: '); disp(thresh);