% contents.m- contents of directory ...\MomentInvariants4PR_Book
%
% topic: Affine moment invariants 
% author: Flusser et al.
% date: 2009
%
% This code accompanies the book by Flusser, Suk and Zitova, "Moments and 
% Moment Invariants for Pattern Recognition", 2009
% http://zoi_zmije.utia.cas.cz/moment_invariants
% http://zoi_zmije.utia.cas.cz/mi/codes
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% NOTE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% I have compiled this contents file from 
% explanations given in http://zoi_zmije.utia.cas.cz/mi/codes
%
%**************************************************************************
% functions
%**************************************************************************
%--------------------------------------------------------------------------
% main
%--------------------------------------------------------------------------
% rotmi.m - computation of the moment invariants to translation, rotation and scaling 
% cafmi.m - computation of the affine moment invariants from the moments 
%--------------------------------------------------------------------------
% secondary
%--------------------------------------------------------------------------
% cm.m - computation of the central geometric moments 
% cmfromgm.m - conversion of the geometric moments to complex ones
% readinv.m - reading of txt-files with invariants to MATLAB 
%**************************************************************************
% helpers
%**************************************************************************
% afinv12indep.txt - all independent invariants up to the weight 12 
% afinvs4_19.txt - all irreducible invariants up to the order 4 