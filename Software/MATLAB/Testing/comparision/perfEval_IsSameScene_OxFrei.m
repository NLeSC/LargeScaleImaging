% perfEval_IsSameScene_OxFrei- performance evaluation of the same  scene
%                   tests for the OxFrei dataset
% **************************************************************************
% author: Elena Ranguelova, NLeSc
% date created: 7 April 2017
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% last modification date: 
% modification details:
%**************************************************************************

%% parameters
vis_eval = true;
lab_step = 4;
verbose = true;
scene_size = 21;
publish = true;

%% load the predicted matrix
sav_path = 'C:\Projects\eStep\LargeScaleImaging\Results\OxFrei\Comparision\';
if publish
    sav_fname = 'test_IsSameScene_MSER_SURF_OxFrei_07-04-2017_17-19.mat';
else
    sav_fname = input('Enter the OxFrei is same scene experiment results filename: ', 's');
end
sav_fullname = [sav_path sav_fname];
%% load the saved results
load(sav_fullname,'is_same_all','YLabels');
predicted = is_same_all;


%% compute performance measures
[eval_metrics] = perfEval_IsSameScene(predicted, scene_size, vis_eval, YLabels, lab_step, verbose);

