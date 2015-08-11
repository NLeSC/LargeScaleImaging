% smssr_acc_masks- obtain the accumulated masks of the SMSSR detector 
%**************************************************************************
% [acc_masks] = smssr_acc_masks(image_ROI, num_levels, thresh_type,...
%                               SE_size_factor, area_factor,...
%                               saliency_type, execution_flags)
%
% author: Elena Ranguelova, NLeSc
% date created: 11 August 2015
% last modification date: 
% modification details: 
%**************************************************************************
% INPUTS:
% image_ROI        the input ROI image data
% [num_levels]      number of gray levels to consider
% [thresh_type]    character 's' for simple thresholding, 
%                  'm' for multithresholding or 'h' for
%                  hysteresis, [optional], if left out default is 'h'
% [SE_size_factor]   structuring element (SE) size factor  
% [area_factor]      area factor for the significant CC 
% [saliency_type]  array with 4 flags for the 4 saliency types 
%                  (Holes, Islands, Indentations, Protrusions)
%                  [optional], if left out- default is [1 1 1 1]
% [execution_flags] vector with 3 flags [verbose, visualise_major, ...
%                                                       visualise_minor]
%                   [optional], if left out- default is [0 0 0]
%                   visualise_major "overrides" visualise_minor
%**************************************************************************
% OUTPUTS:
% acc_masks    3-D array of the accumulated saliency masks of the regions
%                   for example acc_masks(:,:,1) contains the holes
%**************************************************************************
% SEE ALSO
% smssr_old- the oldimplemntation of the SMSSR detector 
%**************************************************************************
% RERERENCES:
%**************************************************************************
function [acc_masks] = smssr_acc_masks(image_ROI, num_levels, thresh_type,...
                               SE_size_factor, area_factor,...
                               saliency_type, execution_flags)

                                         
%**************************************************************************
% input control                                         
%--------------------------------------------------------------------------
if nargin < 7 || length(execution_flags) <3
    execution_flags = [0 0 0];
end
if nargin < 6 || isempty(saliency_type) || length(saliency_type) < 4
    saliency_type = [1 1 1 1];
end
if nargin < 5
    area_factor = 0.03;
end
if nargin < 4
    SE_size_factor = 0.02;
end
if nargin < 3
    thresh_type = 's';
end
if nargin < 2 || isempty(num_levels)
    num_levels = 25;
end
if nargin < 1
    error('smssr_acc_masks.m requires at least 1 input argument- the gray_level ROI!');
    acc_masks = [];
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

% execution flags
verbose = execution_flags(1);
visualise_major = execution_flags(2);
visualise_minor = execution_flags(3);    

if visualise_minor
    visualise_major = 1;  
end

%**************************************************************************
% parameters
%--------------------------------------------------------------------------
% image dimensions
[nrows, ncols] = size(image_ROI);

% set up the figures positions
bdwidth = 5;
topbdwidth = 80;

set(0,'Units','pixels')
scnsize = get(0,'ScreenSize');
wait_pos = [0.2*scnsize(3), 0.2*scnsize(4),scnsize(3)/4, scnsize(4)/20 ];

if visualise_minor || visualise_major
    pos1  = [bdwidth,... 
        1/2*scnsize(4) + bdwidth,...
        scnsize(3)/2 - 2*bdwidth,...
        scnsize(4)/2 - (topbdwidth + bdwidth)];

         pos2 = [pos1(1) + scnsize(3)/2,...
         pos1(2),...
         pos1(3),...
         pos1(4)];
    
        pos3 = [pos1(1) + scnsize(3)/2,...
         bdwidth,...
         pos1(3),...
         pos1(4)];

    f1 = figure('Position',pos1);
    f2 = figure('Position',pos3);
    if holes_flag
       f3 = figure('Position',pos2);
    end
    if indentations_flag
        f4 = figure('Position',pos3);
    end
    if islands_flag
        f5 = figure('Position',pos2);
    end
    if protrusions_flag
        f6 = figure('Position',pos3);
    end
    load('MyColormaps','mycmap'); 
end

%**************************************************************************
% initialisations
%--------------------------------------------------------------------------
% saliency masks per gray level
holes_level = zeros(nrows,ncols);
islands_level = zeros(nrows,ncols);
indentations_level = zeros(nrows,ncols);
protrusions_level = zeros(nrows,ncols);

% accumulative saliency masks
holes_acc = zeros(nrows,ncols);
islands_acc = zeros(nrows,ncols);
indentations_acc = zeros(nrows,ncols);
protrusions_acc = zeros(nrows,ncols);

% final saliency masks
acc_masks = zeros(nrows,ncols,4);

%**************************************************************************
% computations
%--------------------------------------------------------------------------
tic;
t0 = clock;

%--------------------------------------------------------------------------
% parameters depending on pre-processing
%--------------------------------------------------------------------------
% find optimal thresholds
switch thresh_type
    case 's'
        thresholds = fix(1:255/num_levels:255);
    case 'm'
        thresholds = multithresh(image_data, num_levels);
        num_levels = length(thresholds);
        thresh_type ='s';
    case 'h'
        step = fix(255/num_levels);
        high_thresholds  = step:step:255;
        low_thresholds = 0:step:255-step;
        num_levels = length(high_thresholds);
end

%--------------------------------------------------------------------------
% core processing
%--------------------------------------------------------------------------
% waitbar
%if visualise_major
    wb_handle = waitbar(0,'SMSSR detection computaitons: please wait...',...
                        'Position',wait_pos);
    wb_counter = 0;
%end
%..........................................................................
% compute binary saliency for every sampled gray-level
%..........................................................................

for it = 1:num_levels
     wb_counter = wb_counter + 1;
     waitbar(wb_counter/num_levels);
     drawnow

    switch thresh_type
        case 'm'
        case 's'
            level = thresholds(it);
        case 'h'
            level(1) = high_thresholds(it);
            level(2) = low_thresholds(it);                
    end
    %pause
    [saliency_masks_level, binary_image] = smssr_gray_level(image_ROI, ...
                                            thresh_type, level, ...
                                            SE_size_factor, area_factor,...
                                            saliency_type, visualise_minor);
    % cumulative saliency masks
    holes_level = saliency_masks_level(:,:,1);
    islands_level = saliency_masks_level(:,:,2);
    indentations_level = saliency_masks_level(:,:,3);
    protrusions_level = saliency_masks_level(:,:,4);
    
    holes_acc = holes_acc + holes_level;
    islands_acc = islands_acc + islands_level;
    indentations_acc = indentations_acc + indentations_level;
    protrusions_acc = protrusions_acc + protrusions_level;

    %pause;
    % visualisation
    if visualise_major
        if holes_flag
         figure(f1);subplot(221);imagesc(holes_acc); axis image; axis on;
         set(gcf, 'Colormap',mycmap);title('holes');colorbar('South');         
        end
        if islands_flag
         subplot(222);imagesc(islands_acc);axis image;axis on;
         set(gcf, 'Colormap',mycmap);title('islands');colorbar('South');
        end
        if indentations_flag
         subplot(223);imagesc(indentations_acc);axis image;axis on;
         set(gcf, 'Colormap',mycmap);title('indentations');colorbar('South');
        end
        if protrusions_flag
         subplot(224);imagesc(protrusions_acc);axis image;axis on;
         set(gcf, 'Colormap',mycmap);title('protrusions');colorbar('South');                   
        end
        figure(f2);imshow(binary_image);
        if size(level) > 1
            title(['Segmented image at thresholds: ' ...
                num2str(level(2))  ' and ' num2str(level(1)) ]);
        else
            title(['Segmented image at threshold: ' num2str(level)]);
        end
        axis image; axis on;
    end
end
    if verbose
        disp('Elapsed time for the core processing: ');toc
    end

    %visualisation
    if visualise_major
        if holes_flag
         figure(f3);
         subplot(221);imshow(image_ROI); freezeColors; title('Original image');axis image;axis on;
         subplot(222);imshow(holes_acc);%imshow(holes_acc,mycmap);
         axis image;axis on;title('holes');freezeColors; 
        end
        % indentations
        if indentations_flag
         figure(f4);
         subplot(221);imshow(image_ROI); freezeColors;title('Original image');axis image;axis on;
         subplot(222);imshow(indentations_acc); %imshow(indentations_acc,mycmap);
         axis image;axis on;title('indentations');freezeColors; 
        end
        % islands
        if islands_flag
         figure(f5);
         subplot(221);imshow(image_ROI); freezeColors;title('Original image');axis image;axis on;
         subplot(222);imshow(islands_acc);%imshow(islands_acc,mycmap);
         axis image;axis on;title('islands');freezeColors; 
        end
        % protrusions
        if protrusions_flag
         figure(f6);
         subplot(221);imshow(image_ROI); freezeColors;title('Original image');axis image;axis on;
         subplot(222);imshow(protrusions_acc);%imshow(protrusions_acc,mycmap);
         axis image;axis on; title('protrusions'); freezeColors; 
        end
    end
    

% close the waitbar
  close(wb_handle);
  
%**************************************************************************
%variables -> output parameters
%--------------------------------------------------------------------------
%all saliency masks in one array
acc_masks(:,:,1) = holes_acc;
acc_masks(:,:,2) = islands_acc;
acc_masks(:,:,3) = protrusions_acc;
acc_masks(:,:,4) = indentations_acc;
