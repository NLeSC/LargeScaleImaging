% test_IsSameScene_imagePair_OxFrei- testing IsSameScene function for comparision if 2
%                   images are of the same scene (OxFrei dataset)
%**************************************************************************
% author: Elena Ranguelova, NLeSc
% date created: 16-11-2016
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% last modification date: 
% modification details: 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% NOTE: see also test_IsSameScene_imagePair_Oxford
%**************************************************************************
% REFERENCES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% parameters

% execution parameters
verbose = true;
visualize = true;
visualize_dataset = false;
visualize_test = true;
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
area_factor = 0.0002;
% pack to a structure
cc_params = v2struct(conn, list_props, area_factor);

% matching parameters
match_metric = 'ssd';
match_thresh = 1;
max_ratio = 1;
max_dist = 2;
cost_thresh = 0.02;
transf_sim_thresh = 0;
% pack to a structure
match_params = v2struct(match_metric, match_thresh, max_ratio, max_dist, ...
    cost_thresh, transf_sim_thresh);


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
data_path_or = 'C:\Projects\eStep\LargeScaleImaging\Data\OxFrei\';
if binarized
    data_path_bin = 'C:\Projects\eStep\LargeScaleImaging\Results\OxFrei\';
    ext = '_bin.png';
else
    ext  ='.png';
end


disp('**********************************************************************************');
disp('  Demo script for determining if 2 images are of the same scene. (OxFrei dataset) ');
disp('**********************************************************************************');


%% visualize the test dataset
if visualize_dataset
    if verbose
        disp('Displaying the test dataset...');
    end
    display_oxfrei_dataset(data_path_or);
    pause(5);    
end

%% load test data
test_cases = {'01_graffiti','02_freiburg_center', '03_freiburg_from_munster_crop',...
    '04_freiburg_innenstadt','05_cool_car', '06_freiburg_munster',...
    '07_graffiti','08_hall', '09_small_palace'};
% image one
disp('Possible test cases: 01_graffiti,02_freiburg_center, 03_freiburg_from_munster_crop'); 
disp('                     04_freiburg_innenstadt, 05_cool_car, 06_freiburg_munster');
disp('                     07_graffiti, 08_hall, 09_small_palace');
test_case_ind1 = input('Enter base test case index [1..9] for the first image: ','s');
test_case1 = char(test_cases{str2num(test_case_ind1)});
test_transf1 = input('Enter transformation [_original(no transf)|blur|lighting|scale|viewpoint]: ','s');

if strcmp(test_transf1,'_original')
    trans_deg1 = 0;
else
    trans_deg1 = input('Enter the transformation degree [1|2|3|4|5]: ');
end
% image two
test_case_ind2 = input('Enter base test case index [1..9] for the second image: ','s');
test_case2 = char(test_cases{str2num(test_case_ind2)});
test_transf2 = input('Enter transformation [_original(no transf)|blur|lighting|scale|viewpoint]: ','s');

if strcmp(test_transf2,'_original')
    trans_deg2 = 0;
else
    trans_deg2 = input('Enter the transformation degree [1|2|3|4|5]: ');
end
    

if verbose
   disp('Loading the 2 test images...');
   if binarized
       disp('Already binarized images are used.');
   end
end

if binarized
    test_path1 = fullfile(data_path_bin,test_case1);
    test_path2 = fullfile(data_path_bin,test_case2);
else
    test_path1 = fullfile(data_path_or,test_case1,'PNG');
    test_path2 = fullfile(data_path_or,test_case2,'PNG');
end

if trans_deg1 > 0
    trans_str1 = [num2str(test_transf1) num2str(trans_deg1)];
else
    trans_str1 = num2str(test_transf1);
end
if trans_deg2 > 0
    trans_str2 = [num2str(test_transf2) num2str(trans_deg2)];
else
    trans_str2 = num2str(test_transf2);
end

test_image1 = fullfile(test_path1,[trans_str1 ext]); 
test_image2 = fullfile(test_path2,[trans_str2 ext]); 

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
    subplot(121);imshow(im1); 
    title(['First image: ' test_case1 '- ' trans_str1],'Interpreter','None');
    subplot(122);imshow(im2); 
    title(['Second image: ' test_case2 '- ' trans_str2],'Interpreter','None');
    
    pause(0.5);
end

%% compare if the 2 images show the same scene
if verbose
   disp('Comparing the 2 test images...');
end
disp('*****************************************************************');
[is_same, num_matches, mean_cost, transf_sim] = IsSameScene(im1, im2,...
                       moments_params, cc_params, match_params,...
                       vis_params, exec_params);

if verbose
   disp('*****************************************************************');
   disp('                                     DONE.                       ');
   disp('*****************************************************************');
end