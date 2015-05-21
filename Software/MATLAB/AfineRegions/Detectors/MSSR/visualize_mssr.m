% visualize_mssr.m- visualize the MSSR regions from a single image
%                   overlayed on the original image
%**************************************************************************
% visualize_mssr(image_data, saliency_masks, saliency_type, ...
%                                       region_params)
%
% author: Elena Ranguelova, NLeSc
% date created: 19 May 2015
% last modification date: 
% modification details: 
%**************************************************************************
% INPUTS:
% [] means opional
% image_data- gray_level image
% [saliency_masks] - 3-D array of the binary saliency masks of the regions
%                  saliency_masks(:,:,i) contains the salient regions per 
%                  type: i=1- "holes", i=2- "islands", i=3 - "indentations"
%                  and i =4-"protrusions", default is []
% [saliency_type]- array with 4 flags for the 4 saliency types 
%                  (Holes, Islands, Indentations, Protrusions)
%                  if left out- default is [1 1 1 1]   
% [region_params]- salient region parameters [SE_size_factor, ...
%                                                      area_factor, thresh]
%                  SE_size_factor- structuring element (SE) size factor  
%                  area_factor- area factor for the significant CC, 
%                  thresh- percentage of kept regions
%**************************************************************************
% OUTPUT:
% The regions are dsipalyed as colour-coded overlays: "holes" in blue, 
% "islands" in yellow, "indentations" in green and "protrusions" in red
%**************************************************************************
% EXAMPLES USAGE:
% [num_regions, features, saliency_masks] = mssr(image_fname)- detects all 
%                             salient region types 
% visualize_mssr(image_data)- shows only original image
% visualize_mssr(image_data, saliency_masks)- shows all regions
%                               overlayed on the original image
% visualize_mssr(image_data, saliency_masks, [1 1 0 0])- shows only holes
%                              and islands overlayed on the image
% SEE ALSO: test_mssr, imoverlay
%**************************************************************************

function visualize_mssr(image_data, saliency_masks,  ...
                               saliency_type, region_params)

% default parameters and required parameters check
original_only = 0;
if nargin < 1
    error('visualize_mssr_binary.m requires at least 1 input arument!');
end
if (nargin < 2)
    original_only = 1;
end
if (nargin < 3)
    gray_level = 'unknown';
end
if (nargin < 3)     
    saliency_type = [1 1 1 1];
end
if (nargin < 5)    
    area_factor = 'unknown';
    SE_factor = 'unknown';
    tresh = 'unknown';
end

% parameters
% structuring element (SE) size factor  
SE_size_factor=region_params(1);
if ndims(region_params) > 1
    % area factor for the significant CC
    area_factor = region_params(2);
else
    area_factor = 0.03;
end
if ndims(region_params) > 2   
    % thresholding the salient regions
    thresh = region_params(3);
else
    thresh =  0.7;
end

if original_only
    imshow(image_data); title('Original image');
    return
else
% parameter parsing
    saliency_type =num2cell(saliency_type);
    [holes_flag, islands_flag,indentations_flag,protrusions_flag] = deal(saliency_type{:});
    
    if holes_flag
        holes = saliency_masks(:,:,1);
        blue = [0 0 255];
    end
    if islands_flag
        islands = saliency_masks(:,:,2);
        yellow = [255 255 0];
    end
    if indentations_flag
        indentations = saliency_masks(:,:,3);
        green = [0 255 0];
    end
    if protrusions_flag
        protrusions= saliency_masks(:,:,4);
        red = [255 0 0];
    end
    
    % vizualization
    rgb = image_data;
    
    if holes_flag
        rgb = imoverlay(rgb, holes, blue);
    end
    if islands_flag
        rgb = imoverlay(rgb, islands, yellow);
    end
    if indentations_flag
        rgb = imoverlay(rgb, indentations, green);
    end
    if protrusions_flag
        rgb = imoverlay(rgb,protrusions, red);
    end

    figure;
    imshow(rgb);
    title('Image with overlayed MSSR','FontSize',10);
    xlabel({['threshold: ',num2str(thresh)];...
        ['SE size factor: ',num2str(SE_size_factor)];...
        ['Area factor: ',num2str(area_factor)];}, 'FontSize',8)
   
    return
end

