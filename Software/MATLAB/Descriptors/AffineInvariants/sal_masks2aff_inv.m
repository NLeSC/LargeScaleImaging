% sal_masks2aff_inv.m- compute affine invariants from binary saliency masks
%**************************************************************************
% [invariants] = sal_masks2aff_inv(saliency_masks, order, coeff)
%
% author: Elena Ranguelova, NLeSc
% date created: 11 Aug 2016
% last modification date: 
% modification details: 
%**************************************************************************
% INPUTS:
% saliency_masks    3D array of saliency masks (binary images) as output
%                   from salient regions detector
% order             the moments order
% coeff  invariants coefficients (read from the TXT file provided with code)
%**************************************************************************
% OUTPUTS:
% invariants        2D array of Flussers affine moment invariants. Second
%                   dimention correspons to the saliency types in masks
%**************************************************************************
% EXAMPLES USAGE:
% see Testing scripts, e.g. test_matching_mominv_affine_dataset
%**************************************************************************
% SEE ALSO:
% affine_invariants.m
%**************************************************************************
% NOTES:
% currently available coefficient files
% afinv12indep.txt - all independent invariants up to the weight 12
% afinvs4_19.txt - all irreducible invariants up to the order 4 
% see http://zoi_zmije.utia.cas.cz/mi/codes
%**************************************************************************
% REFERENCES: 
% B. Z. J. Flusser, T. Suk, "Moment and Moment Invariants in Pattern 
% Recognition", John Wiley and Sons, 2009.
% Jan Flusser, "On the independence of rotation moment invariants": 
% http://library.utia.cas.cz/prace/20000033.pdf
% see also % http://homepages.inf.ed.ac.uk/rbf/CVonline/LOCAL_COPIES/FISHER/MOMINV/
% and 
% http://citeseerx.ist.psu.edu/viewdoc/download?doi=10.1.1.463.3980&rep=rep1&type=pdf
%**************************************************************************

function [invariants] = sal_masks2aff_inv(saliency_masks, order, coeff)

%**************************************************************************
% input control    
%--------------------------------------------------------------------------
if nargin < 3
    error('sal_masks2aff_inv.m requires at least 3 input argument!');
    invariants = None;
    return
end

%**************************************************************************
% input parameters -> variables
%--------------------------------------------------------------------------
dim  = ndims(saliency_masks);
if dim > 2
    num_masks = size(saliency_masks,dim);
else
    num_masks = 1;
end

%**************************************************************************
% initialisations/constants
%--------------------------------------------------------------------------

%**************************************************************************
% computations
%--------------------------------------------------------------------------
for n = 1:num_masks    
    invariants(n,:) = affine_invariants(saliency_masks(:,:,n),order, coeff);
end
