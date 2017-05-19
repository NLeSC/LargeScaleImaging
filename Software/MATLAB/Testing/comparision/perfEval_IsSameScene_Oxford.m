% perfEval_IsSameScene_Oxford- performance evaluation of the same  scene
%                   tests for the Oxford dataset
% **************************************************************************
% author: Elena Ranguelova, NLeSc
% date created: 7 April 2017
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% last modification date: 18.05.2017
% modification details: adding BIN + SURF; using config
% last modification date: 24.04.2017
% modification details: intriduced detector + descriptor
%**************************************************************************

%% parameters
[ exec_flags, exec_params, ~, ~, ...
    ~, ~, paths] = config(mfilename, 'oxford');

v2struct(exec_flags);
v2struct(exec_params);
v2struct(paths);

publish = true; %overrride config in case it's used for experimental results generation
if publish
  %  det_descr = 'BIN_SMI_all';
  %  det_descr = 'BIN_SMI_filt';
    det_descr = 'BIN_SURF';
  %  det_descr = 'MSER_SMI';
  %  det_descr = 'MSER_SURF';
else   
    det_descr = input('Enter  detector + descriptor combination ([BIN_SURF|BIN_SMI_all|BIN_SMI_filt|MSER_SURF|MSER_SMI]): ','s');
end

%% load the predicted matrix
if ispc
    starting_path = fullfile('C:','Projects');
else
    starting_path = fullfile(filesep,'home','elena');
end
project_path = fullfile(starting_path, 'eStep','LargeScaleImaging');
sav_path = fullfile(project_path, 'Results', 'AffineRegions','Comparision');

if publish
    switch upper(det_descr)
        case 'BIN_SURF'
            sav_fullname =  fullfile(sav_path, 'test_IsSameScene_BIN_SURF_Oxford_10-05-2017_13-31.mat');
        case 'BIN_SMI_ALL'
            sav_fullname = fullfile(sav_path, 'test_IsSameScene_BIN_SMI_all_Oxford_10-05-2017_13-40.mat');
        case 'BIN_SMI_FILT'
            sav_fullname = fullfile(sav_path, 'test_IsSameScene_BIN_SMI_filt_Oxford_10-05-2017_16-05.mat');
        case 'MSER_SURF'
            sav_fullname = fullfile(sav_path, 'test_IsSameScene_MSER_SURF_Oxford_10-05-2017_10-25.mat');
        case 'MSER_SMI'
            sav_fullname =fullfile(sav_path, 'test_IsSameScene_MSER_SMI_Oxford_10-05-2017_10-46.mat');
        otherwise
            error('Unknown detector + descriptor combination!');
    end
else
    sav_fname = input('Enter the Oxford is same scene experiment results filename: ', 's');
    sav_fullname = fullfile(sav_path, sav_fname);
end

%% load the saved results
load(sav_fullname,'is_same_all','YLabels');
predicted = is_same_all;


%% compute performance measures
[eval_metrics] = perfEval_IsSameScene(predicted, scene_size, vis_eval, YLabels, lab_step, verbose);

