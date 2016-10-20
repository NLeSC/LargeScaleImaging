% test_IsSameScene- testing IsSameScene function for comparision if 2
%                   images are of the same scene
%**************************************************************************
% author: Elena Ranguelova, NLeSc
% date created: 20-10-2016
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% last modification date: 
% modification details: 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% NOTE: generalization of test_matching_SMI_desc_affine_dataset
%**************************************************************************
% REFERENCES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% parameters

% execution parameters
verbose = 1;
visualize = 0;
area_filtering = true; 
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
area_factor = 0.0005;
% pack to a structure
cc_params = v2struct(conn, list_props, area_factor);

% matching parameters
match_metric = 'ssd';
match_thresh = 1;
max_ratio = 0.75;
max_dist = 10;
cost_thresh = 0.025;
matches_ratio_thresh = 0.5;
transf_dist_thresh = 2;
% pack to a structure
match_params = v2struct(match_metric, match_thresh, max_ratio, max_dist, ...
    cost_thresh, matches_ratio_thresh, transf_dist_thresh);


% visualization parameters
if visualize
    if matches_filtering
        sbp_or = (241);
        sbp_or_l = (242);
        sbp_or_m = (243);
        sbp_or_fm = (244);
        sbp_a = (245);
        sbp_a_l = (246);
        sbp_a_m = (247);
        sbp_a_fm = (248);
    else
        sbp_or = (231);
        sbp_or_l = (232);
        sbp_or_m = (233);
        sbp_a = (234);
        sbp_a_l = (235);
        sbp_a_m = (236);
    end
end

% paths
if binarized
    data_path = 'C:\Projects\eStep\LargeScaleImaging\Results\AffineRegions\';
    ext = '_bin.png';
else
    data_path = 'C:\Projects\eStep\LargeScaleImaging\Data\AffineRegions\';
    ext = '.png';
end


if verbose
    disp('*****************************************************************');
    disp('  Demo script for determining if 2 images are of the same scene. ');
    disp('*****************************************************************');
end

%% visualize the test dataset
if visualize
    if verbose
        disp('Displaying the test dataset');
    end
    display_oxford_dataset_structured(data_path);
    if verbose
        disp('Paused: Press any key to continue...');
    end
    pause;    
end

%% load test data
% image one
test_case1 = input('Enter base test case [graffiti|leuven|boat|bikes] for the first image: ','s');
trans_deg1 = input('Enter the transformation degree [1(no transformation)|2|3|4|5|6]: ');

% image two
test_case2 = input('Enter base test case [graffiti|leuven|boat|bikes] for the second image: ','s');
trans_deg2 = input('Enter the transformation degree [1(no transformation)|2|3|4|5|6]: ');

if verbose
   disp('Loading the 2 test images...');
end

test_path1 = fullfile(data_path,test_case1);
test_path2 = fullfile(data_path,test_case2);

test_image1 = fullfile(test_path1,[test_case1 num2str(trans_deg1) ext]); 
test_image2 = fullfile(test_path2,[test_case2 num2str(trans_deg2) ext]); 

im1 = imread(test_image1); im2 = imread(test_image2);

%% visualize the choice
if visualize
    if verbose
        disp('Displaying the test dataset');
    end
    ff = figure; set(gcf, 'Position', get(0, 'Screensize'));
    subplot(121);imshow(im1); title(['First image: ' test_case1 num2str(trans_deg1)]);
    subplot(122);imshow(im2); title(['Second image: ' test_case2 num2str(trans_deg2)]);
    if verbose
        disp('Paused: Press any key to continue...');
    end
    pause; 
end

%% compare if the 2 images dhow the same scene
if verbose
   disp('Comparing the 2 test images...');
end
disp('*****************************************************************');
[is_same, matches_ratio, transf_dist] = IsSameScene(im1, im2,...
                        exec_params,moments_params, cc_params,match_params);

if verbose
   disp('*****************************************************************');
   disp('                                     DONE.                       ');
   disp('*****************************************************************');
end
