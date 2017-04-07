% perfEval_IsSameScene- performance evaluation of the same scene experiemnts
% **************************************************************************
% [eval_metrics] = perfEval_IsSameScene(predicted, scene_size, vis, labels, verbose)
%
% author: Elena Ranguelova, NLeSc
% date created: 7 April 2016
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% last modification date: 
% modification details:
%**************************************************************************
% INPUTS:
% predicted     predicted matrix
% scene_size    number of images per scene (dataset assumed made of
%               different scenes and equal number of trasnfornations per scene
% vis           visualization flag, default is [false]
% labels        figure labels
% verbose       verbose flag, default is [true]
%**************************************************************************
% OUTPUTS:
% eval_metrics  structure with all performance evaluation metrics:
%  Accuracy, Sensitivity,Specificity, Precision, Recall, F-Measure, G-mean   
%**************************************************************************
% NOTES: 
%**************************************************************************
% EXAMPLES USAGE:
%
% see perfEval_IsSameScene_Oxford.m
%**************************************************************************
% REFERENCES:
%**************************************************************************
function [eval_metrics] = perfEval_IsSameScene(predicted, scene_size, vis, labels, verbose)

%% input control
if nargin < 3
    verbose = true;
end
if nargin < 3
    vis = false;
end
if nargin < 2
    error('perfEval_IsSameScene requires 2 input arguments!');
end

%% compose the actual IsSame matrix

data_size = size(predicted,1); % predicted is assumed symmetric and sqaure!
num_scenes = data_size/scene_size;

actual = zeros(data_size);

for n =  1:num_scenes
    start_ind = (n-1) * scene_size +1;
    end_ind = n * scene_size;
    actual(start_ind:end_ind, start_ind:end_ind) = 1;
end

actual = actual';

%% visualize
if vis
  gcmap = colormap(gray(256)); close;
  f1 = format_figure(actual, scene_size, gcmap, ...
        [0 1], {'False','True'}, ...
        'Ground truth for the same scenes. All (structured) pairs of Oxford dataset.',...
        labels, []);  
  f2 = format_figure(predicted, scene_size, gcmap, ...
        [0 1], {'False','True'}, ...
        'Predicted results for the same scenes. All (structured) pairs of Oxford dataset.',...
        labels, []);
end

%% compute performance measures
[eval_metrics] = perf_eval(actual, predicted);

if verbose

    disp(['Performance evaluation results: ']);
    v2struct(eval_metrics);
    disp(['True positives: ' num2str(tp)]);
    disp(['True negatives: ' num2str(tn)]);
    disp(['False positives: ' num2str(fp)]);
    disp(['False negatives: ' num2str(fn)]);
    disp(['Accuracy: ' num2str(accuracy)]);
    disp(['Precision: ' num2str(precision)]);
    disp(['Recall: ' num2str(recall)]);
end