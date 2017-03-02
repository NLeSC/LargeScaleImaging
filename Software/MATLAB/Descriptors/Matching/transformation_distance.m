% transformation_distance- 'transformation distance' between 2 images
% **************************************************************************
% [diff1, diff2, dist1, dist2, bw1_trans, bw2_trans] = transformation_distance(im1, im2, tform)
% author: Elena Ranguelova, NLeSc
% date created: 2 Mar 2017
% last modification date: 
% modification details: 
%**************************************************************************
% INPUTS:
% im1/2         images to have the distance between them
% tform         estimated (affine) transformation between im2 and im1
%               e.g. as returned from estimate_affine_tform
%**************************************************************************
% OUTPUTS:
% dist1/2       distance metric: 1 - corr2(im1/2, im2/1_trans)
% im1/2_trans   transformed im1/2; if im1/2 was color, it's converted to
%               gray and also the returned transformed image is gray
%**************************************************************************
% NOTES: 
%**************************************************************************
% EXAMPLES USAGE:
%
% see test_IsSameSceneStandard_imagePair_Oxford.m
%**************************************************************************
% REFERENCES:
%**************************************************************************
function [dist1, dist2, im1_trans, im2_trans] = transformation_distance(im1, im2, tform)

%% input parameters
if nargin < 3
    error('transformation_distance requires min. 3 input arguments!');
end

%% input parameters -> variables
[nrows1, ncols1, ndims1] = size(im1);
[nrows2, ncols2, ndims2] = size(im2);

if ndims1 == 3
    im1 = rgb2gray(im1);
end
if ndims2 == 3
    im2 = rgb2gray(im2);
end

%% initializations
im2_trans = zeros(nrows1, ncols1);
im1_trans = zeros(nrows2, ncols2);

%% computations
outputView = imref2d(size(im1));
im2_trans = imwarp(im2,tform,'OutputView',outputView);

invtform = invert(tform);
outputView = imref2d(size(im2));
im1_trans = imwarp(im1,invtform,'OutputView',outputView);

dist1 = 1 - corr2(im1, im2_trans);
dist2 = 1 - corr2(im2, im1_trans);

end
