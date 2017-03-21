% test_IsSameScene_MSER_SURF_Oxford- testing IsSameScene_MSER_SURF for comparision if 2
%                   images are of the same scene for the Oxford dataset
%**************************************************************************
% author: Elena Ranguelova, NLeSc
% date created: 03-03-2017
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% last modification date: 21 March 2017
% modification details: fixed the logic and parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% NOTE:
%**************************************************************************
% REFERENCES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% parameters

% execution parameters
verbose = true;
visualize = false;
visualize_dataset = false;
visualize_test = false;
visualize_final = true;
matches_filtering = true; % if true, perform filterring on the matches
sav = true;
if sav
    sav_path = 'C:\Projects\eStep\LargeScaleImaging\Results\AffineRegions\Comparision\';
    sav_fname = [sav_path 'IsSameScene_MSER_SURF_Oxford_20172103_1145.mat'];
end
% pack to a structure
exec_params = v2struct(verbose,visualize, matches_filtering);

% matching parameters
match_metric = 'ssd';
match_thresh = 1;
max_ratio = 1;
max_dist = 10;
cost_thresh = 0.025;
transf_sim_thresh = 0.3;
% pack to a structure
match_params = v2struct(match_metric, match_thresh, max_ratio, max_dist, ...
    cost_thresh, transf_sim_thresh);

% visualization parameters
vis_params = [];

% paths
data_path_or = 'C:\Projects\eStep\LargeScaleImaging\Data\AffineRegions';
ext = '.png';

% data size
data_size = 24;

tic
%% initializations
is_same_all = zeros(data_size, data_size);
mean_costs = zeros(data_size, data_size);
transf_sims = zeros(data_size, data_size);
%% header
disp('***************************************************************************************************************');
disp('  Demo: are all pairs of images in the Oxford dataset of the same scene (using MSER detector + SURF descriptor)? ');
disp('***************************************************************************************************************');


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
        test_path1 = fullfile(data_path_or,test_case1);
        test_image1 = fullfile(test_path1,[test_case1 num2str(trans_deg1) ext]);
        im1 = imread(test_image1);
       
        c = 0;
        for j = 1: numel(test_cases)
            test_case2 = char(test_cases{j});
            for trans_deg2 = 1:6
                c  = c+1;
                disp('----------------------------------------------------------------');
                disp([test_case2 num2str(trans_deg2)]);
               
                test_path2 = fullfile(data_path_or,test_case2);
                
                test_image2 = fullfile(test_path2,[test_case2 num2str(trans_deg2) ext]);
                im2 = imread(test_image2);
                
                %% compare if the 2 images show the same scene
                if r >= c
                    [is_same, num_matches, mean_cost, transf_sim] = IsSameScene_MSER_SURF(im1, im2,...
                        match_params, vis_params, exec_params);
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
        'Similarity between transformed images based om matches. All (structured) pairs of Oxford dataset.',...
        YLabels, []);
end

toc

%% save
if sav
   save(sav_fname, 'is_same_all', 'mean_costs', ...
       'transf_sims','YLabels', 'match_params', 'exec_params'); 
end
%% footer
if verbose
    disp('************************   DONE.  ********************************');
end




