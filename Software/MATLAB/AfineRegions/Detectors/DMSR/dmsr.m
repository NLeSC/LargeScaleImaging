% dmsr- main function of the DMSR (Data-driven Morphology Salient Regions) detector 
%**************************************************************************
% [num_regions, features, saliency_masks] = dmsr(image_data,ROI_mask,...
%                                           num_levels, offset,...
%                                           otsu_only, saliency_type, ...    
%                                           morphology_parameters, weights, ...
%                                           execution_flags)
%
% author: Elena Ranguelova, NLeSc
% date created: 12 Oct 2015
% last modification date: 30 May 2016
% modification details: using morphological parameters also for the binary
% detector
% last modification date: 6 Oct 2015
% modification details: added flag for Otsu only
%**************************************************************************
% INPUTS:
% image_data        the input gray-level image data
% [ROI_mask]        the Region Of Interenst binary mask [optional]
%                   if specified should contain the binary array ROI
%                   if left out or empty [], the whole image is considered
% [num_levels]      number of gray levels to be considered [1..255],
%                   default 255, i.e. all, step 1
% [offset]          the offset (number of levels) from Otsu to be processed
%                   default value- 80
% [otsu_only]       flag to perform only Otsu thresholding
% [saliency_type]   array with 4 flags for the 4 saliency types 
%                   (Holes, Islands, Indentations, Protrusions)
%                   [optional], if left out- default is [1 1 1 1]
% [morphology_parameters] vector with 5 values corresponding to
%                   SE_size_factor- size factor for the structuring element
%                   Area_factor_very_large- factor for the area of CC to be
%                   considered 'very large'
%                   Area_factor_large- factor for the area of CC to be
%                   considered 'large'
%                   lambda_factor- factor for the parameter lambda for the
%                   morphological opening (noise reduction)
%                   connectivity - for the morhpological opening
%                   default values [0.02 0.1 0.001 3 8]
% [weights]         vector with 3 weights for the linear combination for
%                   weight_all- the weight for the total number of CC
%                   weight_large- the weight for the number large CC
%                   weight_very_large- for the number of very large CC
%                   default value - [0.33 0.33 0.33], i.e equal
% [execution_flags] vector with 3 flags [verbose, visualise_major, ...
%                                                       visualise_minor]
%                   [optional], if left out- default is [0 0 0]
%                   visualise_major "overrides" visualise_minor
%**************************************************************************
% OUTPUTS:
% num_regions       number of detected salient regions
% features          the features of the equivalent ellipses to the salient 
%                   regions in format [x y a b c t], where (x,y)- ellipse 
%                   centroid coords, a(x-u)^2 + 2b(x-u)(y-v) + c(y-v)^2 = 1
%                   is the ellipse equation,
%                   t- region type (1= Hol | 2= Isl | 3=Ind | 4=Pr)
% saliency_masks    3-D array of the binary saliency masks of the regions
%                   for example saliency_masks(:,:,1) contains the holes
%**************************************************************************
% SEE ALSO
% smssr- the SMSSR detector 
%**************************************************************************
% EXAMPLES USAGE: 
%--------------------------------------------------------------------------
% see also test_dssr_general.m
%**************************************************************************
% RERERENCES:
%**************************************************************************
function [num_regions, features, saliency_masks] = dmsr(image_data,ROI_mask,...
                                           num_levels, offset,...
                                           otsu_only,saliency_type, ...   
                                           morphology_parameters, weights, ...
                                           execution_flags)


                                         
%**************************************************************************
% input control                                         
%--------------------------------------------------------------------------
if nargin < 9 || length(execution_flags) <3
    execution_flags = [0 0 0];
end
if nargin < 8 || isempty(weights) || length(weights) < 3
    weights = [0.33 0.33 0.33];
end
if nargin < 7 || length(morphology_parameters) < 5
    morphology_parameters = [0.02 0.1 0.001 3 8]; 
end
if nargin < 6 || isempty(otsu_only)
    otsu_only =  false;
end
if nargin < 5 || isempty(saliency_type) || length(saliency_type) < 4
    saliency_type = [1 1 1 1];
end
if nargin < 4 || isempty(offset)
    offset =  80;
end
if nargin < 3 || isempty(num_levels)
    num_levels = 25;
end
if nargin < 2
    ROI_mask = [];
end
if nargin < 1
    error('dmsr.m requires at least 1 input argument- the gray_level image!');
    num_regions = 0;
    featurs = [];
    saliency_masks = [];
    return
end

%**************************************************************************
% input parameters -> variables
%--------------------------------------------------------------------------
% execution flags
verbose = execution_flags(1);
visualise_major = execution_flags(2);
visualise_minor = execution_flags(3);    

if visualise_minor
    visualise_major = 1;  
end

% morphology parameters
SE_size_factor = morphology_parameters(1);
Area_factor_large = morphology_parameters(3);
lambda_factor = morphology_parameters(4);
connectivity = morphology_parameters(5);

morph_params_binary =[SE_size_factor Area_factor_large lambda_factor, connectivity];
% saliency types
holes_flag = saliency_type(1);
islands_flag = saliency_type(2);
indentations_flag = saliency_type(3);
protrusions_flag = saliency_type(4);


%**************************************************************************
% parameters
%--------------------------------------------------------------------------
% image dimensions
[nrows, ncols] = size(image_data);

% set up the figures positions
bdwidth = 5;
topbdwidth = 80;

set(0,'Units','pixels')
scnsize = get(0,'ScreenSize');

if visualise_major 
    pos1  = [bdwidth,...
        1/2*scnsize(4) + bdwidth,...
        scnsize(3)/2 - 2*bdwidth,...
        scnsize(4)/2 - (topbdwidth + bdwidth)];
    
    pos2 = [pos1(1) + scnsize(3)/2,...
        pos1(2),...
        pos1(3),...
        pos1(4)];

     f1 = figure('Position',pos1);
 
     f2 = figure('Position',pos2);

    figs = [f1 f2];
end

%**************************************************************************
% initialisations
%--------------------------------------------------------------------------

% saliency masks
num_saliency_types = length(find(saliency_type));
%saliency_masks = zeros(nrows,ncols,num_saliency_types,'uint8');
saliency_masks = zeros(nrows,ncols,num_saliency_types);

%**************************************************************************
% computations
%--------------------------------------------------------------------------
% pre-processing
%--------------------------------------------------------------------------
if verbose
    disp('Preprocessing...');
end

tic;
t0 = clock;

% apply the ROI mask if given 
if ~isempty(ROI_mask)
    ROI_only = image_data.*uint8(ROI_mask);
else
    ROI_only = image_data;
end

if verbose
    disp('Elapsed time for pre-processing: ');toc
end


%..........................................................................
% processing
%..........................................................................

% binarization
if verbose
    disp('Max conncomp binarization... ');tic
end

[binary_image, otsu, num_cc, thresh] = max_conncomp_thresholding(ROI_only, ...
    num_levels, offset, otsu_only, ...
    morphology_parameters, weights, [verbose visualise_minor]);

if visualise_major
    figure('Position',scnsize);
    
    subplot(221); imshow(image_data); title('Gray-scale image'); axis on, grid on;
    subplot(222);imshow(ROI_only); title('ROI'); axis on, grid on;
    
    subplot(223); plot(1:num_levels, num_cc, 'b');
    title('Normalized number of Connected Components');
    hold on; line('XData',[thresh thresh], ...
        'YData', [0 1.2], 'Color', 'r');
    hold on; line('XData',[otsu otsu], ...
        'YData', [0 1.2], 'Color', 'b');
    
    hold off;axis on; grid on;
    
    subplot(224); imshow(double(binary_image)); axis on;grid on;
    title(['Binarized image at level ' num2str(thresh)]);
end
        
if verbose
    disp('Elapsed time for max conncomp binarization: ');toc
end


% saliency
if verbose
    disp('Binary saliency... ');tic
end
[saliency_masks] = binary_detector(binary_image, morph_params_binary,...
                                        saliency_type, visualise_minor);
if verbose
    disp('Elapsed time for binary saliency... ');toc
end


%visualisation    
if visualise_major   
    visualize_regions_overlay(ROI_only, saliency_masks, saliency_type, figs);
end

    
%..........................................................................
% get the equivalent ellipses
%..........................................................................
num_regions = 0;
features = [];

if verbose
    disp('Creating the features from the saliency masks...');
end

tic;
i = 0;

if holes_flag
    i = i+1;
    holes = saliency_masks(:,:,i);
    if find(holes)
        [num_sub_regions, sub_features] = binary_mask2features(holes, connectivity, 1);
        num_regions = num_regions + num_sub_regions;
        features = [features; sub_features];
    end
end
if islands_flag
    i = i+1;
    islands = saliency_masks(:,:,i);
    if find(islands)
        [num_sub_regions, sub_features] = binary_mask2features(islands, connectivity, 2);
        num_regions = num_regions + num_sub_regions;
        features = [features; sub_features];
    end
end
if indentations_flag
    i = i+1;
    indentations = saliency_masks(:,:,i);
    if find(indentations)
        [num_sub_regions, sub_features] = binary_mask2features(indentations, connectivity, 3);
        num_regions = num_regions + num_sub_regions;
        features = [features; sub_features];
    end
end
if protrusions_flag
    i = i+1;
    protrusions = saliency_masks(:,:,i);
    if find(protrusions)
        [num_sub_regions, sub_features] = binary_mask2features(protrusions, connectivity, 4);
        num_regions = num_regions + num_sub_regions;
        features = [features; sub_features];
    end
end

if verbose
   disp('Elapsed time for the computation of the features. ');toc
end

if verbose
       disp(['Total elapsed time:  ' num2str(etime(clock,t0))]);
end


end