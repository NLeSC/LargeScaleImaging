% binary_detector.m- binary morphological detector
%**************************************************************************
% [saliency_masks] = binary_detector(ROI, SE_size_factor, area_factor, ...
%                                saliency_type, visualise)
%
% author: Elena Ranguelova, NLeSc
% date created: 28 Sept 2015
% last modification date: 
% modification details: 
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
%                  and i =4-"protrusions"  if saliency_types is [1 1 1 1]
%**************************************************************************
% EXAMPLES USAGE:
% [saliency_masks] = binary_detector(ROI, se_size_factor, area_factor, ...
%                                saliency_type, visualise);
%                    as called from a gray level detector
%**************************************************************************
% REFERENCES: Ranguelova, E., Pauwels, E. J. ``Morphology-based Stable
% Salient Regions Detector'', International conference on Image and Vision 
% Computing New Zealand (IVCNZ'06), Great Barrier Island, New Zealand,
% November 2006, pp.97-102
%**************************************************************************
function [saliency_masks] = binary_detector(ROI, SE_size_factor, area_factor,...
                                        saliency_type, visualise)

%**************************************************************************
% input control    
%--------------------------------------------------------------------------
if nargin < 5
    visualise = 0;
elseif nargin < 4
    saliency_type = [1 1 1 1];
elseif nargin < 3
    error('binary_detector.m requires at least 3 input arguments!');
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
%SE_size = fix(sqrt(SE_size_factor*ROI_Area/(2 * pi)));
SE_size = fix(SE_size_factor*sqrt(ROI_Area/pi));
SEhi_size = fix(SE_size/2);
SE = strel('disk',SE_size);
SEhi = strel('disk',SEhi_size);

% area opening parameter
lambda = 5*SE_size;
lambdahi = fix(SE_size/2);
%**************************************************************************
% initialisations
%--------------------------------------------------------------------------

% saleincy masks
num_saliency_types = length(find(saliency_type));
saliency_masks = zeros(nrows, ncols, num_saliency_types,'uint8');

% by type
if holes_flag
    holes = zeros(nrows,ncols);
end
if islands_flag
    islands = zeros(nrows,ncols);
end
if indentations_flag
    indentations = zeros(nrows,ncols);
end
if protrusions_flag
    protrusions = zeros(nrows,ncols);
end

if visualise
    f = figure;
end

CCL = zeros(nrows,ncols);
CCLH = zeros(nrows,ncols);
CCLI = zeros(nrows,ncols);
%**************************************************************************
% computations
%--------------------------------------------------------------------------
% pre-processing

% counter of the significant connected components (CC)
num_CCL = 0;
num_CCLH = 0;
num_CCLI = 0;

filled_ROI = imfill(ROI,'holes');
filled_ROI_inv = imfill(imcomplement(ROI),'holes');

% visualisation
if visualise
    figure(f);subplot(221);imshow(ROI); title('ROI'); grid on;
    subplot(223);imshow(filled_ROI);title('filled ROI'); grid on;
    subplot(224);imshow(filled_ROI_inv);title('filled ROI (inverted)'); grid on;
end


%--------------------------------------------------------------------------
% parameters depending on preprocessing
%--------------------------------------------------------------------------
% core processing
%--------------------------------------------------------------------------
% Inner type Salient Structures (ISS)- holes & islands
%..........................................................................
if islands_flag  
    islands = (filled_ROI_inv.*ROI);
    %imshow(islands);title('Before');pause;
    % remove small isolated bits
    islands = bwareaopen(islands,lambda,4);
    %imshow(islands);title('After1');pause;
    %islands = imclose(islands,strel('disk',1));
    %imshow(islands);title('After2');
end

if holes_flag
    holes = (filled_ROI.*imcomplement(ROI));
    %imshow(holes);title('Before');pause;
    % remove small isolated bits
    holes = bwareaopen(holes,lambda,4);
    %imshow(holes);title('After1');pause;
    %holes = imclose(holes, strel('disk',1));
    %imshow(holes);title('After2');
end

% visualisation
if visualise
    f2 = figure;
    if holes_flag
        subplot(221);imshow(holes);title('holes'); grid on;
    end
    if islands_flag
        subplot(222);imshow(islands);title('islands'); grid on;
    end
end

%..........................................................................
% Border Saliency Structures (BSS) - indentations & protrusions
%..........................................................................
if (indentations_flag || protrusions_flag)
    % find significant CC
    [bw,num]=bwlabel(filled_ROI,4);
    stats = regionprops(bw,'Area');
    [bwh,numh]=bwlabel(holes,4);
    statsh = regionprops(bwh,'Area');
    [bwi,numi]=bwlabel(islands,4);
    statsi = regionprops(bwi,'Area');

    % compute the areas of all regions (to find the most significant ones?)
    for i=1:numh
        if statsh(i).Area/ROI_Area >= area_factor;
            num_CCLH = num_CCLH + 1;
            region = (bwh==i);
            filled_region = imfill(region,'holes');
            CCLH(filled_region)= num_CCLH;
        end
    end
    already_detected = false;
    for i=1:numi
        if statsi(i).Area/ROI_Area >= area_factor;
            num_CCLI = num_CCLI + 1;
            region = (bwi==i);
            filled_region = imfill(region,'holes');
            if filled_region == filled_ROI
                already_detected = true;
            end
            CCLI(filled_region)= num_CCLI;
        end
    end
    if visualise
        ff= figure;subplot(221);imshow(CCLH);title('Significant components (from holes) labelled'); grid on;
        subplot(222);imshow(CCLI);title('Significant components (from islands) labelled'); grid on;
    end

    if not(already_detected)
        for i=1:num
            if stats(i).Area/ROI_Area >= area_factor;
                num_CCL = num_CCL + 1;
                region = (bw==i);
                CCL(region)= num_CCL;
            end
        end
    end

    % find the indentations and protrusions
    % inside the significant CCs
    for j = 1:num_CCLH
       SCCH = (CCLH==j);
       if indentations_flag
        % black top hat
         SCCH_bth = imbothat(SCCH,SEhi);
         SCCH_bth = bwareaopen(SCCH_bth,lambdahi,4);
         indentations = indentations|SCCH_bth;
       end
       if protrusions_flag
        % white top hat       
         SCCH_wth = imtophat(SCCH,SEhi);
         SCCH_wth = bwareaopen(SCCH_wth,lambdahi,4);
         protrusions = protrusions|SCCH_wth;
       end    
    end
    
    for j = 1:num_CCLI
        SCCI = (CCLI==j);
        if indentations_flag
        % black top hat
         SCCI_bth = imbothat(SCCI,SEhi);
         SCCI_bth = bwareaopen(SCCI_bth,lambdahi,4);
         indentations = indentations|SCCI_bth;
       end
        if protrusions_flag
        % white top hat       
         SCCI_wth = imtophat(SCCI,SEhi);
         SCCI_wth = bwareaopen(SCCI_wth,lambdahi,4);
         protrusions = protrusions|SCCI_wth;
       end               
    end
  
    if not(already_detected)
      for j = 1:num_CCL
            SCCL = (CCL==j);
            if visualise
                figure(ff); subplot(223);imshow(SCCL); title('Significant components large'); grid on;
            end

           if indentations_flag
            % black top hat
             SCCA_bth = imbothat(SCCL,SE);
             SCCA_bth = bwareaopen(SCCA_bth,lambda);
             indentations = indentations|SCCA_bth;
           end

           if protrusions_flag
            % white top hat       
             SCCA_wth = imtophat(SCCL,SE);
             SCCA_wth = bwareaopen(SCCA_wth,lambda);
             protrusions = protrusions|SCCA_wth;
           end               
      end
    end    
end

if visualise
    figure(f2);
    if indentations_flag
        subplot(223);imshow(indentations);title('indentations');grid on;
    end
    if protrusions_flag
        subplot(224);imshow(protrusions);title('protrusions'); grid on;
    end
end

%**************************************************************************
% variables -> output parameters
%--------------------------------------------------------------------------
i = 0;
if holes_flag
    i = i+1;
    saliency_masks(:,:,i) = holes;
end
if islands_flag
   i = i+1;
    saliency_masks(:,:,i) = islands;
end
if indentations_flag
    i = i+1;    
    saliency_masks(:,:,i) = indentations;
end
if protrusions_flag
    i = i+1;
    saliency_masks(:,:,i) = protrusions;
end

end