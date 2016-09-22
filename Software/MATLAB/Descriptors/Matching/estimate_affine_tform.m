% estimate_affine_tform- estimate affine transformation between
%                           matched region's centroids
% **************************************************************************
% [tform, inl_point1, inl_points2, status] = estimate_affine_tform(matched_pairs, ...
%                                   stats_cc1, stats_cc2, max_dist)
% author: Elena Ranguelova, NLeSc
% date created: 22 Sep 2016
% last modification date: 
% modification details: 
%**************************************************************************
% INPUTS:
% matched_pairs  structure with fields "first" and "second" of the matched 
%                pairs of regions as returned by the matching function
% stats_cc1/2    structure with region properties (must have Centroid)
%                first/second region set
% max_dist       max distance from point to projection. For more info type
%                "help estimateGeometricTransfrom". Optional, default is 8.
%**************************************************************************
% OUTPUTS:
% tform         geometric transformation. Affine is assumed. For more info 
%               type "help estimateGeometricTransfrom".
% inl_points1/2 inlier points in image 1/2.
% status        status of the estimation. Can be 0.1 or 2.
%               0 = no error
%               1 = matched_pairs doesn't contain enough matches
%               2 = not enough inliers found.
%**************************************************************************
% NOTES: see estimateGeometricTransfrom function
%**************************************************************************
% EXAMPLES USAGE:
%
% see test_matching_SMI_desc_affine_dataset.m
%**************************************************************************
% REFERENCES:
%**************************************************************************
function [tform, inl_points1, inl_points2, status] = estimate_affine_tform(matched_pairs, ...
                                   stats_cc1, stats_cc2, max_dist)

%% input parameters
if nargin < 4
    max_dist =  8;
end
if nargin < 3
    error('check_affine_consistency requires min. 3 input argument!');
end

%% input parameters -> variables
centroids1 = cat(1,stats_cc1.Centroid);
centroids2 = cat(1,stats_cc2.Centroid);
indicies1 = cat(1,matched_pairs.first);
indicies2 = cat(1,matched_pairs.second);
%% initializations
matched_points1 = centroids1(indicies1,:);
matched_points2 = centroids2(indicies2,:);

%% computations
[tform, inl_points2, inl_points1, status]= estimateGeometricTransform(matched_points2,...
    matched_points1, 'affine','MaxDistance',max_dist);

end
