% load_vis_saved_IsSameScene_OxFrei- loading and visualizing the results 
%               from the same scene testing for the OxFrei dataset
%**************************************************************************
% author: Elena Ranguelova, NLeSc
% date created: 10-04-2017
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% last modification date: 
% modification details: 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% NOTE: possible combinations detector + descriptor:
%       BIN + SMI, MSER + SURF
%**************************************************************************
% REFERENCES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% parameters
% execution parameters
verbose = true;
visualize = true;
visualize_matching_cost =  true;
visualize_transf_similarity = true;
visualize_dataset = true;
publish = false;

if publish
   % det_descr = 'BIN_SMI';
   % det_descr = 'MSER_SMI';
    det_descr = 'MSER_SURF';
else
    det_descr = input('Enter  detector + descriptor combination ([BIN_SMI|MSER_SURF|MSER_SMI]): ','s');
end

if ispc
    starting_path = fullfile('C:','Projects');
else
    starting_path = fullfile(filesep,'home','elena');
end
project_path = fullfile(starting_path, 'eStep','LargeScaleImaging');
sav_path = fullfile(project_path, 'Results', 'OxFrei','Comparision');

switch upper(det_descr)
    case 'BIN_SMI'
        sav_fname = fullfile(sav_path, '.mat');
    case 'MSER_SURF'
        sav_fname = fullfile(sav_path, 'test_IsSameScene_MSER_SURF_OxFrei_21-04-2017_10-24.mat');
    case 'MSER_SMI'
        sav_fname =fullfile(sav_path, '.mat');
    otherwise
        error('Unknown detector + descriptor combination!');
end

% load the saved results
load(sav_fname);

% unpack parameters from  a structure
v2struct(match_params);

% paths
data_path_or = fullfile(project_path, 'Data', 'OxFrei');
ext = '.png';
% data size
data_size = 189;
lab_step = 1;

%% visualize the test dataset
if visualize_dataset
    if verbose
        disp('Displaying the test dataset...');
    end
    display_oxfrei_dataset(data_path_or);
    pause(5);
end

%% visualize
if visualize
    gcmap = colormap(gray(256)); close;
    hcmap = colormap(hot); close;
    jcmap = colormap(jet); close;
    f1 = format_figure(is_same_all, 6, gcmap, ...
        [0 1], {'False','True'}, ...
        'Is the same scene? All pairs of OxFrei dataset.',...
        YLabels, lab_step);
    if visualize_matching_cost 
        f2 = format_figure(mean_costs, 6,jcmap, ...
            [], [], ...
            'Mean matching cost of all matches. All pairs of OxFrei dataset.',...
            YLabels, lab_step);
    end
    if visualize_transf_similarity
        f3 = format_figure(transf_sims, 6, hcmap, ...
            [-0.2:0.1:1.1], [-0.2:0.1:1.1], ...
            'Correlation between matches. All pairs of OxFrei dataset.',...
            YLabels, lab_step);
    end
end

