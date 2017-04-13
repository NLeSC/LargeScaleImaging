% test_IsSameScene_BIN_SMI_imagePair_Oxford- testing IsSameScene_BIN_SMI
%                   function for comparision if 2
%                   images are of the same scene (Oxford dataset)
%**************************************************************************
% author: Elena Ranguelova, NLeSc
% date created: 20-10-2016
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% last modification date: 10 April 2017
% modification details: the CC version of SMIdescriptor is used now 
% last modification date: 21 March 2017
% modification details: default preliminary binarization is not alowed
% last modification date: 16 November 2016
% modification details: renamed the script
% last modification date: 14 November 2016
% modification details: removed matches_ratio_thresh parameter
% last modification date: 11 November 2016
% modification details: max ratio is now 1 to perform symmetric matching
% last modification date: 4 November 2016
% modification details: transformation distance replaced with similarity
% last modification date: 21-10-2016
% modification details: visualizations added
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% NOTE: generalization of test_matching_SMI_desc_affine_dataset
%**************************************************************************
% REFERENCES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% parameters

publish = false;
% execution parameters
verbose = true;
visualize = true;
visualize_dataset = false;
visualize_test = false;
area_filtering = true;  % if true, perform area filterring on regions
matches_filtering = true; % if true, perform filterring on the matches
% pack to a structure
exec_params = v2struct(verbose,visualize, area_filtering, matches_filtering);

binarized = true;

% moments parameters
order = 4;
coeff_file = 'afinvs4_19.txt';
max_num_moments = 16;
% pack to a structure
moments_params = v2struct(order,coeff_file, max_num_moments);

% CC parameters
conn = 8;
list_props = {'Area','Centroid','MinorAxisLength','MajorAxisLength',...
    'Eccentricity','Solidity'};
area_factor = 0.0002; %0.0005;
% pack to a structure
cc_params = v2struct(conn, list_props, area_factor);

% matching parameters
match_metric = 'ssd';
match_thresh = 1;
max_ratio = 1;
max_dist = 8;
conf=95;
max_num_trials = 1000;
cost_thresh = 0.025;
transf_sim_thresh = 0.25;
num_sim_runs = 30;
% pack to a structure
match_params = v2struct(match_metric, match_thresh, max_ratio, max_dist, ...
    conf, max_num_trials, cost_thresh, transf_sim_thresh, num_sim_runs);


% visualization parameters
if visualize
    if matches_filtering
        sbp1 = (241);
        sbp1_f = (242);
        sbp1_m = (243);
        sbp1_fm = (244);
        sbp2 = (245);
        sbp2_f = (246);
        sbp2_m = (247);
        sbp2_fm = (248);
    else
        sbp1 = (231);
        sbp1_f = (232);
        sbp1_m = (233);
        sbp1_fm = [];
        sbp2 = (234);
        sbp2_f = (235);
        sbp2_m = (236);
        sbp2_fm = [];
    end
    offset_factor = 0.25;
    % pack to a structure
    vis_params = v2struct(sbp1, sbp1_f, sbp1_m, sbp1_fm,...
        sbp2, sbp2_f, sbp2_m, sbp2_fm, offset_factor);
else
    vis_params = [];
end

% paths
if ispc
    starting_path = fullfile('C:','Projects');
else
    starting_path = fullfile(filesep,'home','elena');
end
project_path = fullfile(starting_path, 'eStep','LargeScaleImaging');
data_path_or = fullfile(project_path , 'Data', 'AffineRegions');
ext_or  ='.png';
if binarized
    data_path_bin = fullfile(project_path , 'Results', 'AffineRegions');
    ext_bin = '_bin.png';
end

disp('******************************************************************************************************');
disp('  Demo script for determining if 2 images are of the same scene (smart binarization + SMI descriptor). ');
disp('******************************************************************************************************');


%% visualize the test dataset
if visualize_dataset
    if verbose
        disp('Displaying the test dataset...');
    end
    display_oxford_dataset_structured(data_path_or);
    pause(5);
end

%% load test data

if publish
    disp('Enter base test case [graffiti|leuven|boat|bikes] for the first image: ');
    disp('Enter the transformation degree [1(no transformation)|2|3|4|5|6]: ');
    test_case1 = 'leuven'; trans_deg1 = 1;
    test_case1 = 'graffiti'; trans_deg1 = 1;
    test_case1 = 'boat'; trans_deg1 = 3;
    test_case1 = 'bikes'; trans_deg1 = 1;
    test_case1 = 'bikes'; trans_deg1 = 2;
    test_case1 = 'boat'; trans_deg1 = 2;
    test_case1 = 'graffiti'; trans_deg1 = 4;
    test_case1 = 'leuven'; trans_deg1 = 2;
    
    disp([test_case1 num2str(trans_deg1)]);
    
    disp('Enter base test case [graffiti|leuven|boat|bikes] for the second image: ');
    disp('Enter the transformation degree [1(no transformation)|2|3|4|5|6]: ');
    test_case2 = 'leuven'; trans_deg2 = 4;
    test_case2 = 'graffiti'; trans_deg2 = 3;
    test_case2 = 'boat'; trans_deg2 = 5;
    test_case2 = 'bikes'; trans_deg2 = 6;
    test_case2 = 'boat'; trans_deg2 = 1;
    test_case2 = 'leuven'; trans_deg2 = 3;
    test_case2 = 'boat'; trans_deg2 = 4;
    est_case2 = 'bikes'; trans_deg2 = 2;
    disp([test_case2 num2str(trans_deg2)]);
    
else
    % image one
    test_case1 = input('Enter base test case [graffiti|leuven|boat|bikes] for the first image: ','s');
    trans_deg1 = input('Enter the transformation degree [1(no transformation)|2|3|4|5|6]: ');
    % image two
    test_case2 = input('Enter base test case [graffiti|leuven|boat|bikes] for the second image: ','s');
    trans_deg2 = input('Enter the transformation degree [1(no transformation)|2|3|4|5|6]: ');
    
end

if verbose
    disp('Loading the 2 test images...');
    if binarized
        disp('Already binarized images are used.');
    end
end

test_path1 = fullfile(data_path_or,test_case1);
test_path2 = fullfile(data_path_or,test_case2);

test_image1 = fullfile(test_path1,[test_case1 num2str(trans_deg1) ext_or]);
test_image2 = fullfile(test_path2,[test_case2 num2str(trans_deg2) ext_or]);

im1 = imread(test_image1); im2 = imread(test_image2);
bw1 = []; bw2 = [];

if binarized
    test_bin_path1 = fullfile(data_path_bin,test_case1);
    test_bin_path2 = fullfile(data_path_bin,test_case2);
    test_bin_image1 = fullfile(test_bin_path1,[test_case1 num2str(trans_deg1) ext_bin]);
    test_bin_image2 = fullfile(test_bin_path2,[test_case2 num2str(trans_deg2) ext_bin]);
    bw1 = imread(test_bin_image1); bw2 = imread(test_bin_image2);
end

% visualize the choice
if visualize_test
    if verbose
        disp('Displaying the test images');
    end;
    fig_scrnsz = get(0, 'Screensize');
    offset = 0.25 * fig_scrnsz(4);
    fig_scrnsz(2) = fig_scrnsz(2) + offset;
    fig_scrnsz(4) = fig_scrnsz(4) - offset;
    ff = figure; set(gcf, 'Position', fig_scrnsz);
    subplot(121);imshow(im1); title(['First image: ' test_case1 num2str(trans_deg1)]);
    subplot(122);imshow(im2); title(['Second image: ' test_case2 num2str(trans_deg2)]);
    
    pause(0.5);
end

%% compare if the 2 images show the same scene
if verbose
    disp('Comparing the 2 test images...');
end
disp('*****************************************************************');
if not(binarized)
    if verbose
        disp('Data-driven binarization 1 (before comparision)...');
    end
    [bw1,~] = data_driven_binarizer(im1);
    if verbose
        disp('Data-driven binarization 2 (before comparision)...');
    end
    [bw2,~] = data_driven_binarizer(im2);
end

[is_same, num_matches, mean_cost, transf_sim] = ...
    IsSameScene_BIN_SMI(im1, im2,...
    bw1,bw2, ...
    moments_params, cc_params, ...
    match_params,...
    vis_params, exec_params);

if verbose
    disp('***********************   DONE   ************************');
end
