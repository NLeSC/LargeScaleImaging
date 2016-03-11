% visualize_regions_overlay.m- show salient regions overlaied on image 
%**************************************************************************
% visualize_regions_overlay(image_data, saliency_masks, saliency_flags, figs)
%
% author: Elena Ranguelova, NLeSc
% date created: 9 October 2015
% last modification date: 11 March 2016 
% modification details: fixed the region display
%**************************************************************************
% INPUTS:
% image_data- gray-level input image
% saliency_masks- 3-D array of the binary saliency masks of the regions
%                  saliency_masks(:,:,i) contains the salient regions per 
%                  type: i=1- "holes", i=2- "islands", i=3 - "indentaitons"
%                  and i =4-"protrusions"  if saliency_types is [1 1 1 1]
% saliency_flags- flags indicating the types of saliency 
% figs- vector of 3 figure handles
%**************************************************************************
% OUTPUTS:
%**************************************************************************
% EXAMPLES USAGE:
% 
%**************************************************************************
% REFERENCES: 
%**************************************************************************

function visualize_regions_overlay(image_data, saliency_masks, saliency_flags, figs)
%**************************************************************************
% input control    
%--------------------------------------------------------------------------
if nargin < 3 || length(saliency_flags)<4
    saliency_flags = [1 1 1 1];
elseif nargin < 2
    error('visualize_regions_overlay.m requires at least 2 input arguments!');
end
%**************************************************************************
%% constants/hard-set parameters
%--------------------------------------------------------------------------
BLUE = [0 0 255];
YELLOW = [255 255 0];
GREEN = [0 255 0];
RED = [255 0 0];
%**************************************************************************
%% input parameters -> variables
%--------------------------------------------------------------------------
% saliency types
holes_flag = saliency_flags(1);
islands_flag = saliency_flags(2);
indentations_flag = saliency_flags(3);
protrusions_flag = saliency_flags(4);

% figure handles
f1 = figs(1);
f2 = figs(2);
f3 = figs(3);
% saliency masks
i = 0;

if holes_flag
    i =i+1;
    holes = saliency_masks(:,:,i);
end
if islands_flag
    i =i+1;
    islands = saliency_masks(:,:,i);
end
if indentations_flag
    i =i+1;
    indentations = saliency_masks(:,:,i);
end
if protrusions_flag
    i =i+1;
    protrusions = saliency_masks(:,:,i);
end


%**************************************************************************
%% visualization
%--------------------------------------------------------------------------
all_rgb = image_data;
% holes
if holes_flag && ~isempty(find(holes, 1))
    
    rgb = imoverlay(image_data, holes, BLUE);
    all_rgb = imoverlay(all_rgb, holes, BLUE);
    figure(f1);
    subplot(221);imshow(holes);
    title('Holes');axis image;axis on;
    drawnow;
    figure(f2);
    subplot(221); imshow(rgb); axis on; title('Holes overlayed on image');
end
% islands
if islands_flag && ~isempty(find(islands,1))
    rgb = imoverlay(image_data, islands, YELLOW);
    all_rgb = imoverlay(all_rgb, islands, YELLOW);
    figure(f1);
    subplot(222);imshow(islands);
    title('Islands');axis image;axis on;
    drawnow;
    figure(f2);
    subplot(222); imshow(rgb); axis on; title('Islands overlayed on image');
end
% indentations
if indentations_flag && ~isempty(find(indentations,1))
    rgb = imoverlay(image_data, indentations, GREEN);
    all_rgb = imoverlay(all_rgb, indentations, GREEN);
    figure(f1);
    subplot(223);imshow(indentations);
    title('Indentations');axis image;axis on;
    drawnow;
    figure(f2);
    subplot(223); imshow(rgb); axis on; title('Indentations overlayed on image');
end
% protrusions
if protrusions_flag && ~isempty(find(protrusions,1))
    rgb = imoverlay(image_data, protrusions, RED);
    all_rgb = imoverlay(all_rgb, protrusions, RED);
    figure(f1);
    subplot(224);imshow(protrusions);
    title('Protrusions');axis image;axis on;
    drawnow;
    figure(f2);
    subplot(224); imshow(rgb); axis on; title('Protrusions overlayed on image'); 
end

figure(f3);
imshow(all_rgb); axis on; title('All detected regions and types overlayed on image');
