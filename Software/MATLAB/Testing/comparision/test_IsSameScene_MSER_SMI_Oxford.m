% test_IsSameScene_MSER_SMI_Oxford- testing IsSameScene_MSER_SMI for comparision if 2
%                   images are of the same scene for the Oxford dataset
%**************************************************************************
% author: Elena Ranguelova, NLeSc
% date created: 21-04-2017
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% last modification date: 
% modification details: 
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

% paths
if ispc
    starting_path = fullfile('C:','Projects');
else
    starting_path = fullfile(filesep,'home','elena');
end
project_path = fullfile(starting_path, 'eStep','LargeScaleImaging');
data_path_or = fullfile(project_path , 'Data', 'AffineRegions');
ext_or = '.png';

if sav
    sav_path = fullfile(project_path, 'Results', 'AffineRegions','Comparision');
    scripts_name = mfilename;
    format_dt = 'dd-mm-yyyy_HH-MM';
    sav_fname = generate_results_fname(sav_path, scripts_name, format_dt);
end

% data size
data_size = 24;

% pack to a structure
exec_params = v2struct(verbose,visualize, matches_filtering);

% moments parameters
order = 4;
coeff_file = 'afinvs4_19.txt';
max_num_moments = 16;
% pack to a structure
moments_params = v2struct(order,coeff_file, max_num_moments);

% CC parameters
list_props = {'Area','Centroid','MinorAxisLength','MajorAxisLength',...
    'Eccentricity','Solidity'};
% pack to a structure
cc_params = v2struct(list_props);

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
vis_params = [];

tic

%% initializations
is_same_all = zeros(data_size, data_size);
mean_costs = zeros(data_size, data_size);
transf_sims = zeros(data_size, data_size);
%% header
disp('***************************************************************************************************************');
disp('  Demo: are all pairs of images in the Oxford dataset of the same scene (using MSER detector + SMI descriptor)? ');
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
        test_image1 = fullfile(test_path1,[test_case1 num2str(trans_deg1) ext_or]);
        im1 = imread(test_image1);
       
        c = 0;
        for j = 1: numel(test_cases)
            test_case2 = char(test_cases{j});
            for trans_deg2 = 1:6
                c  = c+1;
                disp('----------------------------------------------------------------');
                disp([test_case2 num2str(trans_deg2)]);
               
                test_path2 = fullfile(data_path_or,test_case2);
                
                test_image2 = fullfile(test_path2,[test_case2 num2str(trans_deg2) ext_or]);
                im2 = imread(test_image2);
                
                %% compare if the 2 images show the same scene
                if r >= c
                    [is_same, num_matches, mean_cost, transf_sim] = IsSameScene_MSER_SMI(im1, im2,...
                         moments_params, cc_params, match_params, vis_params, exec_params);
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