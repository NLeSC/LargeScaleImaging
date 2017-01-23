% perfEval_IsSameScene_Oxford- performance evaluation of the same  scene
%                   tests for the Oxford dataset
%**************************************************************************
% author: Elena Ranguelova, NLeSc
% date created: 15-11-2016
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% last modification date: 
% modification details: 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% NOTE:
%**************************************************************************
% REFERENCES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% parameters
vis = true;
verbose = true;
%% compose the actual IsSame matrix

data_size = 24;
scene_batch_size = 6;
num_scenes = data_size/scene_batch_size;

actual = zeros(data_size);

for n =  1:num_scenes
    start_ind = (n-1) * scene_batch_size +1;
    end_ind = n * scene_batch_size;
    actual(start_ind:end_ind, start_ind:end_ind) = 1;
end

actual = actual';

%% load the predicted matrix
sav_path = 'C:\Projects\eStep\LargeScaleImaging\Results\AffineRegions\Comparision\';

sav_fname = [sav_path 'IsSameScene_Oxford_20161114_1435.mat'];
sav_fname = [sav_path 'IsSameScene_Oxford_20161114_1605.mat'];
sav_fname = [sav_path 'IsSameScene_Oxford_20161114_1752.mat'];
%% load the saved results
load(sav_fname,'is_same_all','YLabels');
predicted = is_same_all;

%% visualize
if vis
  gcmap = colormap(gray(256)); close;
  f1 = format_figure(actual, scene_batch_size, gcmap, ...
        [0 1], {'False','True'}, ...
        'Ground truth for the same scenes. All (structured) pairs of Oxford dataset.',...
        YLabels);  
  f2 = format_figure(predicted, scene_batch_size, gcmap, ...
        [0 1], {'False','True'}, ...
        'Predicted results for the same scenes. All (structured) pairs of Oxford dataset.',...
        YLabels);
end

%% compute performance measures
[eval_metrics] = perf_eval(actual, predicted);

if verbose

    disp(['Performance evaluation for results saved in: ' sav_fname]);
    v2struct(eval_metrics);
    disp(['True positives: ' num2str(tp)]);
    disp(['True negatives: ' num2str(tn)]);
    disp(['False positives: ' num2str(fp)]);
    disp(['False negatives: ' num2str(fn)]);
    disp(['Accuracy: ' num2str(accuracy)]);
    disp(['Precision: ' num2str(precision)]);
    disp(['Recall: ' num2str(recall)]);
end