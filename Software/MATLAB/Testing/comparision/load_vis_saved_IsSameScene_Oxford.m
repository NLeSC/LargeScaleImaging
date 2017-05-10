% load_vis_saved_IsSameScene_Oxford- loading and visualizing the results 
%               from the same scene testing for the Oxford dataset
%**************************************************************************
% author: Elena Ranguelova, NLeSc
% date created: 15-11-2016
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% last modification date: 10.05.2017
% modification details: adding BIN + SURF; using config
% last modification date: 24.04.2017
% modification details: adding MSER + SMI
% last modification date: 10.04.2017
% modification details: making it generic for the Oxford
%               dataset,independant on  combination detector + descriptor
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% NOTE: possible combinations detector + descriptor:
%       BIN + SMI, MSER + SURF
%**************************************************************************
% REFERENCES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% parameters
[ exec_flags, exec_params, ~, ~, ...
    ~, ~, paths] = config(mfilename, 'oxford');

v2struct(exec_flags);
v2struct(exec_params);
v2struct(paths);

if publish
    det_descr = 'BIN_SMI_all';
  %  det_descr = 'BIN_SMI_filt';
  %  det_descr = 'BIN_SURF';
  %  det_descr = 'MSER_SMI';
  %  det_descr = 'MSER_SURF';
else   
    det_descr = input('Enter  detector + descriptor combination ([BIN_SURF|BIN_SMI_all|BIN_SMI_filt|MSER_SURF|MSER_SMI]): ','s');
end

switch upper(det_descr)
    case 'BIN_SURF' 
        sav_fname =  fullfile(sav_path, 'test_IsSameScene_BIN_SURF_Oxford_10-05-2017_13-31.mat');
    case 'BIN_SMI_ALL'        
        sav_fname = fullfile(sav_path, 'test_IsSameScene_BIN_SMI_all_Oxford_10-05-2017_13-40.mat');
    case 'BIN_SMI_FILT'        
        sav_fname = fullfile(sav_path, 'test_IsSameScene_BIN_SMI_filt__Oxford_10-05-2017_16-05.mat');
    case 'MSER_SURF'
        sav_fname = fullfile(sav_path, 'test_IsSameScene_MSER_SURF_Oxford_10-05-2017_10-25.mat');
    case 'MSER_SMI'
        sav_fname =fullfile(sav_path, 'test_IsSameScene_MSER_SMI_Oxford_10-05-2017_10-46.mat');
    otherwise
        error('Unknown detector + descriptor combination!');
end

% load the saved results
load(sav_fname);

% unpack parameters from  a structure
v2struct(match_params);

%% visualize the test dataset
if visualize_dataset
    if verbose
        disp('Displaying the test dataset...');
    end
    display_oxford_dataset_structured(data_path_or);
    pause(5);
end

%% visualize
if visualize
    gcmap = colormap(gray(256)); close;
    hcmap = colormap(hot); close;
    jcmap = colormap(jet); close;
    f1 = format_figure(is_same_all, 6, gcmap, ...
        [0 1], {'False','True'}, ...
        'Is the same scene? All (structured) pairs of Oxford dataset.',...
        YLabels, []);
    if visualize_matching_cost 
        f2 = format_figure(mean_costs, 6,jcmap, ...
            [], [], ...
            'Mean matching cost of all matches. All (structured) pairs of Oxford dataset.',...
            YLabels, []);
    end
    if visualize_transf_similarity
        f3 = format_figure(transf_sims, 6, hcmap, ...
            [-0.2:0.1:1.1], [-0.2:0.1:1.1], ...
            'Correlation between matches. All (structured) pairs of Oxford dataset.',...
            YLabels, []);
    end
end

