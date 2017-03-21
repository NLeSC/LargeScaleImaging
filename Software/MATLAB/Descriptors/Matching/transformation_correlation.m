% transformation_correlation- 'transformation correlation' between 2 images
% **************************************************************************
% [correl1, correl2, bw1_trans, bw2_trans] = transformation_correlations(im1, im2, tform)
% author: Elena Ranguelova, NLeSc
% date created: 21 Mar 2017
% last modification date: 
% modification details: 
%**************************************************************************
% INPUTS:
% im1/2         images to have the distance between them
% tform         estimated (affine) transformation between im2 and im1
%               e.g. as returned from estimate_affine_tform
%**************************************************************************
% OUTPUTS:
% correl1/2     correlationbetween im1/2: corr2(im1/2, im2/1_trans)
% im1/2_trans   transformed im1/2; if im1/2 was color, it's converted to
%               gray and also the returned transformed image is gray
%**************************************************************************
% NOTES: 
%**************************************************************************
% EXAMPLES USAGE:
%
% see test_IsSameScene_BIN_SMI_imagePair_Oxford.m
%**************************************************************************
% REFERENCES:
%**************************************************************************
function [correl1, correl2, im1_trans, im2_trans] = transformation_correlation(im1, im2, tform)

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
c = 10;
outputView = imref2d(size(im1));
im2_trans = imwarp(im2+c,tform,'OutputView',outputView,'FillValues', 0);

invtform = invert(tform);
outputView = imref2d(size(im2));
im1_trans = imwarp(im1+c,invtform,'OutputView',outputView,'FillValues', 0);

% mask out the NaN values
mask1 = not(im1_trans == 0);
mask2 = not(im2_trans == 0);
% im1_masked2 = im1.*uint8(mask2);
% im2_masked1 = im2.*uint8(mask1);
% figure;subplot(221); imshow(im1_masked2);
% subplot(222); imshow(mask2);
% subplot(223); imshow(im2_trans.*uint8(mask2));
% figure;subplot(221); imshow(im2_masked1);
% subplot(222); imshow(mask1);
% subplot(223); imshow(im1_trans.*uint8(mask1));

im1_trans = im1_trans - c;
im2_trans = im2_trans - c;
correl1 = corr2(im1(mask2), im2_trans(mask2));
correl2 = corr2(im2(mask1), im1_trans(mask1));

end
