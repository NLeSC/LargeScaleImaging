% transformation_distance- 'transformation distance' between 2 binary images
% **************************************************************************
% [diff, dist, bw2_trans] = transformation_distance(bw1, bw2, tform)
% author: Elena Ranguelova, NLeSc
% date created: 22 Sep 2016
% last modification date: 
% modification details: 
%**************************************************************************
% INPUTS:
% bw1/2         binary images to have the diaytance between them
% tform         estimated (affine) transformation between bw2 and bw1
%               e.g. as returned from estimate_affine_tform
%**************************************************************************
% OUTPUTS:
% diff         XOR(bw1, bw2_transf), difference between bw1 and tranf. bw2
% dist         distance metric- sum(nonzeros(diff))/size(bw1) * 100 [%]
% bw2_trans    transformed bw2
%**************************************************************************
% NOTES: 
%**************************************************************************
% EXAMPLES USAGE:
%
% see test_matching_SMI_desc_affine_dataset.m
%**************************************************************************
% REFERENCES:
%**************************************************************************
function [diff, dist, bw2_trans] = transformation_distance(bw1, bw2, tform)

%% input parameters
if nargin < 3
    error('transformation_distance requires min. 3 input argument!');
end

%% input parameters -> variables
[nrows, ncols] = size(bw1);

%% initializations
bw2_trans = zeros(nrows, ncols);

%% computations
outputView = imref2d(size(bw1));
bw2_trans = imwarp(bw2,tform,'OutputView',outputView);

diff = xor(bw1, bw2_trans);
dist = ((sum(nonzeros(diff)))/(nrows*ncols)) * 100;
end
