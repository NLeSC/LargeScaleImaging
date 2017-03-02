% test_IsSameSceneStandard_Oxford- testing IsSameScene function for comparision if 2
%                   images are of the same scene for the Oxford dataset
%                   using IsSameSceneStandard
%**************************************************************************
% author: Elena Ranguelova, NLeSc
% date created: 27-10-2016
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% last modification date: 14 November 2016
% modification details: symmetric compuation of matricies
%                       removed matches_ratio_thresh parameter
% last modification date: 11 November 2016
% modification details: max ratio is now 1 to perform symmetric matching                       
% last modification date: 4 November 2016
% modification details: transformation distance replaced with similarity
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% NOTE:
%**************************************************************************
% REFERENCES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% parameters
% execution parameters
verbose = false;
visualize = false;
visualize_dataset = false;
visualize_test = false;
visualize_final = true;
area_filtering = true;  % if true, perform area filterring on regions
matches_filtering = true; % if true, perform filterring on the matches
sav = true;
if sav
    sav_path = 'C:\Projects\eStep\LargeScaleImaging\Results\AffineRegions\Comparision\';
    sav_fname = [sav_path 'IsSameScene_Oxford_20161114_1605.mat'];
    %sav_fname = [sav_path 'IsSameScene_Oxford_20161114_1752.mat'];
end
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
max_ratio = 1;
max_dist = 10;
cost_thresh = 0.021;
transf_sim_thresh = 0;
% pack to a structure
match_params = v2struct(match_metric, match_thresh, max_ratio, max_dist, ...
    cost_thresh, transf_sim_thresh);

% visualization parameters
vis_params = [];

% paths
data_path_or = 'C:\Projects\eStep\LargeScaleImaging\Data\AffineRegions';
if binarized
    data_path_bin = 'C:\Projects\eStep\LargeScaleImaging\Results\AffineRegions\';
    ext = '_bin.png';
else
    ext = '.png';
end

% data size
data_size = 24;

tic
%% initializations
is_same_all = zeros(data_size, data_size);
mean_costs = zeros(data_size, data_size);
transf_sims = zeros(data_size, data_size);
%% header
disp('*********************************************************************');
disp('  Demo: are all pairs of images of the same scene (Oxford dataset). ');
disp('*********************************************************************');


%% visualize the test dataset
if visualize_dataset
    if verbose
        disp('Displaying the test dataset...');
    end
    display_oxford_dataset_structured(data_path_or);
    pause(5);
end

%% loop over all test data
test_cases = {'graffiti', 'boat','leuven','bikes'};
r = 0;
for i = 1: numel(test_cases)
    test_case1 = char(test_cases{i});
    for trans_deg1 = 1:6
        r  = r + 1;
        disp('*****************************************************************');
        YLabels{r} = strcat(test_case1, num2str(trans_deg1), ': ', num2str(r));
        disp(YLabels{r});
        if binarized
            test_path1 = fullfile(data_path_bin,test_case1);
        else
            test_path1 = fullfile(data_path_or,test_case1);
        end
        test_image1 = fullfile(test_path1,[test_case1 num2str(trans_deg1) ext]);
        im1 = imread(test_image1);
        c = 0;
        for j = 1: numel(test_cases)
            test_case2 = char(test_cases{j});
            for trans_deg2 = 1:6
                c  = c+1;
                disp('----------------------------------------------------------------');
                disp([test_case2 num2str(trans_deg2)]);
                
                if binarized
                    test_path2 = fullfile(data_path_bin,test_case2);
                else
                    test_path2 = fullfile(data_path_or,test_case2);
                end
                
                test_image2 = fullfile(test_path2,[test_case2 num2str(trans_deg2) ext]);
                im2 = imread(test_image2);
                
                %% compare if the 2 images show the same scene
                if r >= c
                    [is_same, num_matches, mean_cost, transf_sim] = IsSameScene(im1, im2,...
                        moments_params, cc_params, match_params,...
                        vis_params, exec_params);
                    is_same_all(r,c) = is_same;
                    mean_costs(r,c) = mean_cost;
                    transf_sims(r,c) = transf_sim;                
                end
                
            end
        end
    end
end

%% fill up the remaning elements of the matricies
for r = 1: data_size
    for c =1: data_size
        if r < c            
            is_same_all(r,c) = is_same_all(c,r);
            mean_costs(r,c) = mean_costs(c,r);
            transf_sims(r,c) = transf_sims(c,r);
        end
    end
end
%% visualize
if visualize_final
    gcmap = colormap(gray(256)); close;
    hcmap = colormap(hot); close;
    jcmap = colormap(jet); close;
    f1 = format_figure(is_same_all, 6, gcmap, ...
        [0 1], {'False','True'}, ...
        'Is the same scene? All (structured) pairs of Oxford dataset.',...
        YLabels, []);
    f2 = format_figure(mean_costs, 6,jcmap, ...
        [], [], ...
        'Mean matching cost of all matches. All (structured) pairs of Oxford dataset.',...
        YLabels, []);
    f3 = format_figure(transf_sims, 6, hcmap, ...
        [], [], ...
        'Transformation between matches similarity (1- distance). All (structured) pairs of Oxford dataset.',...
        YLabels, []);
end

toc

%% save
if sav
   save(sav_fname, 'is_same_all', 'mean_costs', ...
       'transf_sims','YLabels', 'moments_params', ...
       'cc_params', 'match_params', 'exec_params'); 
end
%% footer
if verbose
    disp('*****************************************************************');
    disp('                                     DONE.                       ');
    disp('*****************************************************************');
end




