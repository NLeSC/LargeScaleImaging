% max_conncomp_thresholding.m- connected component(CC)-based thresholding
%**************************************************************************
% [binary_image, otsu, num_combined_cc, thresh] = max_conncomp_thresholding(gray_image,
%                               num_levels, offset, otsu_only,
%                               morpholigy_parameters, weights,
%                               execution_flags)
%
% author: Elena Ranguelova, NLeSc
% date created: 07.10.2015
% last modification date: 5 Jan 2016
% modification details: binary_masks is decalred 'uint8' for memory saving!
%                       also the binary_image is calculated explicitely
%                       using the determined threshold (to be double,
%                       otherwise types don't match well!)
% last modification date: 16 Oct 2015
% modification details: added flag for Otsu only
%**************************************************************************
% INPUTS:
% gray_image        matrix containing the gray-scale image
% [num_levels]      number of gray levels to be considered [1..255],
%                   default 255, i.e. all, step 1
% [offset]          the offset (number of levels) from Otsu to be processed
%                   default value- 80
% [otsu_only]       flag to perform only Otsu thresholding
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
% [execution_flags] vector of 2 elements, controlling the execution
%                   verbose- verbose mode
%                   visualize- vizualize
%                   default value- [0 0]
%**************************************************************************
% OUTPUTS:
% binary_image      the binarized gray level image
% otsu              the Otsu threshold (gray level)
% num_combined_cc            combined number of connected components
% thresh            the threshold used for binarization- the max of
%                   the weighted combination among the 3 number of CCs
%**************************************************************************
% EXAMPLES USAGE:
%
%**************************************************************************
% REFERENCES:
%**************************************************************************
function [binary_image, otsu, num_combined_cc, thresh] = max_conncomp_thresholding(gray_image, ...
    num_levels, offset, otsu_only, ...
    morphology_parameters, weights, ...
    execution_flags)

%**************************************************************************
% input control
%--------------------------------------------------------------------------
if nargin < 7 || length(execution_flags) < 2
    execution_flags = [0 0];
elseif nargin < 6 || length(weights) < 3
    weights = [0.33 0.33 0.33];
elseif nargin < 5 || length(morphology_parameters) < 5
    morphology_parameters = [0.02 0.1 0.001 3 8];
elseif nargin < 4
    otsu_only = false;
elseif nargin < 3
    offset = 80;
elseif nargin < 2
    num_levels = 255;
elseif nargin < 1
    error('max_conncomp_thresholding.m requires at least 1 input argument!');
end

%**************************************************************************
% input parameters -> variables
%--------------------------------------------------------------------------
% execution flags
verbose = execution_flags(1);
visualization = execution_flags(2);

% weights
weight_all = weights(1);
weight_large = weights(2);
weight_very_large = weights(3);

% morphology parameters
SE_size_factor = morphology_parameters(1);
Area_factor_very_large  = morphology_parameters(2);
Area_factor_large = morphology_parameters(3);
lambda_factor = morphology_parameters(4);
connectivity = morphology_parameters(5);

% gray levels
min_level =  1; max_level = 255;
step = (max_level - min_level)/(num_levels - 1);
if step < 1
    step = 1;
end

if not(otsu_only)
    
    % image dimensions
    [nrows, ncols] = size(gray_image);
    
    % image area
    Area = nrows*ncols;
    % areas for large and very large CCs
    Area_size_large = Area * Area_factor_large;
    Area_size_very_large = Area * Area_factor_very_large;
    
    % area opening parameter
    lambda = lambda_factor* fix(SE_size_factor*sqrt(Area/pi));
    
    %**************************************************************************
    % initialisations
    %--------------------------------------------------------------------------
    binary_masks = zeros(nrows,ncols, max_level,'uint8');
    num_cc = zeros(1,max_level);
    num_large_cc = zeros(1,max_level);
    num_very_large_cc = zeros(1,max_level);
    num_combined_cc = zeros(1,max_level);
end
%**************************************************************************
% computations
%--------------------------------------------------------------------------
% pre-processing

% Otsu thresholding
if verbose
    disp('Standart Otsu gray level thresholding...');
    tic
end
otsu = fix(255*graythresh(gray_image));
off = min(otsu-1, offset);
%if visualization
binary_otsu = gray_image >= otsu;
%end

if not (otsu_only)
    % thresholding for set of levels
    if verbose
        disp('Thresholding and denoising for the specified range of gray levels...');
    end
    for level = otsu - off: step: otsu + off
        binary = gray_image > level;
        binary_filt = bwareaopen(binary, lambda, connectivity);
        clear binary
        binary_filt2 = 1- bwareaopen(1- binary_filt, lambda, connectivity);
        binary_masks(:,:,fix(level)) = binary_filt2;
         
        clear binary_filt binary_filt2
    end
    
    % count number of all and large and very large connected components
    if verbose
        disp('Counting the number of CCes per gray level...');
    end
    for level = otsu - off: step: otsu + off
        l = fix(level);
       % imshow(double(binary_masks(:,:,l))); title(num2str(l));         
        CC = bwconncomp(binary_masks(:,:,l),connectivity);
        RP = regionprops(CC, 'Area');
        num = CC.NumObjects;
        num_cc(l) = num;
        ln = 0; vln = 0;
        for r = 1:  num
            regionArea =  RP(r).Area;
            if regionArea >= Area_size_very_large
                ln = ln+1;
                vln = vln + 1;
            else
                if regionArea >= Area_size_large
                    ln = ln + 1;
                end
            end
        end
%         num
%         ln
%         vln
%         pause;
        num_large_cc(l) = ln;
        num_very_large_cc(l) = vln;
    end
    
    if isempty(find(num_cc))
        error('No CCs found! ');
    end
    % normalize the counts
    if verbose
        disp('Normalizing the counts...');
    end
    [max_num, thresh_all] = max(num_cc(:)); %#ok<ASGLU>
    [max_large_num, thresh_large] = max(num_large_cc(:)); %#ok<ASGLU>
    [max_very_large_num, thresh_very_large] = max(num_very_large_cc(:)); %#ok<ASGLU>
    
    norm_num_cc = num_cc/max_num;
    norm_large_num_cc = num_large_cc/max_large_num;
    norm_very_large_num_cc = num_very_large_cc/max_very_large_num;
    
    % compute the final measure and find the maximum
    if verbose
        disp('Combining the counts and finding the maximum...');
    end
    
    num_combined_cc = (weight_all*norm_num_cc + ...
        weight_large* norm_large_num_cc+ ...
        weight_very_large*norm_very_large_num_cc);
    
    %**************************************************************************
    % variables -> output parameters
    %--------------------------------------------------------------------------
    [max_combined, thresh] = max(num_combined_cc);
    
    if verbose
        disp('Combined maximum number of CCs:'); disp(max_combined);
    end
    
    binary_image = gray_image >= thresh; %binary_masks(:,:,thresh);  
    clear binary_masks
    
    if verbose
        disp('Done.')
        disp('Elapsed time: ');
        toc
    end
    
    %**************************************************************************
    % visualization
    %--------------------------------------------------------------------------
    if visualization
        figure('Position',get(0,'ScreenSize'));
        [counts, centers] = hist(double(gray_image(:)),num_levels);
        subplot(221); plot(centers, counts,'k'); title('Gray-level histogram with Otsu threshold');
        hold on; line('XData',[otsu otsu], ...
            'YData', [0 max(counts)], 'Color', 'r'); hold off;axis on;grid on;
        legend;
        subplot(222);imshow(binary_otsu); axis on;grid on;
        title(['Image thresholded at Otsu s level ' num2str(otsu)]);
        
        %     subplot(223); plot(1:num_levels, norm_num_cc, 'k',...
        %         1:max_level, norm_large_num_cc,'b',...
        %         1:max_level, norm_very_large_num_cc,'m',...
        %         1:max_level, num_combined_cc, 'r');
        subplot(223); plot(1:num_levels, num_cc, 'k',...
            1:max_level, num_large_cc,'b',...
            1:max_level, num_very_large_cc,'m',...
            1:max_level, num_combined_cc, 'r');
        
        title('Normalized number of Connected Components');
        hold on; line('XData',[thresh thresh], ...
            'YData', [0 1.2], 'Color', 'r');
        hold on; line('XData',[thresh_all thresh_all], ...
            'YData', [0 1.2], 'Color', 'k');
        hold on; line('XData',[thresh_large thresh_large], ...
            'YData', [0 1.2], 'Color', 'b');
        hold on; line('XData',[thresh_very_large thresh_very_large], ...
            'YData', [0 1.2], 'Color', 'm');
        hold off;axis on; grid on;
        legend('all','large', 'very large', 'combined');
        subplot(224); imshow(double(binary_image)); axis on;grid on;
        title(['Binarized image at level ' num2str(thresh)]);
        
        
    end
else
    binary_image = binary_otsu;
    thresh = otsu;
    num_combined_cc = 0;
end
