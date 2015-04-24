% mssr_open- function to open the saved results from the MSSR detector
%**************************************************************************
% [num_regions, features, saliency_masks] = mssr_open(features_fname,...
%                                                     regions_fname, type)
%
% author: Elena Ranguelova, TNO
% date created: 26 Feb 2008
% last modification date: 28 Feb 2008
% modification details: made regions_fname optional
%**************************************************************************
% INPUTS:
% features_fname- the filename for the ellipse features (.mssr)
% [regions_fname]- the file for the saliency masks of the regions 
%                   (binary .mat) [optional]
% [type] - flag- to read the features including the saliency type or not
%               if left out default is 0 (no type) [optional]
%**************************************************************************
% OUTPUTS:
% num_regions- the number of salient regions0
% saliency_masks- the binary saliency masks
% features- the array with ellipse features
%**************************************************************************
% NOTES: the opposite of mssr_save
%**************************************************************************
% EXAMPLES USAGE: see for example display_features.m
%**************************************************************************
% REFERENCES:
%**************************************************************************
function  [num_regions, features, saliency_masks] =...
    mssr_open(features_fname, regions_fname, type) %#ok<STOUT>


%**************************************************************************
% input control    
%--------------------------------------------------------------------------
if nargin < 3
    type = 0;
elseif nargin < 2
    regions_fname = [];
elseif nargin < 1
    error('mssr_open.m requires at least 1 input argument!');
    return
end
%**************************************************************************
% constants/hard-set parameters
%--------------------------------------------------------------------------
% feature dimensions with/without type
FEAT_DIM = 5;
FEAT_DIM_TYPE = 6;
%**************************************************************************
% input parameters -> variables
%--------------------------------------------------------------------------
% in case we want to read the features incl. the saliency type
if type
    i = find(features_fname =='.');
    j = i(end);
    if isempty(j)
        features_type_fname = [features_fname '_type.mssr'];
    else
        features_type_fname = [features_fname(1:j-1) '_type.mssr'];
    end
end
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
% load the binary masks (should contain saliency_masks as saved by mssr_save)
if isempty(regions_fname)
    saliency_masks = [];
else
    load(regions_fname);
    % temporary!!
    if ~exist('saliency_masks')
        saliency_masks = Sal;
    end
end
%..........................................................................
% read off the features
if type
    % features including the 
       fid = fopen(features_type_fname,'r');
       t = fscanf(fid,'%d \n',1);
       num_regions = fscanf(fid,'%d \n',1);
       for j = 1:num_regions
           features(j,:) = fscanf(fid, '%f \n',FEAT_DIM_TYPE);
       end
      fclose(fid);  
else
       fid = fopen(features_fname,'r');
       t = fscanf(fid,'%d \n',1);
       num_regions = fscanf(fid,'%d \n',1);
       for j = 1:num_regions
           features(j,:) = fscanf(fid, '%f \n',FEAT_DIM);
       end
      fclose(fid);  
end



