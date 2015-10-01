% integral_masks- obtain the sum along the level dim.from 3D binary masks
%**************************************************************************
% [acc_masks] = integral_masks(binary_masks)
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
% acc_masks     accumulated mask along the level dimension
%**************************************************************************
% SEE ALSO
%**************************************************************************
% RERERENCES:
%**************************************************************************
function [acc_masks] = integral_masks(binary_masks)

%**************************************************************************
% input control                                         
%--------------------------------------------------------------------------
if nargin < 1
    error('intergral_masks requires at least 1 input argument- the binary masks array!');
end

%**************************************************************************
% computations
%--------------------------------------------------------------------------
acc_masks = sum(binary_masks,3);