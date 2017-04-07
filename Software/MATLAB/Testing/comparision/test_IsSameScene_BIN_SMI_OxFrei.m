% test_IsSameScene_BIN_SMI_OxFrei- testing IsSameScene_BIN_SMI function
%                   for comparision if 2
%                   images are of the same scene for the OxFrei dataset
%**************************************************************************
% author: Elena Ranguelova, NLeSc
% date created: 23-01-2017
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% last modification date: 31 March 2017
% modification details: new parameters; multiple runs
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
visualize_final = true;
area_filtering = true;  % if true, perform area filterring on regions
matches_filtering = true; % if true, perform filterring on the matches
sav = true;

% paths
if ispc
    starting_path = fullfile('C:','Projects');
else
    starting_path = fullfile(filesep,'home','elena');
end
project_path = fullfile(starting_path, 'eStep','LargeScaleImaging');
data_path_or = fullfile(project_path , 'Data', 'OxFrei');
ext_or = '.png';
if binarized
    data_path_bin = fullfile(project_path , 'Results', 'OxFrei');
    ext_bin = '_bin.png';
end

if sav
    sav_path = fullfile(project_path, 'Results', 'OxFrei','Comparision');
    scripts_name = mfilename;
    format_dt = 'dd-mm-yyyy_HH-MM';
    sav_fname = generate_results_fname(sav_path, scripts_name, format_dt);
end

% data size
data_size = 189;

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
tick_step = 5;

tic
%% initializations
is_same_all = zeros(data_size, data_size);
mean_costs = zeros(data_size, data_size);
transf_sims = zeros(data_size, data_size);
%% header
disp('*********************************************************************');
disp('  Demo: are all pairs of OxFrei images of the same scene (BIN + SMI).');
disp('*********************************************************************');


%% visualize the test dataset
if visualize_dataset
    if verbose
        disp('Displaying the test dataset (needs 3 figure windows)...');
    end
    display_oxfrei_dataset(data_path_or);
    pause(5);
end

%% loop over all test data
test_cases = {'01_graffiti','02_freiburg_center', '03_freiburg_from_munster_crop',...
    '04_freiburg_innenstadt','05_cool_car', '06_freiburg_munster',...
    '07_graffiti','08_hall', '09_small_palace'};
test_cases = {'01_graffiti'};
r = 0;
for i = 1: numel(test_cases)
    test_case1 = char(test_cases{i});
    test_path1 = fullfile(data_path_or, test_case1, 'PNG');
    
    bin_path1 = fullfile(data_path_bin, test_case1);
    [image_fnames1, bin_fnames1] = get_bin_filenames(test_path1, bin_path1);
    %     if binarized
    %         image_fnames1 = bin_fnames1;
    %     end
    
    for ind1 = 1: numel(image_fnames1)
        r  = r + 1;
        disp('*****************************************************************');
        
        test_image1 = char(image_fnames1{ind1});
        [~,name1,~] = fileparts(test_image1);
        YLabels{r} = strcat(test_case1, num2str(ind1), ': ', name1, ': ', num2str(r));
        disp(YLabels{r});
        
        im1 = imread(test_image1); bw1=[];
        if binarized            
            test_bin_image1 = char(bin_fnames1{ind1});
            bw1 = imread(test_bin_image1);
        end
        
        c = 0;
        for j = 1: numel(test_cases)
            test_case2 = char(test_cases{j});
            data_path2 = fullfile(data_path_or, test_case2, 'PNG');
            bin_path2 = fullfile(data_path_bin, test_case2);
            [image_fnames2, bin_fnames2] = get_bin_filenames(data_path2, bin_path2);
            %             if binarized
            %                 image_fnames2 = bin_fnames2;
            %             end
            
            for ind2 = 1:numel(image_fnames2)
                c  = c+1;
                %disp('----------------------------------------------------------------');
                test_image2 = char(image_fnames2{ind2});
                im2 = imread(test_image2); bw2 = [];
                if binarized                    
                    test_bin_image2 = char(bin_fnames2{ind2});
                    bw2 = imread(test_bin_image2);
                end
                %% compare if the 2 images show the same scene
                if r >= c
                    [is_same, num_matches, mean_cost, transf_sim] = ...
                        IsSameScene_BIN_SMI(im1, im2, bw1, bw2, ...
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
    f1 = format_figure(is_same_all, 21, gcmap, ...
        [0 1], {'False','True'}, ...
        'Is the same scene? All pairs of OxFrei dataset.',...
        YLabels, tick_step);
    f2 = format_figure(mean_costs, 21,jcmap, ...
        [], [], ...
        'Mean matching cost of all matches. All pairs of OxFrei dataset.',...
        YLabels, tick_step);
    f3 = format_figure(transf_sims, 21, hcmap, ...
        [], [], ...
        'Transformation between matches similarity. All pairs of OxFrei dataset.',...
        YLabels, tick_step );
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




