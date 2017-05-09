% test_IsSameScene_BIN_SMI_imagePair_OxFrei- testing IsSameScene_BIN_SMI 
%                   function for comparision if 2
%                   images are of the same scene (OxFrei dataset)
%**************************************************************************
% author: Elena Ranguelova, NLeSc
% date created: 16-11-2016
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% last modification date: 21 March 2017
% modification details: default preliminary binarization is not alowed;
%                       binarization happens inside the script; added new
%                       parameters
% last modification date: 
% modification details: 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% NOTE: see also test_IsSameScene_imagePair_Oxford
%**************************************************************************
% REFERENCES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% parameters
[ exec_flags, exec_params, moments_params, cc_params, ...
    match_params, vis_params, paths] = config(mfilename, 'oxfrei');

v2struct(exec_flags)
v2struct(paths)

disp('********************************************************************************************************************************');
disp('  Demo script for determining if 2 images from the OxFrei dataset are of the same scene (smart binarization + SMI descriptor).  ');
disp('********************************************************************************************************************************');


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
    trans_deg1 = '';
else
    trans_deg1 = input('Enter the transformation degree [1|2|3|4|5]: ');
end
% image two
test_case_ind2 = input('Enter base test case index [1..9] for the second image: ','s');
test_case2 = char(test_cases{str2num(test_case_ind2)});
test_transf2 = input('Enter transformation [_original(no transf)|blur|lighting|scale|viewpoint]: ','s');

if strcmp(test_transf2,'_original')
    trans_deg2 = '';
else
    trans_deg2 = input('Enter the transformation degree [1|2|3|4|5]: ');
end
    

if verbose
   disp('Loading the 2 test images...');
   if binarized
       disp('Already binarized images are used.');
   end
end

test_path1_or = fullfile(data_path_or,test_case1,'PNG');
test_path2_or = fullfile(data_path_or,test_case2,'PNG');

if trans_deg1 > 0
    trans_str1 = [num2str(test_transf1) num2str(trans_deg1)];
 else
     trans_str1 = '_original';
end
if trans_deg2 > 0
    trans_str2 = [num2str(test_transf2) num2str(trans_deg2)];
 else
     trans_str2 = '_original';
end

test_image1 = fullfile(test_path1_or,[trans_str1 ext_or]); 
test_image2 = fullfile(test_path2_or,[trans_str2 ext_or]); 

im1 = imread(test_image1); im2 = imread(test_image2);
bw1 = []; bw2 = [];

if binarized
    test_bin_path1 = fullfile(data_path_bin,test_case1);
    test_bin_path2 = fullfile(data_path_bin,test_case2);
    test_bin_image1 = fullfile(test_bin_path1,[test_transf1 num2str(trans_deg1) ext_bin]);
    test_bin_image2 = fullfile(test_bin_path2,[test_transf2 num2str(trans_deg2) ext_bin]);
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
   disp('*****************************************************************');
   disp('                                     DONE.                       ');
   disp('*****************************************************************');
end
