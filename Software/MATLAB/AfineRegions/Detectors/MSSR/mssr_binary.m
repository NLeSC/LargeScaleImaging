% mssr_binary.m- binary MSSR
%**************************************************************************
% [saliency_masks] = mssr_binary(ROI, area_factor, saliency_type, visualise)
%
% author: Elena Ranguelova, TNO
% date created: 25 Feb 2008
% last modification date: 
% modification details: 
%**************************************************************************
% INPUTS:
% ROI- binary mask of the Region Of Interest
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
%                  then islands, indentation and protrusions 
%**************************************************************************
% EXAMPLES USAGE:
% [saliency_masks] = mssr_binary(ROI, area_factor, saliency_type, visualise);
% as called from mssr_gray_level.m
%**************************************************************************
% REFERENCES: Ranguelova, E., Pauwels, E. J. ``Morphology-based Stable
% Salient Regions Detector'', International conference on Image and Vision 
% Computing New Zealand (IVCNZ'06), Great Barrier Island, New Zealand,
% November 2006, pp.97-102
%**************************************************************************
function [saliency_masks] = mssr_binary(ROI, area_factor, saliency_type,...
                                        visualise)

%**************************************************************************
% input control    
%--------------------------------------------------------------------------
if nargin < 4
    visualise = 0;
elseif nargin < 3
    saliency_type = [1 1 1 1];
elseif nargin < 2
    error('mssr_binary.m requires at least 2 input aruments!');
    saliency_masks = [];
    return
end
%**************************************************************************
% constants/hard-set parameters
%--------------------------------------------------------------------------
% Structuring Element (SE) size factor
%SE_size_factor = 0.02;
SE_size_factor = 0.01;

%**************************************************************************
% input parameters -> variables
%--------------------------------------------------------------------------
% saliency flags
holes_flag = saliency_type(1);
islands_flag = saliency_type(2);
indentations_flag = saliency_type(3);
protrusions_flag = saliency_type(4);

% ROI
[nrows, ncols] = size(ROI);

% ROI area
%A = bwarea(ROI);
A = nrows*ncols;

% SE
SE_size = fix(sqrt(SE_size_factor*A/(2 * pi)));
SE = strel('disk',SE_size);

% area opening parameter
lambda = 2*SE_size;

%**************************************************************************
% initialisations
%--------------------------------------------------------------------------
% saleincy masks
saliency_masks = zeros(nrows, ncols, 4);
% by type
holes = zeros(nrows,ncols);
islands = zeros(nrows,ncols);
indentations = zeros(nrows,ncols);
protrusions = zeros(nrows,ncols);
% the connected components labels mattrix
CCL = zeros(nrows,ncols);

%**************************************************************************
% computations
%--------------------------------------------------------------------------
% pre-processing

% counter of the significant connected components (CC)
num_CC = 0;

% hole filling operator
filled_ROI = imfill(ROI,'holes');

% get the CCs
[bw,num]=bwlabel(filled_ROI,4);
stats = regionprops(bw,'Area');

% compute the areas of all regions (to find the most significant ones?)
for i=1:num
    if stats(i).Area/A >= area_factor;
        num_CC = num_CC + 1;
        CCL(bw==i)= num_CC;
    end
end

%--------------------------------------------------------------------------
% parameters depending on preprocessing
%--------------------------------------------------------------------------
% core processing
%--------------------------------------------------------------------------
% Inner type Salient Structures (ISS)- holes & islands
%..........................................................................
if islands_flag
    if isempty(find(imcomplement(CCL>0), 1))
        islands = ROI;
    else
        islands= imcomplement(CCL>0).*ROI;
    end
    % remove small isolated bits
    islands = bwareaopen(islands,lambda);
end

if holes_flag
    holes = (filled_ROI.*imcomplement(ROI));
    % remove small isolated bits
    holes = bwareaopen(holes,lambda);
end

% % visualisation
% if visualise
%     figure;imshow(holes);title('holes');
%     figure;imshow(islands);title('islands');
% end

%..........................................................................
% Border Saliency Structures (BSS) - indentaions & protrusions
%..........................................................................
if (indentations_flag || protrusions_flag)
    % inside the significant CCs
    for j = 1:num_CC
        SCC = (CCL==j);

       if indentations_flag
        % black top hat
             SCC_bth = imbothat(SCC,SE);
             if visualise
                 %figure;imshow(SCC_bth);title('black top hat');
             end
         SCC_bth = bwareaopen(SCC_bth,lambda);
         indentations = indentations|SCC_bth;
       end
       
       if protrusions_flag
        % white top hat       
         SCC_wth = imtophat(SCC,SE);
         if visualise
              %figure;imshow(SCC_wth);title('white top hat');
         end
         SCC_wth = bwareaopen(SCC_wth,lambda);
         protrusions = protrusions|SCC_wth;
       end               
    end
end

% if visualise
%     figure;imshow(indentations);title('indentaions');
%     figure;imshow(protrusions);title('protrusions');
% end

%**************************************************************************
% variables -> output parameters
%--------------------------------------------------------------------------
saliency_masks(:,:,1) = holes;
saliency_masks(:,:,2) = islands;
saliency_masks(:,:,3) = indentations;
saliency_masks(:,:,4) = protrusions;

% final vizualization
if visualise
    red = [255 0 0];
    green = [0 255 0];
    blue = [0 0 255];
    yellow = [255 255 0];
    rgb = imoverlay(ROI,protrusions, red);
    rgb = imoverlay(rgb, indentations, green);
    rgb = imoverlay(rgb, holes, blue);
    rgb = imoverlay(rgb, islands, yellow);
    imshow(rgb);
end