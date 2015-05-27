% smssr_gray_thresh.m- salient regions in a thresholded gray-level image
%**************************************************************************
% [saliency_masks] = mssr_gray_thresh(image, thresh,
%                                   SE_size_factor,area_factor,
%                                   saliency_type, visualise)
%
% author: Elena Ranguelova, NLeSc
% date created: 27 May 2015
% last modification date: 
% modification details: 
%**************************************************************************
% INPUTS:
% image - input gray-level image
% thresh - the specific gray level threshold
% SE_size_factor- structuring element (SE) size factor  
% area_factor - area factor for the significant CC
% [saliency_type]- array with 4 flags for the 4 saliency types 
%                (Holes, Islands, Indentations, Protrusions)
%                [optional], if left out- default is [1 1 1 1]   
% [visualise] - visualisation flag
%                     [optional], if left out- default is 0
%**************************************************************************
% OUTPUTS:
% saliency_masks - 3-D array of the binary saliency masks of the regions
%                  for example saliency_masks(:,:,1) contains the holes
%**************************************************************************
% EXAMPLES USAGE:
% [saliency_masks_level] = smssr_gray_thresh(I, thresh, SE_size_factor, ...
%                                   area_factor, saliency_type, visualise_minor);
% as called from smssr.m
%--------------------------------------------------------------------------
% [saliency_masks_level] = smssr_gray_thresh(I, 0.2, 0.5, 10);
% SMSSR regions (all types) for the cross section of image I (say 256 x 256)
% at threshold 0.2, CC which occupies 50% of the cross-section is considered
% significant; all 'holes' less than 10 pixels are removed, no visualisation
%**************************************************************************
% REFERENCES: see smssr.m and mssr_binary.m
%**************************************************************************
function [saliency_masks] = mssr_gray_thresh(image,thresh, SE_size_factor,...
                                            area_factor, ...
                                            saliency_type, visualise)


%**************************************************************************
% input control    
%--------------------------------------------------------------------------
if nargin < 6
    visualise = 0;
elseif nargin < 5
    saliency_type = [1 1 1 1];
elseif nargin <4
    error('smssr_gray_thresh.m requires at least 4 input aruments!');
    saliency_masks = [];
    return
end

%**************************************************************************
% constants/hard-set parameters
%--------------------------------------------------------------------------
%**************************************************************************
% input parameters -> variables
%--------------------------------------------------------------------------
[nrows,ncols] = size(image);
%**************************************************************************
% initialisations
%--------------------------------------------------------------------------
saliency_masks = zeros(nrows,ncols,4);

%**************************************************************************
% computations
%--------------------------------------------------------------------------
% pre-processing
%--------------------------------------------------------------------------
% cross-section
ROI = im2bw(image,thresh);

if visualise
    figure;imshow(ROI);title(['Segmented image at threshold: ' num2str(thresh)]);
end
%--------------------------------------------------------------------------
% parameters depending on pre-processing
%--------------------------------------------------------------------------
% core processing
%--------------------------------------------------------------------------
% binary saliency
if find(ROI)
    [saliency_masks] = mssr_binary(ROI, SE_size_factor, area_factor, ...
                                   saliency_type, visualise);
end
   
%**************************************************************************
% variables -> output parameters
%--------------------------------------------------------------------------

