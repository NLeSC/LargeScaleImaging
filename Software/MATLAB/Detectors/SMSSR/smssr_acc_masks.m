% smssr_acc_masks- obtain the accumulated masks of the SMSSR detector 
%**************************************************************************
% [acc_masks] = smssr_acc_masks(image_ROI, num_levels, steps, thresh_type,...
%                               morphology_params, ...
%                               saliency_type, execution_flags, figs)
%
% author: Elena Ranguelova, NLeSc
% date created: 11 August 2015
% last modification date: 30 May 2016
% modification details: added 2 morphology_parameters
% last modification date: 19.08.205
% modification details: added number of gray level steps as parameters
% last modification date: 12.08.205
% modification details: the third dimension of the output depends on the
%                       saliency types requested
%**************************************************************************
% INPUTS:
% image_ROI        the input ROI image data
% [num_levels]      number of gray levels to consider
% [steps]           number of gray level steps
% [thresh_type]    character 's' for simple thresholding, 
%                  'm' for multithresholding or 'h' for
%                  hysteresis, [optional], if left out default is 'h'
% [morphology_parameters] vector with 4 values corresponding to
%                   SE_size_factor- size factor for the structuring element
%                   area_factor - area factor for the significant connected 
%                   components (CCs)
%                   lambda_factor- factor for the parameter lambda for the
%                   morphological opening (noise reduction)
%                   connectivity - for the morhpological opening
%                   default values [0.02 0.05 3 4]
% [saliency_type]  array with 4 flags for the 4 saliency types 
%                  (Holes, Islands, Indentations, Protrusions)
%                  [optional], if left out- default is [1 1 1 1]
% [execution_flags] vector with 3 flags [verbose, visualise_major, ...
%                                                       visualise_minor]
%                   [optional], if left out- default is [0 0 0]
%                   visualise_major "overrides" visualise_minor
% figs             figure handles
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
function [acc_masks] = smssr_acc_masks(image_ROI, num_levels, steps, thresh_type,...
                               morphology_parameters,...
                               saliency_type, execution_flags, figs)

                                         
%**************************************************************************
% input control                                         
%--------------------------------------------------------------------------
if nargin < 7 || length(execution_flags) <3
    execution_flags = [0 0 0];
end
if nargin < 6 || isempty(saliency_type) || length(saliency_type) < 4
    saliency_type = [1 1 1 1];
end
if nargin < 5 || length(morphology_parameters)<4
    morphology_parameters = [0.02 0.05 3 4]; 
end
if nargin < 4
    thresh_type = 's';
end
if nargin < 3
    steps = [5 10 20 50];
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

if visualise_major
    f1 = figs(1);
    f2 = figs(2);
    if holes_flag
        f3 = figs(3);
    end
    if indentations_flag
        f4 = figs(4);
    end
    if islands_flag
        f5 = figs(5);
    end
    if protrusions_flag
        f6 = figs(6);
    end
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
    load('MyColormaps','mycmap'); 
end

%**************************************************************************
% initialisations
%--------------------------------------------------------------------------
% accumulative saliency masks
if holes_flag
    holes_acc = zeros(nrows,ncols,length(steps)+1);
end
if islands_flag
    islands_acc = zeros(nrows,ncols,length(steps)+1);
end
if indentations_flag
    indentations_acc = zeros(nrows,ncols,length(steps)+1);
end
if protrusions_flag
    protrusions_acc = zeros(nrows,ncols,length(steps)+1);
end

% final saliency masks
num_saliency_types = length(find(saliency_type));
acc_masks = zeros(nrows,ncols,num_saliency_types);

%**************************************************************************
% computations
%--------------------------------------------------------------------------
tic;
t0 = clock;

%--------------------------------------------------------------------------
% parameters depending on pre-processing
%--------------------------------------------------------------------------
% find optimal thresholds
min_level =  1; max_level = 255;
step = (max_level - min_level)/num_levels;
if step == 0
    step = 1;
end

switch thresh_type
    case 's'        
        thresholds = fix(min_level:step:max_level-step);
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
%..........................................................................
% compute binary saliency for every sampled gray-level
%..........................................................................

j =0;
for st = [steps]
    wb_handle = waitbar(0,'SMSSR detection computaitons: please wait...',...
                        'Position',wait_pos);
    wb_counter = 0;
    j = j+1;
    for it = 1:st:num_levels
         wb_counter = wb_counter + 1;
         waitbar(wb_counter/length(1:st:num_levels));
         drawnow

        switch thresh_type
            case 'm'
            case 's'
                level = thresholds(it);
            case 'h'
                level(1) = high_thresholds(it);
                level(2) = low_thresholds(it);                
        end
        
        [saliency_masks_level, binary_image] = gray_level_detector(image_ROI, ...
                                                thresh_type, level, ...
                                                morphology_parameters,...
                                                saliency_type, visualise_minor);
        % cumulative saliency masks
        i =0;
        if holes_flag    
            i = i+1;
            holes_acc(:,:,j) = holes_acc(:,:,j) + saliency_masks_level(:,:,i);
        end
   %     holes_acc(:,:,j) = medfilt2(holes_acc(:,:,j)); 
        if islands_flag    
            i = i+1;
            islands_acc(:,:,j) = islands_acc(:,:,j) + saliency_masks_level(:,:,i);
        end
  %      islands_acc(:,:,j) = medfilt2(islands_acc(:,:,j)); 
        if indentations_flag    
            i = i+1;
            indentations_acc(:,:,j) = indentations_acc(:,:,j) + saliency_masks_level(:,:,i);
        end
%        holes_acc(:,:,j) = medfilt2(holes_acc(:,:,j)); 
        if protrusions_flag    
            i = i+1;
            protrusions_acc(:,:,j) =  protrusions_acc(:,:,j) + saliency_masks_level(:,:,i);
        end
%        holes_acc(:,:,j) = medfilt2(holes_acc(:,:,j)); 

        % visualisation
        if visualise_major
            if holes_flag
             figure(f1);subplot(221);imagesc(holes_acc(:,:,j)); axis image; axis on; grid on;
             set(gcf, 'Colormap',mycmap);title('holes');colorbar('South');         
            end
            if islands_flag
             subplot(222);imagesc(islands_acc(:,:,j));axis image;axis on; grid on;
             set(gcf, 'Colormap',mycmap);title('islands');colorbar('South');
            end
            if indentations_flag
             subplot(223);imagesc(indentations_acc(:,:,j));axis image;axis on; grid on;
             set(gcf, 'Colormap',mycmap);title('indentations');colorbar('South');
            end
            if protrusions_flag
             subplot(224);imagesc(protrusions_acc(:,:,j));axis image;axis on; grid on;
             set(gcf, 'Colormap',mycmap);title('protrusions');colorbar('South');                   
            end
            if visualise_major
                figure(f3);imshow(binary_image);
                if size(level) > 1
                    title(['Segmented image at gray levels: ' ...
                        num2str(level(2))  ' and ' num2str(level(1)) ]);
                else
                    title(['Segmented image at gray level: ' num2str(level)]);
                end
                axis image; axis on; grid on;
            end
       end
    end
    %pause;
    % close the waitbar
    close(wb_handle);
end

if verbose
    disp('Elapsed time for the core processing: ');toc
end


 
%**************************************************************************
%variables -> output parameters
%--------------------------------------------------------------------------
%all saliency masks in one array
i = 0;
if holes_flag
    i =i+1;
    acc_masks(:,:,i) = sum(holes_acc,3);
    %acc_masks(:,:,i) = medfilt2(acc_masks(:,:,i));
end
if islands_flag
    i =i+1;
    acc_masks(:,:,i) = sum(islands_acc,3);
    %acc_masks(:,:,i) = medfilt2(acc_masks(:,:,i));    
end
if indentations_flag
    i =i+1;
    acc_masks(:,:,i) = sum(indentations_acc,3);
    %acc_masks(:,:,i) = medfilt2(acc_masks(:,:,i));    
end
if protrusions_flag
    i =i+1;
    acc_masks(:,:,i) = sum(protrusions_acc,3);
    %acc_masks(:,:,i) = medfilt2(acc_masks(:,:,i));    
end

if visualise_major
    i = 0;
    if holes_flag
        i = i+1;
        figure(f1);subplot(221);imagesc(acc_masks(:,:,i)); axis image; axis on; grid on;
        set(gcf, 'Colormap',mycmap);title('holes');colorbar('South');
    end
    if islands_flag
        i = i+1;
        subplot(222);imagesc(acc_masks(:,:,i));axis image;axis on; grid on;
        set(gcf, 'Colormap',mycmap);title('islands');colorbar('South');
    end
    if indentations_flag
        i = i+1;
        subplot(223);imagesc(acc_masks(:,:,i));axis image;axis on; grid on;
        set(gcf, 'Colormap',mycmap);title('indentations');colorbar('South');
    end
    if protrusions_flag
        i = i+1;
        subplot(224);imagesc(acc_masks(:,:,i));axis image;axis on; grid on;
        set(gcf, 'Colormap',mycmap);title('protrusions');colorbar('South');
    end
end

%visualisation
i =0;
if visualise_major
    if holes_flag
        i = i + 1;
        figure(f3);
        subplot(221);imshow(image_ROI); freezeColors; title('Original image');axis image;axis on;
        subplot(222);imshow(acc_masks(:,:,i));
        axis image;axis on;title('holes');freezeColors;
    end
    % islands
    if islands_flag
        i =i+1;
        figure(f5);
        subplot(221);imshow(image_ROI); freezeColors;title('Original image');axis image;axis on;
        subplot(222);imshow(acc_masks(:,:,i));
        axis image;axis on;title('islands');freezeColors;
    end   
    % indentations
    if indentations_flag
        i = i+1;
        figure(f4);
        subplot(221);imshow(image_ROI); freezeColors;title('Original image');axis image;axis on;
        subplot(222);imshow(acc_masks(:,:,i)); 
        axis image;axis on;title('indentations');freezeColors;
    end    
    % protrusions
    if protrusions_flag
        i = i+1;
        figure(f6);
        subplot(221);imshow(image_ROI); freezeColors;title('Original image');axis image;axis on;
        subplot(222);imshow(acc_masks(:,:,i));
        axis image;axis on; title('protrusions'); freezeColors;
    end
end