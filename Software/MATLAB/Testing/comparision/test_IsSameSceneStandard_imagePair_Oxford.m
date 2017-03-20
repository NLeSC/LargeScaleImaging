% test_IsSameSceneStandard_imagePair_Oxford- testing IsSameScene function for comparision if 2
%                   images are of the same scene (Oxford dataset) using
%                   IsSameSceneStandard
%**************************************************************************
% author: Elena Ranguelova, NLeSc
% date created: 23-02-2017
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% last modification date: 
% modification details: 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% NOTE: 
%**************************************************************************
% REFERENCES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% parameters

publish = false;
% execution parameters
verbose = false;
visualize = true;
visualize_dataset = false;
visualize_test = false;
matches_filtering = true; % if true, perform filterring on the matches
% pack to a structure
exec_params = v2struct(verbose,visualize, matches_filtering);

% matching parameters
match_metric = 'ssd';
match_thresh = 1;
max_ratio = 1;
max_dist = 10;
cost_thresh = 0.025;
%matches_ratio_thresh = 0.5;
transf_sim_thresh = -0.5;
% pack to a structure
match_params = v2struct(match_metric, match_thresh, max_ratio, max_dist, ...
    cost_thresh, transf_sim_thresh);

% visualization parameters
if visualize
    if matches_filtering
        sbp1 = (241);
        sbp1_d = (242);
        sbp1_m = (243);
        sbp1_fm = (244);
        sbp2 = (245);
        sbp2_d = (246);
        sbp2_m = (247);
        sbp2_fm = (248);
    else
        sbp1 = (231);
        sbp1_d = (232);
        sbp1_m = (233);
        sbp1_fm = [];
        sbp2 = (234);
        sbp2_d = (235);
        sbp2_m = (236);
        sbp2_fm = [];
    end
    offset_factor = 0.25;
    % pack to a structure
    vis_params = v2struct(sbp1, sbp1_d, sbp1_m, sbp1_fm,...
        sbp2, sbp2_d, sbp2_m, sbp2_fm, offset_factor);
else
    vis_params = [];
end

% paths
data_path_or = 'C:\Projects\eStep\LargeScaleImaging\Data\AffineRegions\';
ext  ='.png';


disp('******************************************************************************************************');
disp('  Demo script for determining if 2 images are of the same scene using standard detector + descriptor. ');
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
    %test_case1 = 'leuven'; trans_deg1 = 1;
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
%     test_case2 = 'boat'; trans_deg2 = 4;
%     test_case2 = 'bikes'; trans_deg2 = 2;
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
end

test_path1 = fullfile(data_path_or,test_case1);
test_path2 = fullfile(data_path_or,test_case2);

test_image1 = fullfile(test_path1,[test_case1 num2str(trans_deg1) ext]); 
test_image2 = fullfile(test_path2,[test_case2 num2str(trans_deg2) ext]); 

im1 = imread(test_image1); im2 = imread(test_image2);

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
[is_same, num_matches, mean_cost, transf_sim] = IsSameSceneStandard(im1, im2,...
                       match_params,...
                       vis_params, exec_params);

if verbose
   disp('*****************************************************************');
   disp('                                     DONE.                       ');
   disp('*****************************************************************');
end
