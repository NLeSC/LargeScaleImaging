% IsSameScene-  comparing if 2 images are of the same scene
% **************************************************************************
% [is_same, matches_ratio, dist] = IsSameScene(im1, im2, ...
%                               exec_params, moments_params, cc_params,...
%                               match_params)
%
% author: Elena Ranguelova, NLeSc
% date created: 4 October 2016
% last modification date: 
% modification details: 
%**************************************************************************
% INPUTS:
% im1/2         the input gray/color or binary images to be compared
% exec_params   the execution parameters 
% moments_params parameters related to the moment invariants
% cc_params     parameters related to the connected components
% match_params   the matching parameters 
%**************************************************************************
% OUTPUTS:
% is_same       binary flag, true if images are the same and false
%               otherwise
% matches_ratio ratio of good matches and all matches
% dist          distance between the 2 images
%**************************************************************************
% NOTES: 
%**************************************************************************
% EXAMPLES USAGE: 
% 
% see test_filter_regions.m
%**************************************************************************
% REFERENCES:
%**************************************************************************
function [is_same, matches_ratio, dist] = IsSameScene(im1, im2,...
                        exec_params,oments_params, cc_params,match_params)