% mssr_gray_level.m- salient regions in a cross-section of gray-level image
%**************************************************************************
% [saliency_masks] = mssr_gray_level(image, level,
%                                   SE_size_factor,area_factor,
%                                   saliency_type, visualise)
%
% author: Elena Ranguelova, TNO
% date created: 22 Feb 2008
% last modification date: 15 May 20105
% modification details: using the new input parameters
%**************************************************************************
% INPUTS:
% image - input gray-level image
% level - the specific gray level 
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
% [saliency_masks_level] = mssr_gray_level(I, level, SE_size_factor, ...
%                                   area_factor, saliency_type, visualise_minor);
% as called from mssr.m
%--------------------------------------------------------------------------
% [saliency_masks_level] = mssr_gray_level(I, 128, 0.5, 10);
% MSSR regions (all types) for the cross section of image I (say 256 x 256)
% at level 128, CC which occupies 50% of the cross-section is considered
% significant; all 'holes' less than 10 pixels are removed, no visualisation
%**************************************************************************
% REFERENCES: see mssr.m and mssr_binary.m
%**************************************************************************
function [saliency_masks] = mssr_gray_level(image,level, SE_size_factor,...
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
    error('mssr_gray_level.m requires at least 4 input aruments!');
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
ROI = image >= level;

if visualise
    figure;imshow(ROI);title(['Segmented image at gray level: ' num2str(level)]);
end
%--------------------------------------------------------------------------
% parameters depending on pre-processing
%--------------------------------------------------------------------------
% core processing
%--------------------------------------------------------------------------
% binary saliency
if find(ROI)
    [saliency_masks] = binary_detector(ROI, SE_size_factor, area_factor, ...
                                   saliency_type, visualise);
end
   
%**************************************************************************
% variables -> output parameters
%--------------------------------------------------------------------------

