% filter_matches-  filtering the matches obtained after matching
% **************************************************************************
% [filt_matched_pairs, filt_matched_ind, filt_match_cost, num_matches] = ...
%                       filter_matches(matched_pairs, matched_ind, ...
%                       match_cost, cost_thresh)
% author: Elena Ranguelova, NLeSc
% date created: 29 Sep 2016
% last modification date: 
% modification details: 
%**************************************************************************
% INPUTS:
% matched_pairs  structure with fields "first" and "second" of the matched 
%                pairs of regions/points as returned from matching.m
% matched_ind    the indicies of the matched pairs in relation to the
%                input features/descriptors
% match_cost     matching cost as returned from matching.m
%[cost_thresh]   cost threshold for filtering. All matches below the 
%                threshold are discarded. Optional, default is 0.015
%                (assuming 'SSD' matching metric)
%**************************************************************************
% OUTPUTS:
% filt_matched_pairs  structure with fields "first" and "second" of the 
%                     filtered matched pairs of regions/points
% filt_matched_ind    the filtered indicies of the matched pairs in relation 
%                     to the original input features/descriptors
% filt_match_cost     filtered matching cost. 
% num_matches         number of filtered matched region/point pairs
%**************************************************************************
% NOTES:
% see matching.m
%**************************************************************************
% EXAMPLES USAGE:
% see test_matching_SMI_desc_affine_dataset.m
%**************************************************************************
% REFERENCES:
%**************************************************************************
function [filt_matched_pairs, filt_matched_ind, filt_match_cost, num_matches] = filter_matches(matched_pairs, ...
          matched_ind,  match_cost, cost_thresh)
                   
%% input control
if nargin < 4 
    cost_thresh = 0.015;
end
if nargin < 3
    error('filter_matches: the function expects minimum 3 input arguments!');
end

%% initializations
filt_matched_pairs = struct();
filt_matched_ind =[];
counter = 0;
filt_match_cost = NaN;

%% computations
or_num_matches = size(matched_ind,1);

for i = 1:or_num_matches
    if match_cost(i) <= cost_thresh
        counter = counter +1;
        filt_matched_pairs(counter).first = matched_pairs(i).first;
        filt_matched_pairs(counter).second = matched_pairs(i).second;
        filt_matched_ind(counter,1) = matched_ind(i,1);
        filt_matched_ind(counter,2) = matched_ind(i,2);
        filt_match_cost(counter) = match_cost(i);        
    end
end

num_matches = counter;
                   