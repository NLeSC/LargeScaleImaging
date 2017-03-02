% transformation_distance_binary- 'transformation distance' between 2 binary images
% **************************************************************************
% [diff1, diff2, dist1, dist2, bw1_trans, bw2_trans] = transformation_distance_binary(bw1, bw2, tform)
% author: Elena Ranguelova, NLeSc
% date created: 22 Sep 2016
% last modification date: 2 Mar 2017
% modification details: renamed to transformation_distance_binary
% last modification date: 4 Oct 2016
% modification details: returns 2 distances in respect to the 2  addimages
% last modification date: 30 Sept 2016
% modification details: distance is now in respect to bw1
%**************************************************************************
% INPUTS:
% bw1/2         binary images to have the distance between them
% tform         estimated (affine) transformation between bw2 and bw1
%               e.g. as returned from estimate_affine_tform
%**************************************************************************
% OUTPUTS:
% diff1/2       XOR(bw1/2, bw2/1_transf), difference between bw1/2 and tranf. bw2/1
% dist1/2       distance metric- sum(nonzeros(diff1/2))/sum(non-zeros(bw1/2))
% bw1/2_trans     transformed bw1/2
%**************************************************************************
% NOTES: 
%**************************************************************************
% EXAMPLES USAGE:
%
% see test_matching_SMI_desc_affine_dataset.m
%**************************************************************************
% REFERENCES:
%**************************************************************************
function [diff1, diff2, dist1, dist2, bw1_trans, bw2_trans] = transformation_distance_binary(bw1, bw2, tform)

%% input parameters
if nargin < 3
    error('transformation_distance requires min. 3 input arguments!');
end

%% input parameters -> variables
[nrows1, ncols1] = size(bw1);
[nrows2, ncols2] = size(bw2);

%% initializations
bw2_trans = zeros(nrows1, ncols1);
bw1_trans = zeros(nrows2, ncols2);

%% computations
outputView = imref2d(size(bw1));
bw2_trans = imwarp(bw2,tform,'OutputView',outputView);

invtform = invert(tform);
outputView = imref2d(size(bw2));
bw1_trans = imwarp(bw1,invtform,'OutputView',outputView);

diff1 = xor(bw1, bw2_trans);
diff2 = xor(bw2, bw1_trans);

bw1_nonzeo = sum(nonzeros(bw1));
diff1_sum = sum(nonzeros(diff1));
dist1 = diff1_sum/bw1_nonzeo;

bw2_nonzeo = sum(nonzeros(bw2));
diff2_sum = sum(nonzeros(diff2));
dist2 = diff2_sum/bw2_nonzeo;

end
