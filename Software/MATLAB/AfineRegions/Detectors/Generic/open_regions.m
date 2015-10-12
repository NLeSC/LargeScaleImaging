% open_regions- open the saved results from the saliency detectors
%**************************************************************************
% [num_regions, features, saliency_masks] = dmsr_open(detector, ...
%                                                     features_fname,...
%                                                     regions_fname, ...
%                                                     type)
%
% author: Elena Ranguelova, NLeSc
% date created: 12 October 2015
% last modification date: 
% modification details: 
%**************************************************************************
% INPUTS:
% detector - string indicating the salient regions detector (S/D/MSSR)
% features_fname- the filename for the ellipse features (.d/s/mssr)
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
% NOTES: the opposite of save_regions; replaces the s/d/mssr_open.m
%**************************************************************************
% EXAMPLES USAGE: see for example test_dmsr_general.m
%**************************************************************************
% REFERENCES: 
%**************************************************************************
function  [num_regions, features, saliency_masks] =...
    open_regions(detector, features_fname, regions_fname, type) 


%**************************************************************************
% input control    
%--------------------------------------------------------------------------
if nargin < 4
    type = 0;
elseif nargin < 3
    regions_fname = [];
elseif nargin <2
    error('open_regions.m requires at least 2 input arguments!');
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
switch lower(detector)
    case {'mssr', 'smssr', 'dmsr'}
        ext = lower(detector);
    otherwise
        error('open_regions.m: unknown detector!');
end

if type
    i = find(features_fname =='.');
    j = i(end);
    if isempty(j)
        features_type_fname = [features_fname '_type.' ext];
    else
        features_type_fname = [features_fname(1:j-1) '_type.' ext];
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
% load the binary masks (should contain saliency_masks as saved by dmsr_save)
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



