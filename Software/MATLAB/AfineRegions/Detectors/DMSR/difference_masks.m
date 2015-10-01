% difference_masks- obtain the bidirectioal difference between binary masks
%**************************************************************************
% [fwd_diff, bwd_diff] = diffrence_masks(binary_masks)
%
% author: Elena Ranguelova, NLeSc
% date created: 1 October 2015
% last modification date: 
% modification details: 
%**************************************************************************
% INPUTS:
% binary_masks    3D binary masks from thresholding at different gray_levels
%**************************************************************************
% OUTPUTS:
% f/bwd_diff     absolute differences in forward and backward directions
%**************************************************************************
% SEE ALSO
% test_diff      testing script for difference masks function
%**************************************************************************
% RERERENCES:
%**************************************************************************
function [fwd_diff, bwd_diff] = difference_masks(binary_masks)

%**************************************************************************
% input control                                         
%--------------------------------------------------------------------------
if nargin < 1
    error('difference_masks requires at least 1 input argument- the binary masks array!');
    return
end
%**************************************************************************
% input parameters to local parameters                                        
%--------------------------------------------------------------------------
[nrows, ncols, nlevels] = size(binary_masks);
fwd_diff = zeros(nrows, ncols, nlevels);
bwd_diff = zeros(nrows, ncols, nlevels);

%**************************************************************************
% computations
%--------------------------------------------------------------------------

% forward difference
fwd_diff(:,:,1:end-1) = binary_masks(:,:,1:end-1) - binary_masks(:,:,2:end);
% take the absolute value
fwd_diff = abs(fwd_diff);

% backward difference
bwd_diff(:,:,2:end) = binary_masks(:,:,2:end) - binary_masks(:,:,1:end-1);
% take the absolute value
bwd_diff = abs(bwd_diff);
