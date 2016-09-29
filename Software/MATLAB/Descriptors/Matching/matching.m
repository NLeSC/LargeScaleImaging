% matching-  descriptos matching
% **************************************************************************
% [matched_pairs, match_cost, matched_ind, num_matches] = matching(descr1, descr2, ...
%                                   metric, match_thresh, max_ratio, unique, ...
%                                   filtered, ind1, ind2)
% author: Elena Ranguelova, NLeSc
% date created: 22 Sep 2016
% last modification date: 
% modification details: 
%**************************************************************************
% INPUTS:
% descr1/2      2D arrays with descriptos for region/point to be matched
% [metric]      matching metric.  Optional. Can be 'SAD' or 'SSD' (default).
%               SAD = Sum of abs. differences, SSD = Sum of squared differences.  
% [match_thresh] matching threshold. For more info type "help matchFeatures".
%               Optional, default is 1.
% [max_ratio]   Ratio threshold. For more info type "help matchFeatures".
%               Optional, default is 0.75.
% [unique]      Unique matches. For more info type "help matchFeatures".
%               Optional, default is true.
% [filtered]    Boolean flag indicating weather the original set of regions/points
%               represented by the descriptors have been filtered
%               (decimated). Optional, default is true.
% [ind1/2]      If filtered is true, the indicies of the filtred regions/points.
%               Optional, no default.
%**************************************************************************
% OUTPUTS:
% matched_pairs  structure with fields "first" and "second" of the matched 
%                pairs of regions/points
% match_cost     matching cost. For more info type "help matchFeatures".
% matched_ind    the indicies of the matched pairs in relation to the
%                input features/descriptors
% num_matches    number of matched region/point pairs
%**************************************************************************
% NOTES:
% see CVS Toolbox's matchFeatures
%**************************************************************************
% EXAMPLES USAGE:
% see test_matching_SMI_desc_affine_dataset.m
%**************************************************************************
% REFERENCES:
%**************************************************************************
function [matched_pairs, match_cost, matched_ind, num_matches] = matching(descr1, descr2, ...
                                  metric, match_thresh, max_ratio, unique, ...
                                  filtered, ind1, ind2)

%% input control
if nargin < 9 && filtered
    error('matching: the indicies of the second set of points/regions are expected!');
end
if nargin < 8 && filtered
    error('matching: the indicies of the first set of points/regions are expected!');
end
if nargin < 7 
    filtered = true;
end
if nargin < 6 
    unique = true;
end
if nargin < 5 
    max_ratio = 0.75;
end
if nargin < 4 
    match_thresh = 1;
end
if nargin < 3 
    metric = 'SSD';
end
if nargin < 2
    error('matching: the function expects minimum 2 input arguments- the arrays of decriptors/featurs to match!');
end

%% initializations
matched_pairs = struct();
matched_ind =[];
num_matches = 0;
match_cost = NaN;

%% computations
[matched_ind, match_cost] = matchFeatures(descr1, descr2,...
    'Metric',metric, 'MatchThreshold', match_thresh, ...
    'MaxRatio', max_ratio, 'Unique', unique);
num_matches = size(matched_ind,1);

if num_matches == 0
    disp('No matches found!');
    return
end

if filtered
    for i = 1:num_matches
        matched_pairs(i).first = ind1(matched_ind(i,1));
        matched_pairs(i).second = ind2(matched_ind(i,2));
    end
else
    for i = 1:num_matches
        matched_pairs(i).first = matched_ind(i,1);
        matched_pairs(i).second = matched_ind(i,2);
    end
end

