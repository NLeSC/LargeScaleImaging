% mssr- main function of the MSSR detector 
%**************************************************************************
% [num_regions, features, saliency_masks] =...
%                            mssr(image_fname,ROI_mask_fname,num_levels,                                                          
%                                 saliency_type, region_params, ...
%                                 execution_flags)
%
% author: Elena Ranguelova, NLeSc
% date created: 19 May 2015
% last modification date: 19 May 2015
% modification details: 
%**************************************************************************
% INPUTS:
% image_fname- the image filename 
% [ROI_mask_fname]- the Region Of Interenst binary mask (*.mat) [optional]
%                   if specified should contain the binary array ROI
%                   if left out or empty [], the whole image is considered
% [num_levels] -number of gray levels to consider
% [saliency_type]- array with 4 flags for the 4 saliency types 
%                (Holes, Islands, Indentations, Protrusions)
%                [optional], if left out- default is [1 1 1 1]   
% [region_params]- salient region parameters [SE_size_factor, ...
%                                                      area_factor, thresh]
%                  SE_size_factor- structuring element (SE) size factor  
%                  area_factor- area factor for the significant CC, 
%                  thresh- percentage of kept regions
% [execution_flags] - vector with 3 flags [verbose, ...
%                                         visualise_major, visualise_minor]
%                     [optional], if left out- default is [0 0 0 0]
%                     visualise_major "overrides" visualise_minor
%**************************************************************************
% OUTPUTS:
% num_regions- number of detected salient regions
% features- the features of the equivalent ellipses to the salient regions
%           in format [x y a b c t], where (x,y)- ellipse centroid coords,
%           a(x-u)^2 + 2b(x-u)(y-v) + c(y-v)^2 = 1 - ellipse equation,
%           t- region type (1= Hol/2= Isl/ 3=Ind/ 4=Pr)
% saliency_masks - 3-D array of the binary saliency masks of the regions
%                  for example saliency_masks(:,:,1) contains the holes
%**************************************************************************
% SEE ALSO
% mssr_2008- the version of the detector from 2008
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
% [num_regions, features, saliency_masks] = ...
%                                      mssr(image_filename);
% finds all types of saleint regions for the image
%--------------------------------------------------------------------------
%[num_regions, features, saliency_masks] = ...
%                        mssr(image_filename,[],[],[1 1 1 1],[],[1 1 0 0]);
% finds only the 'holes' and 'islands' for the whole image in verbose mode
%--------------------------------------------------------------------------
% [num_regions, features, saliency_masks] = ...
%               mssr('..\data\tails\na0016_1_tail_image.jpg',...
%                   '..\data\tails\na0016_1_tail');
% finds all types of salient regions within the presegmented ROI (tail)
%**************************************************************************
% RERERENCES:Ranguelova, Pauwels, "Saliency detection and matching strategy
% for photo-ID of humpback whales", IJGVIP, Special issue on features, 2006
%**************************************************************************
function  [num_regions, features, saliency_masks] = mssr(image_fname, ...
                            ROI_mask_fname, num_levels, ...
                            saliency_type, region_params, execution_flags)
                                         
%**************************************************************************
% input control                                         
%--------------------------------------------------------------------------
if nargin < 6
    execution_flags = [0 0 0];
end
if nargin < 5 || isempty(region_params)
    region_params = [0.02 0.03 0.7];
end
if nargin < 4 || isempty(num_levels)
    num_levels = 25;
end
if nargin < 3 || isempty(saliency_type)
    saliency_type = [1 1 1 1];
end
if nargin < 2 
    ROI_mask_fname = [];
end
if nargin < 1
    error('mssr.m requires at least 1 input argument- the image filename!');
    num_regions = 0;
    featurs = [];
    saliency_masks = [];
    return
end

%**************************************************************************
%  parameters
%--------------------------------------------------------------------------
% structuring element (SE) size factor  
SE_size_factor=region_params(1);
% area factor for the significant CC
area_factor = region_params(2);
% thresholding the salient regions
thresh = region_params(3);

%**************************************************************************
% input parameters -> variables
%--------------------------------------------------------------------------
% image
I_or = imread(image_fname);
nrows = size(I_or,1);
ncols = size(I_or,2);

% ROI
ROI = [];
if ~isempty(ROI_mask_fname)
    s = load(ROI_mask_fname);
    s_cell = struct2cell(s);
    for k = 1:size(s_cell)
        field = s_cell{k};
        if islogical(field)
            ROI = field;
        end
    end
    if isempty(ROI)
       error('ROI_mask_fname does not contain binary mask!');
       num_regions = 0;
       featurs = [];
       saliency_masks = [];
       return
    end
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
    f2 = figure('Position',pos2);
    f3 = figure('Position',pos3);
    f4 = figure('Position',pos2);
    f5 = figure('Position',pos3);

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
% if the image is colour convert it to gray-scale

if verbose
    disp('Preprocessing...');
end

tic;
t0 = clock;

if ndims(I_or) == 3 
    if verbose  
        disp('Original image is colour- converting to gray-scale...');
    end
    I = rgb2gray(I_or);
else
    if verbose  
       disp('Original image is gray-scale.');
    end
    I = I_or;
end

% apply the ROI mask if given and get the range of gray levels
ROI_only = uint8(zeros(nrows, ncols));
if ~isempty(ROI)
    ROI_only = I.*uint8(ROI);
else
    ROI_only = I;
end

[otsu_thr,qual, mean_level1,mean_level2] = otsu_threshold(double(ROI_only(ROI_only>0)));

%--------------------------------------------------------------------------
% parameters depending on pre-processing
%--------------------------------------------------------------------------
% gray-level step
step = fix(255/num_levels);
if step == 0
    step = 1;
end
    
if verbose
    disp('Elapsed time for pre-processing: ');toc
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
    wb_handle = waitbar(0,'MSSR detection computaitons: please wait...','Position',wait_pos);
    wb_counter = 0;
%end

%..........................................................................
% compute binary saliency for every sampled gray-level
%..........................................................................
for level = 0 : step: 255 

    wb_counter = wb_counter + 1;
    waitbar(wb_counter/length(mean_level1:step:mean_level2));
    drawnow

    [saliency_masks_level] = mssr_gray_level(ROI_only, level, ...
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

    end
end
    if verbose
        disp('Elapsed time for the core processing: ');toc
    end

    %visualisation
    if visualise_major
        if holes_flag
         figure(f2);
         subplot(221);imshow(I_or); title('Original image');axis image;axis on;
         subplot(222);imshow(holes_acc,mycmap);
         axis image;axis on;title('holes');freezeColors; 
        end
        % indentations
        if indentations_flag
         figure(f3);
         subplot(221);imshow(I_or); title('Original image');axis image;axis on;
         subplot(222);imshow(indentations_acc,mycmap);
         axis image;axis on;title('indentations');freezeColors; 
        end
        % islands
        if islands_flag
         figure(f4);
         subplot(221);imshow(I_or); title('Original image');axis image;axis on;
         subplot(222);imshow(islands_acc,mycmap);
         axis image;axis on;title('islands');freezeColors; 
        end
        % protrusions
        if protrusions_flag
         figure(f5);
         subplot(221);imshow(I_or); title('Original image');axis image;axis on;
         subplot(222);imshow(protrusions_acc,mycmap);
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
    holes_thresh = thresh_cumsum(holes_acc, thresh, verbose);
end
if find(islands_acc)
    islands_thresh = thresh_cumsum(islands_acc, thresh, verbose);
end

% the indentations and protrusions
if find(indentations_acc)
    indentations_thresh = thresh_area(indentations_acc, thresh, verbose);
end
if find(protrusions_acc)
    protrusions_thresh = thresh_area(protrusions_acc, thresh, verbose);
end
  
    %visualisation
    if visualise_major
        % holes
        if holes_flag && ~isempty(find(holes_thresh, 1))
            if (ndims(I_or)==3)
                I_r=I_or(:,:,1); I_g=I_or(:,:,2); I_b=I_or(:,:,3);    
            else
                I_r = I_or; I_g = I_or; I_b = I_or;        
            end

             figure(f2);
             subplot(223);imshow(holes_thresh);set(gcf, 'Colormap',1-gray(256));
             title('thresholded holes');axis image;axis on;
             drawnow; 
             Per = zeros(nrows,ncols);
             Per = bwperim(holes_thresh);
             I_r(Per)=0; I_g(Per)=0; I_b(Per)=255; 
             I_reg(:,:,1)=I_r; I_reg(:,:,2)=I_g; I_reg(:,:,3)=I_b;
             I_reg = uint8(I_reg);
             subplot(224); imshow(I_reg); axis on; title('Detected holes');            
        end
        % indentations
        if indentations_flag && ~isempty(find(indentations_thresh,1))
            if (ndims(I_or)==3)
                I_r=I_or(:,:,1); I_g=I_or(:,:,2); I_b=I_or(:,:,3);    
            else
                I_r = I_or; I_g = I_or; I_b = I_or;        
            end

             figure(f3);
             subplot(223);imshow(indentations_thresh);set(gcf, 'Colormap',1-gray(256));
             title('thresholded indentations');axis image;axis on;
             drawnow; 
             Per = zeros(nrows,ncols);
             Per = bwperim(indentations_thresh);
             I_r(Per)=0; I_g(Per)=255; I_b(Per)=0; 
             I_reg(:,:,1)=I_r; I_reg(:,:,2)=I_g; I_reg(:,:,3)=I_b;
             I_reg = uint8(I_reg);
             subplot(224); imshow(I_reg); axis on; title('Detected indentations');               
        end
        % islands
        if islands_flag && ~isempty(find(islands_thresh,1))
            if (ndims(I_or)==3)
                I_r=I_or(:,:,1); I_g=I_or(:,:,2); I_b=I_or(:,:,3);    
            else
                I_r = I_or; I_g = I_or; I_b = I_or;        
            end

             figure(f4);
             subplot(223);imshow(islands_thresh);set(gcf, 'Colormap',1-gray(256));
             title('thresholded islands');axis image;axis on;
             drawnow; 
             Per = zeros(nrows,ncols);
             Per = bwperim(islands_thresh);
             I_r(Per)=255; I_g(Per)=255; I_b(Per)=0; 
             I_reg(:,:,1)=I_r; I_reg(:,:,2)=I_g; I_reg(:,:,3)=I_b;
             I_reg = uint8(I_reg);
             subplot(224); imshow(I_reg); axis on; title('Detected islands');  
        end
        % protrusions
        if protrusions_flag && ~isempty(find(protrusions_thresh,1))
            if (ndims(I_or)==3)
                I_r=I_or(:,:,1); I_g=I_or(:,:,2); I_b=I_or(:,:,3);    
            else
                I_r = I_or; I_g = I_or; I_b = I_or;        
            end

             figure(f5);
             subplot(223);imshow(protrusions_thresh);set(gcf, 'Colormap',1-gray(256));
             title('thresholded protrusions');axis image;axis on;
             drawnow; 
             Per = zeros(nrows,ncols);
             Per = bwperim(protrusions_thresh);
             I_r(Per)=255; I_g(Per)=0; I_b(Per)=0; 
             I_reg(:,:,1)=I_r; I_reg(:,:,2)=I_g; I_reg(:,:,3)=I_b;
             I_reg = uint8(I_reg);
             subplot(224); imshow(I_reg); axis on; title('Detected protrusions');  
        end
    end
    
    if verbose
        disp('Elapsed time for the thresholding: ');toc
    end

    
%**************************************************************************
% variables -> output parameters
%--------------------------------------------------------------------------
% all saliency masks in one array
saliency_masks(:,:,1) = holes_thresh;
saliency_masks(:,:,2) = islands_thresh;
saliency_masks(:,:,3) = protrusions_thresh;
saliency_masks(:,:,4) = indentations_thresh;

% display the original regions overlaid on the image
if visualise_final
    visualize_mssr(I_or, saliency_masks, saliency_type,region_params);
end

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

