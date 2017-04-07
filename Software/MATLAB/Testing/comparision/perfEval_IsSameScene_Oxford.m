% perfEval_IsSameScene_Oxford- performance evaluation of the same  scene
%                   tests for the Oxford dataset
% **************************************************************************
% author: Elena Ranguelova, NLeSc
% date created: 7 April 2017
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% last modification date: 
% modification details:
%**************************************************************************

%% parameters
vis_eval = false;
verbose = true;
scene_size = 6;

%% load the predicted matrix
sav_path = 'C:\Projects\eStep\LargeScaleImaging\Results\AffineRegions\Comparision\';
sav_fname('Enter the Oxford is same scene experiment results filename: ', 's');
sav_fullname = [sav_path sav_fname];
%% load the saved results
load(sav_fullname,'is_same_all','YLabels');
predicted = is_same_all;


%% compute performance measures
[eval_metrics] = perfEval_IsSameScene(predicted, scene_size, vis_eval, verbose);

