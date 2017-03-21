% perf_eval-  evaluates the performance of a classification model 
% **************************************************************************
% [eval_metrics] = perf_eval(actual, predicted)
%
% author: Elena Ranguelova, NLeSc
% date created: 15 November 2016
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% last modification date: 
% modification details:
%**************************************************************************
% INPUTS:
% actual        ground truth matrix
% predicted     predicted matrix
%**************************************************************************
% OUTPUTS:
% eval_metrics  structure with all performance evaluation metrics:
%  Accuracy, Sensitivity,Specificity, Precision, Recall, F-Measure, G-mean   
%**************************************************************************
% NOTES: based on Evaluate from MATLAB file exchange
% https://nl.mathworks.com/matlabcentral/fileexchange/
% 37758-performance-measures-for-classification
%**************************************************************************
% EXAMPLES USAGE:
%
% see perfEval_IsSameScene_BIN_SMI_Oxford.m
%**************************************************************************
% REFERENCES:
% see https://en.wikipedia.org/wiki/Sensitivity_and_specificity
%**************************************************************************
function [eval_metrics] = perf_eval(actual, predicted)

%% input control
if nargin < 2
    error('perf_eval requires 2 input matricies actual and predicted');
end

%% processing
idx = (actual()==1);

p = length(actual(idx));
n = length(actual(~idx));
N = p+n;

% basic counts
tp = sum(actual(idx) == predicted(idx));
tn = sum(actual(~idx) == predicted(~idx));
fp = n-tn;
fn = p-tp;

% rates
tp_rate = tp/p;
tn_rate = tn/n;

accuracy = (tp+tn)/N;
sensitivity = tp_rate;
specificity = tn_rate;
precision = tp/(tp+fp);
recall = sensitivity;
f_measure = 2*((precision*recall)/(precision + recall));
gmean = sqrt(tp_rate*tn_rate);

%% pack into a tructure
eval_metrics = v2struct(tp, tn, fp, fn, accuracy, sensitivity, specificity,...
    precision, recall, f_measure, gmean);
