% test_IsSameScene_MSER_SURF_imagePair_Oxford- testing IsSameScene_MSER_SURF
%                   function for comparision if 2
%                   images are of the same scene (Oxford dataset) 
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

[ exec_flags, exec_params, ~, ~, ...
    match_params, vis_params, paths] = config(mfilename, 'oxford');

v2struct(exec_flags)
v2struct(paths)


disp('******************************************************************************************************');
disp(' Demo: are 2 images from the Oxford dataset of the same scene (using MSER detector + SURF descriptor)?');
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

% image one
test_case1 = input('Enter base test case [graffiti|leuven|boat|bikes] for the first image: ','s');
trans_deg1 = input('Enter the transformation degree [1(no transformation)|2|3|4|5|6]: ');
% image two
test_case2 = input('Enter base test case [graffiti|leuven|boat|bikes] for the second image: ','s');
trans_deg2 = input('Enter the transformation degree [1(no transformation)|2|3|4|5|6]: ');


if verbose
    disp('Loading the 2 test images...');
end

test_path1 = fullfile(data_path_or,test_case1);
test_path2 = fullfile(data_path_or,test_case2);

test_image1 = fullfile(test_path1,[test_case1 num2str(trans_deg1) ext_or]);
test_image2 = fullfile(test_path2,[test_case2 num2str(trans_deg2) ext_or]);

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
[is_same, num_matches, mean_cost, transf_sim] = IsSameScene_MSER_SURF(im1, im2,...
    match_params,...
    vis_params, exec_params);

if verbose
    disp('***********************   DONE   ************************');
end
