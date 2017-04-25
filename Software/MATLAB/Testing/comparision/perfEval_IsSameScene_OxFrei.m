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

if publish
   % det_descr = 'BIN_SMI';
   % det_descr = 'MSER_SMI';
    det_descr = 'MSER_SURF';
% else
%     det_descr = input('Enter  detector + descriptor combination ([BIN_SMI|MSER_SURF|MSER_SMI]): ','s');
end

%% load the predicted matrix
if ispc
    starting_path = fullfile('C:','Projects');
else
    starting_path = fullfile(filesep,'home','elena');
end
project_path = fullfile(starting_path, 'eStep','LargeScaleImaging');
sav_path = fullfile(project_path , 'Results', 'OxFrei','Comparision');

if publish
   switch upper(det_descr)
    case 'BIN_SMI'
        sav_fullname = fullfile(sav_path, '.mat');
    case 'MSER_SURF'
        sav_fullname = fullfile(sav_path, 'test_IsSameScene_MSER_SURF_OxFrei_21-04-2017_10-24.mat');
    case 'MSER_SMI'
        sav_fullname =fullfile(sav_path, '.mat');
    otherwise
        error('Unknown detector + descriptor combination!');
   end  
else
    sav_fname = input('Enter the OxFrei is same scene experiment results filename: ', 's');
    sav_fullname = fullfile(sav_path, sav_fname);
end

%% load the saved results
load(sav_fullname,'is_same_all','YLabels');
predicted = is_same_all;


%% compute performance measures
[eval_metrics] = perfEval_IsSameScene(predicted, scene_size, vis_eval, YLabels, lab_step, verbose);

