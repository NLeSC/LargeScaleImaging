% regions_subset2binary- makes a binary image from a subset binary regions
% **************************************************************************
% [bw_out] = regions_subset2binary(bw_in, regions_ind, conn_comp) 
%
% author: Elena Ranguelova, NLeSc
% date created: 29 Sept 2016
% last modification date: 
% modification details: 
%**************************************************************************
% INPUTS:
% bw_in         binary image from which the subset of regions was derived
% regions_idx   indicies of subset of the regions
% [conn_comp]   connected components connectivity; Optional, default is 4
%**************************************************************************
% OUTPUTS:
% bw_out       binary image (logical) containing the subset of regions
%**************************************************************************
% NOTES: 
%**************************************************************************
% EXAMPLES USAGE: 
% 
% see test_regions_subset2binary.m
%**************************************************************************
% REFERENCES:
%**************************************************************************
function [bw_out] = regions_subset2binary(bw_in, regions_ind, conn)

%% input parameters
if nargin < 2
    error('regions_subset2binary requires min. 2 input arguments!');
end
if nargin < 3 
    conn = 4;
end

%% initializations
bw_out = bw_in;

%index = ones(num_regions,1);
L = bwlabel(bw_in, conn);
labels =  unique(L);

%% processing
for rl = 1:max(labels)
    if not(ismember(rl,regions_ind))
        bw_out(L==rl) = false;
    end
end
