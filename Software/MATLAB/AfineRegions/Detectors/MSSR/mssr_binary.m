% mssr_binary.m- binary MSSR detector
%**************************************************************************
% [saliency_masks] = mssr_binary(ROI, SE_size_factor, area_factor, ...
%                                saliency_type, visualise)
%
% author: Elena Ranguelova, NLeSc
% date created: 25 Feb 2008
% last modification date: 12-05-2015
% modification details: the se_size_factor added as a parameter
%                       the visualization of the final result is taken out
%                       of the function into visualize_mssr_binary
%                       Major bug fix: islands are now comupted properly
%                       
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
%SE_size = floor(SE_size_factor*sqrt(nrows^2 + ncols^2))
SE_size = fix(sqrt(SE_size_factor*ROI_Area/(2 * pi)));
offset = 2*SE_size;
SE = strel('disk',SE_size);

% area opening parameter
lambda = 2*SE_size;
% lambda = floor(SE_size_factor*sqrt(nrows^2 + ncols^2))
% if lambda == 0
%     lambda =  10
% end
%**************************************************************************
% initialisations
%--------------------------------------------------------------------------
% saleincy masks
saliency_masks = zeros(nrows, ncols, 4);
% by type
holes = zeros(nrows+offset,ncols+offset);
islands = zeros(nrows+offset,ncols+offset);
indentations = zeros(nrows+offset,ncols+offset);
protrusions = zeros(nrows+offset,ncols+offset);

ROIoff = zeros(nrows+offset,ncols+offset);
ROIoff(offset/2+1:nrows+offset/2, offset/2+1:ncols+offset/2) = ROI;
% the connected components labels mattrix
CCL = zeros(nrows+offset,ncols+offset);

%**************************************************************************
% computations
%--------------------------------------------------------------------------
% pre-processing

% counter of the significant connected components (CC)
num_CC = 0;

% hole filling operator
filled_ROI = imfill(ROIoff,'holes');
filled_ROI_inv = imfill(imcomplement(ROIoff),'holes');

% visualisation
if visualise
    figure;imshow(ROIoff); title('ROIoff');
    f1 = figure;
    subplot(221);imshow(filled_ROI);title('filled ROI');
    subplot(222);imshow(filled_ROI_inv);title('filled ROI (inverted)');
end


%--------------------------------------------------------------------------
% parameters depending on preprocessing
%--------------------------------------------------------------------------
% core processing
%--------------------------------------------------------------------------
% Inner type Salient Structures (ISS)- holes & islands
%..........................................................................
if islands_flag  
    islands = (filled_ROI_inv.*ROIoff);
    % remove small isolated bits
    islands = bwareaopen(islands,lambda);
end

if holes_flag
    holes = (filled_ROI.*imcomplement(ROIoff));
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
% find significant CC
[bwh,numh]=bwlabel(holes,4);
statsh = regionprops(bwh,'Area');

% compute the areas of all regions (to find the most significant ones?)
for i=1:numh
    if statsh(i).Area/ROI_Area >= area_factor;
        num_CC = num_CC + 1;
        region = (bwh==i);
        filled_region = imfill(region,'holes');
        CCL(filled_region)= num_CC;
    end
end

if (indentations_flag || protrusions_flag)
    % inside the significant CCs
    for j = 1:num_CC
        SCC = (CCL==j);
        if visualise
            figure; imshow(SCC); title('SCC');
        end

       if indentations_flag
        % black top hat
             SCC_bth = imbothat(SCC,SE);
%              if visualise
%                  figure(f1);subplot(223);imshow(SCC_bth);title('black top hat');
%              end
         SCC_bth = bwareaopen(SCC_bth,lambda);
         %ff=figure;subplot(221);imshow(SCC_bth);title('black top hat after area open');
         indentations = indentations|SCC_bth;
         %subplot(222);imshow(indentations);title('indentations');
       end
       
%        if protrusions_flag
%         % white top hat       
%          SCC_wth = imtophat(SCC,SE);
% %          if visualise
% %                figure(f1);subplot(224);imshow(SCC_wth);title('white top hat');
% %          end
%          SCC_wth = bwareaopen(SCC_wth,lambda);
%          protrusions = protrusions|SCC_wth;
%        end               
    end
end
% indentations = indentations & islands;
% figure(ff); subplot(223);imshow(indentations);title('indentations');

if visualise
    figure(f2);subplot(223);imshow(indentations);title('indentaions');
    subplot(224);imshow(protrusions);title('protrusions');
end

%**************************************************************************
% variables -> output parameters
%--------------------------------------------------------------------------
holes = holes(offset/2+1:nrows+offset/2, offset/2+1:ncols+offset/2);
islands = islands(offset/2+1:nrows+offset/2, offset/2+1:ncols+offset/2);
indentations = indentations(offset/2+1:nrows+offset/2, offset/2+1:ncols+offset/2);
protrusions = protrusions(offset/2+1:nrows+offset/2, offset/2+1:ncols+offset/2);
saliency_masks(:,:,1) = holes;
saliency_masks(:,:,2) = islands;
saliency_masks(:,:,3) = indentations;
saliency_masks(:,:,4) = protrusions;


end