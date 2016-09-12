% affine_invariants.m- function to compute Flusser's affine invariants
%**************************************************************************
% [invariants] = affine_invariants(bw, order, coeff)
%
% author: Elena Ranguelova, NLeSc
% date created: 10 Aug 2016
% last modification date: 11 Aug 2016
% modification details: input are the coefficients not the file, order is
% now also a parameter
%**************************************************************************
% INPUTS:
% bw     binary image
% order  the moments order
% coeff  invariants coefficients (read from the TXT file provided with code)
%**************************************************************************
% OUTPUTS:
% invariants   Flussers affine moment invariants
%**************************************************************************
% EXAMPLES USAGE:
% see Testing scripts, e.g. test_matching_mominv
%**************************************************************************
% SEE ALSO:
% cm and cafmi from MomentInvariantsForPR_Book
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

function [invariants] = affine_invariants(bw, order, coeff)

%**************************************************************************
% input control    
%--------------------------------------------------------------------------
if nargin < 3
    error('affine_invariants.m requires at least 3 input arguments!');
    invariants = None;
    return
end

%**************************************************************************
% input parameters -> variables
%--------------------------------------------------------------------------

%**************************************************************************
% initialisations/constants
%--------------------------------------------------------------------------

%**************************************************************************
% computations
%--------------------------------------------------------------------------
moments = cm(bw,order);
invariants = cafmi(coeff, moments);