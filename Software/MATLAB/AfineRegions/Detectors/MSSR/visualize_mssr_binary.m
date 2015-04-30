% visualize_mssr_binary.m- visualize the MSSR regions overlayed on the 
%                          original binary image
%**************************************************************************
% visualize_mssr_binary(ROI,saliency_masks, saliency_type, ...
%                       area_factor, SE_factor)
%
% author: Elena Ranguelova, NLeSc
% date created: 29 Apr 2015
% last modification date: 30 April 2015 
% modification details: extra optional parameters added- SE and
% area factors
%**************************************************************************
% INPUTS:
% [] means opional
% ROI- binary mask of the Region Of Interest
% 
% [saliency_masks] - 3-D array of the binary saliency masks of the regions
%                  saliency_masks(:,:,i) contains the salient regions per 
%                  type: i=1- "holes", i=2- "islands", i=3 - "indentations"
%                  and i =4-"protrusions", default is []
% [saliency_type]- array with 4 flags for the 4 saliency types 
%                  (Holes, Islands, Indentations, Protrusions)
%                  if left out- default is [1 1 1 1]   
% [area_factor]-   the area factor used to obtain the salient regions,
%                  default 'unknown'
% [SE_factor]-     the SE size factor used to obtain the salient regions,
%                  default 'unknown' 
%**************************************************************************
% OUTPUT:
% The regions are dsipalyed as colour-coded overlays: "holes" in blue, 
% "islands" in yellow, "indentations" in green and "protrusions" in red
%**************************************************************************
% EXAMPLES USAGE:
% [saliency_masks] = mssr_binary(ROI, se_size_factor, area_factor)- detects
%                               all salient region types for the binary ROI
% visualize_mssr_binary(ROI)- shows only original ROI
% visualize_mssr_binary(ROI, saliency_masks)- shows all regions
%                               overlayed on the ROI
% visualize_mssr_binary(ROI, saliency_masks, [1 1 0 0])- shows only holes
%                              and islands overlayed on the ROI
% SEE ALSO: test_mssr_binary, imoverlay
%**************************************************************************

function visualize_mssr_binary(ROI, saliency_masks, saliency_type, ...
                               area_factor, SE_factor)

% default parameters and required parameters check
original_only = 0;
if nargin < 1
    error('visualize_mssr_binary.m requires at least 1 input arument!');
end
if (nargin < 2)
    original_only = 1;
end
if (nargin < 3)     
    saliency_type = [1 1 1 1];
end
if (nargin < 4)    
    area_factor = 'unknown';
end
if (nargin < 5)
    SE_factor = 'unknown';
end

if original_only
    imshow(logical(ROI)); title('Original ROI');
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
    rgb = ROI;
    
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

    imshow(rgb);
    title('ROI with overlayed MSSR','FontSize',10);
    xlabel({['SE size factor: ',num2str(SE_factor)];...
        ['Area factor: ',num2str(area_factor)]}, 'FontSize',8)
   
    return
end

