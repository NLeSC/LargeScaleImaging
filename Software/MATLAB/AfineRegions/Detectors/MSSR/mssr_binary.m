% mssr_binary.m- binary MSSR detector
%**************************************************************************
% [saliency_masks] = mssr_binary(ROI, SE_size_factor, area_factor, ...
%                                saliency_type, visualise)
%
% author: Elena Ranguelova, NLeSc
% date created: 25 Feb 2008
% last modification date: 06-05-2015
% modification details: the se_size_factor added as a parameter
%                       the visualization of the final result is taken out
%                       of the function into visualize_mssr_binary
%                       Major bug fix: islands are now comupted properly
%**************************************************************************
% INPUTS:
% ROI- binary mask of the Region Of Interest
% SE_size_factor- structuring element (SE) size factor
% area_factor - area factor for the significant connected components (CCs)
% [saliency_type]- array with 4 flags for the 4 saliency types 
%                (Holes, Islands, Indentations, Protrusions)
%                [optional], if left out- default is [1 1 1 1]   
% [visualise] - visualisation flag
%               [optional], if left out- default is 0, if set to 1, 
%               intermendiate steps of the detection are shown 
%**************************************************************************
% OUTPUTS:
% saliency_masks - 3-D array of the binary saliency masks of the regions
%                  saliency_masks(:,:,i) contains the salient regions per 
%                  type: i=1- "holes", i=2- "islands", i=3 - "indentaitons"
%                  and i =4-"protrusions" 
%**************************************************************************
% EXAMPLES USAGE:
% [saliency_masks] = mssr_binary(ROI, se_size_factor, area_factor, ...
%                                saliency_type, visualise);
%                    as called from mssr_gray_level.m- TO DO!
%**************************************************************************
% REFERENCES: Ranguelova, E., Pauwels, E. J. ``Morphology-based Stable
% Salient Regions Detector'', International conference on Image and Vision 
% Computing New Zealand (IVCNZ'06), Great Barrier Island, New Zealand,
% November 2006, pp.97-102
%**************************************************************************
function [saliency_masks] = mssr_binary(ROI, SE_size_factor, area_factor,...
                                        saliency_type, visualise)

%**************************************************************************
% input control    
%--------------------------------------------------------------------------
if nargin < 5
    visualise = 0;
elseif nargin < 4
    saliency_type = [1 1 1 1];
elseif nargin < 3
    error('mssr_binary.m requires at least 3 input aruments!');
    saliency_masks = [];
    return
end

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
ROI_Area = nrows*ncols;

% SE
SE_size = fix(sqrt(SE_size_factor*ROI_Area/(2 * pi)))

SE = strel('disk',SE_size);

% area opening parameter
lambda = 2*SE_size

%**************************************************************************
% initialisations
%--------------------------------------------------------------------------
% saleincy masks
saliency_masks = zeros(nrows, ncols, 4);
% by type
holes = zeros(nrows,ncols);
islands = zeros(nrows,ncols);
%islands_inv = zeros(nrows,ncols);
indentations = zeros(nrows,ncols);
protrusions = zeros(nrows,ncols);

% the connected components labels mattrix
CCL = zeros(nrows,ncols);
CCL_inv = zeros(nrows,ncols);

%**************************************************************************
% computations
%--------------------------------------------------------------------------
% pre-processing

% counter of the significant connected components (CC)
num_CC = 0;
%num_CC_inv = 0;

% hole filling operator
filled_ROI = imfill(ROI,'holes');
%filled_ROI_inv = imfill(imcomplement(ROI),'holes');

% visualisation
if visualise
    f1 = figure;subplot(221); imshow(ROI); title('ROI');
    subplot(221);imshow(filled_ROI);title('filled ROI');
 %   subplot(222);imshow(filled_ROI_inv);title('filled ROI (inverted)');
end

% get the CCs
[bw,num]=bwlabel(filled_ROI,4);
stats = regionprops(bw,'Area');

% [bw_inv,num_inv]=bwlabel(filled_ROI_inv,4);
% stats_inv = regionprops(bw_inv,'Area');
% compute the areas of all regions (to find the most significant ones?)
for i=1:num
    stats(i).Area
    if stats(i).Area/ROI_Area >= area_factor;
        num_CC = num_CC + 1;
        index = (bw==i);
        CCL(index)= num_CC;
    end
end
% compute the areas of all regions (for the inverted ROI)
% for i=1:num_inv
%     stats_inv(i).Area
%     if stats_inv(i).Area/ROI_Area >= area_factor;
%         num_CC_inv = num_CC_inv + 1;
%         index = (bw_inv==i);
%         CCL_inv(index)= num_CC_inv;
%     end
% end
if visualise
    figure; subplot(221);imshow(CCL); title('CCL');
    %subplot(222);imshow(CCL_inv); title('CCL inv');
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
        disp('Yes')
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

% visualisation
if visualise
    f2 = figure;subplot(221);imshow(holes);title('holes');
    subplot(222);imshow(islands);title('islands');
end

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
                 figure(f1);subplot(223);imshow(SCC_bth);title('black top hat');
             end
         SCC_bth = bwareaopen(SCC_bth,lambda);
         indentations = indentations|SCC_bth;
       end
       
       if protrusions_flag
        % white top hat       
         SCC_wth = imtophat(SCC,SE);
         if visualise
               figure(f1);subplot(224);imshow(SCC_wth);title('white top hat');
         end
         SCC_wth = bwareaopen(SCC_wth,lambda);
         protrusions = protrusions|SCC_wth;
       end               
    end
end

if visualise
    figure(f2);subplot(223);imshow(indentations);title('indentaions');
    subplot(224);imshow(protrusions);title('protrusions');
end

%**************************************************************************
% variables -> output parameters
%--------------------------------------------------------------------------
saliency_masks(:,:,1) = holes;
saliency_masks(:,:,2) = islands;
saliency_masks(:,:,3) = indentations;
saliency_masks(:,:,4) = protrusions;


end