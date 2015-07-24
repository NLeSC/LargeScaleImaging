% mssr- main function of the SMSSR detector 
%**************************************************************************
% [num_regions, features, saliency_masks] = smssr(image_data,ROI_mask,...
%                                           num_levels, saliency_type, ...
%                                           thresh_type, ...    
%                                           region_params, execution_flags)
%
% author: Elena Ranguelova, NLeSc
% date created: 27 May 2015
% last modification date: 23 June 2015
% modification details: added hysteresis thresholding for binarization
% modification date: 22 June 2015
% modification details: added parameter for the type of  thresholding- 
%                       <m>ultithresholding or <h>ysteresis
%**************************************************************************
% INPUTS:
% image_data        the input gray-level image data
% [ROI_mask]        the Region Of Interenst binary mask [optional]
%                   if specified should contain the binary array ROI
%                   if left out or empty [], the whole image is considered
% [num_levels]      number of gray levels to consider
% [saliency_type]   array with 4 flags for the 4 saliency types 
%                   (Holes, Islands, Indentations, Protrusions)
%                   [optional], if left out- default is [1 1 1 1]
% [thresh_type]     character 's' for simple thresholding, 
%                   'm' for multithresholding or 'h' for
%                   hysteresis, [optional], if left out default is 'h'
% [region_params]   region parameters [SE_size_factor, area_factor, saliency_thresh]
%                   SE_size_factor- structuring element (SE) size factor  
%                   area_factor- area factor for the significant CC, 
%                   saliency_thresh- percentage of kept regions
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
% mssr- the MSSR detector 
%**************************************************************************
% EXAMPLES USAGE: 
% cl;
% if ispc 
%     starting_path = fullfile('C:','Projects');
% else
%     starting_path = fullfile(filesep,'home','elena');
% end
% image_filename = fullfile(starting_path,'eStep','LargeScaleImaging',...
%            'Data','AffineRegions','Phantom','phantom.png');
% image_data =imread(image_filename);
% [num_regions, features, saliency_masks] = ...
%                                      smssr(image_data);
% finds all types of saleint regions for the image
%--------------------------------------------------------------------------
% [num_regions, features, saliency_masks] = ...
%                        smssr(image_data,[],[],[1 1 1 1],'m',[],[1 1 0 0]);
% finds only the 'holes' and 'islands' for the whole image in verbose mode
% multithresholding is used as binarization method
%--------------------------------------------------------------------------
% load ROI_mask; 
% [num_regions, features, saliency_masks] = ...
%               smssr(image_data, ROI_mask);
% finds all types of salient regions within the presegmented ROI (tail)
%--------------------------------------------------------------------------
% see also test_mssr.m
%**************************************************************************
% RERERENCES:
%**************************************************************************
function [num_regions, features, saliency_masks] = smssr(image_data,ROI_mask,...
                                           num_levels, saliency_type, ...
                                           thresh_type,...
                                           region_params, execution_flags)

                                         
%**************************************************************************
% input control                                         
%--------------------------------------------------------------------------
if nargin < 7 || length(execution_flags) <3
    execution_flags = [0 0 0];
end
if nargin < 6 || isempty(region_params) || length(region_params) < 3
    region_params = [0.02 0.03 0.7];
end
if nargin < 5
    thresh_type = 's';
end
if nargin < 4 || isempty(saliency_type) || length(saliency_type) < 4
    saliency_type = [1 1 1 1];
end
if nargin < 3 || isempty(num_levels)
    num_levels = 25;
end
if nargin < 2
    ROI_mask = [];
end
if nargin < 1
    error('smssr.m requires at least 1 input argument- the gray_level image!');
    num_regions = 0;
    featurs = [];
    saliency_masks = [];
    return
end

%**************************************************************************
% input parameters -> variables
%--------------------------------------------------------------------------
% structuring element (SE) size factor  
SE_size_factor=region_params(1);
if ndims(region_params) > 1
    % area factor for the significant CC
    area_factor = region_params(2);
else
    area_factor = 0.03;
end
if ndims(region_params) > 2   
    % thresholding the salient regions
    saliency_thresh = region_params(3);
else
    saliency_thresh =  0.7;
end

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
[nrows, ncols] = size(image_data);

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
    f3 = figure('Position',pos2);
    f4 = figure('Position',pos3);
    f5 = figure('Position',pos2);
    f6 = figure('Position',pos3);
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

% thresholded saliency masks
holes_thresh = zeros(nrows,ncols);
islands_thresh = zeros(nrows,ncols);
indentations_thresh = zeros(nrows,ncols);
protrusions_thresh = zeros(nrows,ncols);

% final saliency masks
saliency_masks = zeros(nrows,ncols,4);

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

% apply the ROI mask if given and get the range of gray levels
if ~isempty(ROI_mask)
    ROI_only = image_data.*uint8(ROI_mask);
else
    ROI_only = image_data;
end


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
if verbose
    disp('Processing per gray level...');
end

tic;

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
    [saliency_masks_level, binary_image] = smssr_gray_level(ROI_only, ...
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
         subplot(221);imshow(image_data); freezeColors; title('Original image');axis image;axis on;
         subplot(222);imshow(holes_acc);%imshow(holes_acc,mycmap);
         axis image;axis on;title('holes');freezeColors; 
        end
        % indentations
        if indentations_flag
         figure(f4);
         subplot(221);imshow(image_data); freezeColors;title('Original image');axis image;axis on;
         subplot(222);imshow(indentations_acc); %imshow(indentations_acc,mycmap);
         axis image;axis on;title('indentations');freezeColors; 
        end
        % islands
        if islands_flag
         figure(f5);
         subplot(221);imshow(image_data); freezeColors;title('Original image');axis image;axis on;
         subplot(222);imshow(islands_acc);%imshow(islands_acc,mycmap);
         axis image;axis on;title('islands');freezeColors; 
        end
        % protrusions
        if protrusions_flag
         figure(f6);
         subplot(221);imshow(image_data); freezeColors;title('Original image');axis image;axis on;
         subplot(222);imshow(protrusions_acc);%imshow(protrusions_acc,mycmap);
         axis image;axis on; title('protrusions'); freezeColors; 
        end
    end
    

% close the waitbar
  close(wb_handle);
%..........................................................................
% threshold the cumulative saliency masks 
%..........................................................................
if verbose
    disp('Thresholding the saliency maps...');
end

tic;
% the holes and islands
if find(holes_acc)
   % holes_thresh = thresh_cumsum(holes_acc, saliency_thresh, verbose);
    holes_thresh = uint8(holes_acc > 0);
end
if find(islands_acc)
   % islands_thresh = thresh_cumsum(islands_acc, saliency_thresh, verbose);
    islands_thresh = uint8(islands_acc > 0);
end

% the indentations and protrusions
if find(indentations_acc)
   %indentations_thresh = thresh_area(indentations_acc, saliency_thresh, verbose);
    indentations_thresh = uint8(indentaitons_acc > 0);
end
if find(protrusions_acc)
   %protrusions_thresh = thresh_area(protrusions_acc, saliency_thresh, verbose);
   protrusions_thresh = uint8(protrusions_acc > 0);
end
  
%visualisation
if visualise_major
    visualise_regions();
end

if verbose
   disp('Elapsed time for the thresholding: ');toc
end

    
%**************************************************************************
%variables -> output parameters
%--------------------------------------------------------------------------
%all saliency masks in one array
saliency_masks(:,:,1) = holes_thresh;
saliency_masks(:,:,2) = islands_thresh;
saliency_masks(:,:,3) = protrusions_thresh;
saliency_masks(:,:,4) = indentations_thresh;

%..........................................................................
% get the equivalent ellipses
%..........................................................................
num_regions = 0;

for i=1:4
    if find(saliency_masks(:,:,i))
        [LE, num_reg] = bwlabel(saliency_masks(:,:,i),4);
          stats = regionprops(LE, 'Centroid','MajorAxisLength',...
                                          'MinorAxisLength','Orientation');

            for j = 1:num_reg

                %ellipse parameters
                  a = fix(getfield(stats,{j},'MajorAxisLength')/2);  
                  b = fix(getfield(stats,{j},'MinorAxisLength')/2);

                  if ((a>0) && (b>0))
                      num_regions = num_regions+1;
                      C = getfield(stats,{j},'Centroid');
                      x0 = C(1); y0= C(2);
                      phi_deg = getfield(stats,{j},'Orientation');
                      if (phi_deg==0)
                          phi_deg = 180;
                      end
                      phi = phi_deg*pi/180;

                      % compute the MSER features 
                      [A, B, C] = conversion_ellipse(a, b, -phi);
                      features(num_regions,:) = [x0; y0; A; B; C; i]'; %#ok<AGROW>

                  end
            end % for j
     end
end

if verbose
       disp(['Total elapsed time:  ' num2str(etime(clock,t0))]);
end

    function visualise_regions()

        % define colors
        blue = [0 0 255];
        yellow = [255 255 0];
        green = [0 255 0];
        red = [255 0 0];

        % holes
        if holes_flag && ~isempty(find(holes_thresh, 1))

            rgb = image_data;
            rgb = imoverlay(rgb, holes_thresh, blue);

            figure(f3);
            subplot(223);imshow(holes_thresh);
            title('thresholded holes');axis image;axis on;
            drawnow;
            subplot(224); imshow(rgb); axis on; title('Detected holes');
        end
        % indentations
        if indentations_flag && ~isempty(find(indentations_thresh,1))
            rgb = image_data;
            rgb = imoverlay(rgb, indentations_thresh, green);

            figure(f4);
            subplot(223);imshow(indentations_thresh);
            title('thresholded indentations');axis image;axis on;
            drawnow;
            subplot(224); imshow(rgb); axis on; title('Detected indentations');
        end
        % islands
        if islands_flag && ~isempty(find(islands_thresh,1))
            rgb = image_data;
            rgb = imoverlay(rgb, islands_thresh, yellow);

            figure(f5);
            subplot(223);imshow(islands_thresh);
            title('thresholded islands');axis image;axis on;
            drawnow;
            subplot(224); imshow(rgb); axis on; title('Detected islands');
        end
        % protrusions
        if protrusions_flag && ~isempty(find(protrusions_thresh,1))
            rgb = image_data;
            rgb = imoverlay(rgb, protrusions_thresh, red);

            figure(f6);
            subplot(223);imshow(protrusions_thresh);
            title('thresholded protrusions');axis image;axis on;
            drawnow;
            subplot(224); imshow(rgb); axis on; title('Detected protrusions');
        end
    end

end