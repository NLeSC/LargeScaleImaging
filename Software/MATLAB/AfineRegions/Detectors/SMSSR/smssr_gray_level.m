% smssr_gray_level.m- salient regions in a cross-section of gray-level image
%**************************************************************************
% [saliency_masks, binary_image] = smssr_gray_level(image, thresh_type, levels,
%                                   SE_size_factor,area_factor,
%                                   saliency_type, visualise)
%
% author: Elena Ranguelova, NLeSc
% date created: 23 June 20105
%**************************************************************************
% INPUTS:
% image - input gray-level image
% thresh_type- character 's'- single threshold or 'h'- hysteresis thresholds
% levels - the specific gray level(s). If hysteresis is desired, 
%          2 element vector [hightr lowtr]  should be provided
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
% binary_image - the binarize dimage using the shoser thresholding type
%**************************************************************************
% EXAMPLES USAGE:
% [saliency_masks_level] = mssr_gray_level(I, thresh_type, levels, SE_size_factor, ...
%                                   area_factor, saliency_type, visualise_minor);
% as called from smssr.m
%--------------------------------------------------------------------------
% [saliency_masks_level] = smssr_gray_level(I, 'multitr',128, 0.5, 10);
% SMSSR regions (all types) for the cross section of image I (say 256 x 256)
% at level 128, CC which occupies 50% of the cross-section is considered
% significant; all 'holes' less than 10 pixels are removed, no visualisation
%**************************************************************************
% REFERENCES: based on mssr_gray_level.m
%**************************************************************************
function [saliency_masks, binary_image] = smssr_gray_level(image, thresh_type, levels,... 
                                            SE_size_factor,...
                                            area_factor, ...
                                            saliency_type, visualise)


%**************************************************************************
% input control    
%--------------------------------------------------------------------------
if nargin < 7
    visualise = 0;
elseif nargin < 6
    saliency_type = [1 1 1 1];
elseif nargin <5
    error('smssr_gray_level.m requires at least 5 input aruments!');
end

if length(levels) > 2 || length(levels) < 1
    error('smssr_gray_level.m: the gray levels can be one or two!');
end
if ~(strcmp(thresh_type,'s') || strcmp(thresh_type,'h'))
    error('smssr_gray_level.m: the thresh_type can be either s(ingle) or h(ysteresis)!');
end
%**************************************************************************
% constants/hard-set parameters
%--------------------------------------------------------------------------
%**************************************************************************
% input parameters -> variables
%--------------------------------------------------------------------------
[nrows,ncols] = size(image);
if length(levels) == 1
    level=levels;
end
    
%**************************************************************************
% initialisations
%--------------------------------------------------------------------------
num_saliency_types = length(find(saliency_type));
saliency_masks = zeros(nrows,ncols,num_saliency_types);

%**************************************************************************
% computations
%--------------------------------------------------------------------------
% pre-processing
%--------------------------------------------------------------------------
% cross-section
switch thresh_type
    case 's'
        binary_image = image >= level;
        if visualise
             figure;imshow(binary_image);title(['Segmented image at gray level: ' ...
                 num2str(level)]);
        end
    case 'h'
        binary_image = hysteresis_thresholding(image, [], levels, [0 visualise 0]);
        if visualise
             figure;imshow(binary_image);
             title(['Segmented image with hysteresis between gray levels: '...
                 num2str(level(2)) ' and ' num2str(level(1))]);
        end
end


%--------------------------------------------------------------------------
% parameters depending on pre-processing
%--------------------------------------------------------------------------
% core processing
%--------------------------------------------------------------------------
% binary saliency
if find(binary_image)
    [saliency_masks] = smssr_binary(binary_image, SE_size_factor, area_factor, ...
                                   saliency_type, visualise);
end
   
%**************************************************************************
% variables -> output parameters
%--------------------------------------------------------------------------

