% IsSameScene-  comparing if 2 images are of the same scene
% **************************************************************************
% [is_same] = IsSameScene(im1, im2, exec_params,oments_params, cc_params,...
%                         match_params)
%
% author: Elena Ranguelova, NLeSc
% date created: 3 October 2016
% last modification date: 
% modification details: 
%**************************************************************************
% INPUTS:
% im1/2         teo input gray/color or binary images to be compared

%**************************************************************************
% OUTPUTS:
% is_same       binary flag, true if images are the same and false
%               otherwise
%**************************************************************************
% NOTES: 
%**************************************************************************
% EXAMPLES USAGE: 
% 
% see test_filter_regions.m
%**************************************************************************
% REFERENCES:
%**************************************************************************
function [bw_filt, regions_idx, threshs] = filter_regions(bw, region_props, ...
                                   prop_types, logic_ops, ranges, conn_comp)