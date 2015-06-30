% mser_open- function to open the saved results from the MSER detector
%**************************************************************************
% [num_regions, features] = mser_open(features_fname)
%
% author: Elena Ranguelova, TNO
% date created: 6 Mar 2008
% last modification date: 
% modification details: 
%**************************************************************************
% INPUTS:
% features_fname- the filename for the ellipse features (.mser)
%**************************************************************************
% OUTPUTS:
% num_regions- the number of salient regions0
% features- the array with ellipse features
%**************************************************************************
% NOTES: for now it opens only features saved as ellipse format!!
%**************************************************************************
% EXAMPLES USAGE: see for example mser_detector_one.m
%**************************************************************************
% REFERENCES:
%**************************************************************************
function  [num_regions, features] = mser_open(features_fname)


%**************************************************************************
% input control    
%--------------------------------------------------------------------------
if nargin < 1
    error('mser_open.m requires at least 1 input argument!');
end
%**************************************************************************
% constants/hard-set parameters
%--------------------------------------------------------------------------
% feature dimension
FEAT_DIM = 5;
%**************************************************************************
% input parameters -> variables
%--------------------------------------------------------------------------
% in case we want to read the features incl. the saliency type
%**************************************************************************
% initialisations
%--------------------------------------------------------------------------
%**************************************************************************
% computations
%--------------------------------------------------------------------------
% pre-processing
%--------------------------------------------------------------------------
% parameters depending on pre-processing
%--------------------------------------------------------------------------
% core processing
%--------------------------------------------------------------------------
%**************************************************************************
% variables -> output parameters
%--------------------------------------------------------------------------
%..........................................................................
% read off the features
features_fname
fid = fopen(features_fname,'r');
t = fscanf(fid,'%f \n',1);
num_regions = fscanf(fid,'%d \n',1);
for j = 1:num_regions
      features(j,:) = fscanf(fid, '%f \n',FEAT_DIM);
end
fclose(fid);  
end



