% display_features.m- displays salient regions overlaid on the image
%**************************************************************************
% display_features(image_fname, detector, features_fname, ROI_mask_fname, ...
%                  regions_fname,...
%                  list_regions, scaling, labels, col_ellipse, ...
%                  line_width, col_label, original)
%
% author: Elena Ranguelova, TNO
% date created: 26 Feb 2008
% last modification date: 1 June 2015
% modification details:  added many appearance parameters
%                        added example of usage on the TNO laptop
%                        show features only within (potential) ROI
%                        added posibility to show the regions too
% last modification date: 12 October 2015
% modification details:  added detector parameter for the open_regions
%**************************************************************************
% INPUTS:
% image_fname- the original image filename 
% detector - string indicating the salient regions detector (S/D/MSSR)
% feature_fname - the file with features 
% [ROI_mask_fname]- the ROI binary mask (*.mat) [optional]
% [regions_fname]- the original saliency binary masks (*.mat) [optional]
% [type] - flag- to read the features including the saliency type or not
%               if left out or empty default is 0 (no type) [optional]
% [list_regions]- the list of regions to be displayed [optiona] if left out
%               all regions from the features_fname file are displayed
% [scaling]- ellipse scaling [optional] if left out default is 1
% [labels]- flag - to display the region number next to it or no 
%               if left out default is 0 (no labels) [optional]
% [col_ellipse]- the colour(s) of the ellipses [optional] if left out or
%                empty default is magenta
% [line_width]- the width of the ellipse line [optional] default is 1
% [col_label]- the colour(s) of the region numbers (if labels flag is 1)
%               [optional] if left out default is magenta
% [original]- show also the original regions overlaid on the image
%              [optional], if left out 0
%**************************************************************************
% OUTPUTS:
%**************************************************************************
% NOTES: originates from Mikolajzcyk's display_features function
% http://www.robots.ox.ac.uk/~vgg/research/affine/
%**************************************************************************
% EXAMPLES USAGE: see mssr_visualise_one!!
%**************************************************************************
% REFERENCES:
%**************************************************************************
function display_features(image_fname, detector, features_fname, ROI_mask_fname, ...
                  regions_fname,...  
                  type, list_regions, scaling, labels, col_ellipse, ...
                  line_width, col_label, original)

%**************************************************************************
% input control    
%--------------------------------------------------------------------------
if (nargin<13) || isempty(original)
    original = 0;
end
if (nargin < 12) || isempty(col_label)
    col_label = 'm'; % magenta
end
if (nargin < 11 ) || isempty(line_width)
    line_width = 1;
end
if (nargin < 10) || isempty(col_ellipse)
    col_ellipse =  [1 0 1]; % magenta
end
if (nargin < 9) || isempty(labels)
    labels = 0;
end
if (nargin < 8) || isempty(scaling)
    scaling = 1;
end
if (nargin < 7) 
    list_regions = [];
end
if (nargin < 6) || isempty(type)
    type = 0;
end
if nargin < 5
	regions_fname = [];  
end
if nargin < 4
    ROI_mask_fname = [];  
end
if nargin < 3
    error('display_features.m requires at least 2 input arguments!');
    return
end

%**************************************************************************
% constants/hard-set parameters
%--------------------------------------------------------------------------
% offset in pixels to display the region's label
if labels
    offset = 5;
end

%**************************************************************************
% input parameters -> variables
%--------------------------------------------------------------------------
% features 
[num_regions, features, saliency_masks] =...
    open_regions(detector,features_fname, regions_fname, type); 
sprintf('There are %d number of regions detected.', num_regions)
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
            return %#ok<UNRCH>
       end      
end

% regions
if isempty(list_regions)
    list_regions = 1:num_regions;
end

% check if colour of the ellipses is individually specified
if size(col_ellipse,1) > 1 && ...
        size(col_ellipse,1) ~= length(list_regions)
    error('number of colours should be equal to the number of regions!');
    return;
end

%**************************************************************************
% initialisations
%--------------------------------------------------------------------------
I = zeros(size(I_or));
if original
    I_reg = zeros(size(I_or));
end
%**************************************************************************
% computations
%--------------------------------------------------------------------------
% pre-processing

if ~(isempty(ROI))
    if (ndims(I_or)==3)
        I_r=I_or(:,:,1); I_g=I_or(:,:,2); I_b=I_or(:,:,3);
         I_r(~ROI)=1; I_g(~ROI)=1; I_b(~ROI)=1;
         I(:,:,1)=I_r; I(:,:,2)=I_g; I(:,:,3)=I_b;
    else
         I = I_or; I(~ROI)=1; 
    end
else
    I = I_or;
end

% display the original regions overlaid on the image
if original
    Per = zeros(nrows,ncols);
            for i=1:size(saliency_masks,3)
                   Per = Per|bwperim(saliency_masks(:,:,i));
            end
            Per_vis = imdilate(Per,strel('square',line_width));
            if (ndims(I_or)==3)
                 I_r=I_or(:,:,1); I_g=I_or(:,:,2); I_b=I_or(:,:,3);
                 I_r(Per_vis)=255; I_g(Per_vis)=0; I_b(Per_vis)=255; 
                 I_reg(:,:,1)=I_r; I_reg(:,:,2)=I_g; I_reg(:,:,3)=I_b;
                 I_reg = uint8(I_reg);
            else
                 I_r = I_or; I_g = I_or; I_b = I_or;
                 I_r(Per_vis)=255; I_g(Per_vis)=0; I_b(Per_vis)=255;
                 I_reg(:,:,1)=I_r; I_reg(:,:,2)=I_g; I_reg(:,:,3)=I_b;
                 I_reg = uint8(I_reg);
            end
    
    f0=figure; imshow(I_reg); axis on;
end

% display the (relevant part of the) image
I = uint8(I);
f = figure; imshow(I);axis on;
%--------------------------------------------------------------------------
% parameters depending on pre-processing
%--------------------------------------------------------------------------
% core processing
%--------------------------------------------------------------------------
% for all regions
i = 0;
for n=list_regions
    i = i+1;
    x = features(n,1); y = features(n,2);
    a = features(n,3); b = features(n,4); c = features(n,5);
    if type
        % display the 4 saliency types in different colour-coding
        sal_type = features(n,6);
        if sal_type == 1
            % holes
            col_ellipse = [0 0 1]; % blue
        elseif sal_type == 2
            % islands
            col_ellipse = [1 1 0]; % yellow;
        elseif sal_type == 3
            %indentations            
            col_ellipse = [0 1 0]; % green;
        else
            %protrusions
            col_ellipse = [1 0 0]; % red;
        end
         % draw the ellipse if within the ROI
         if ~isempty(ROI) 
             if ROI(fix(y),fix(x))
                 drawellipse(x,y,a,b,c, scaling, col_ellipse,line_width);
             end
         else
            drawellipse(x,y,a,b,c, scaling, col_ellipse,line_width);
         end
    else % no type is given
        % draw the ellipse
        if size(col_ellipse,1) > 1
            if ~isempty(ROI) 
             if ROI(fix(y),fix(y))
              drawellipse(x,y,a,b,c, scaling, col_ellipse(i,:),line_width);
             end
            else
              drawellipse(x,y,a,b,c, scaling, col_ellipse(i,:),line_width);
            end             
        else
           if ~isempty(ROI) 
             if ROI(fix(y),fix(y)) 
                  drawellipse(x,y,a,b,c, scaling, col_ellipse,line_width);
             end
           else
               drawellipse(x,y,a,b,c, scaling, col_ellipse,line_width);
           end                  
        end
    end
    
     % the labels
    if labels
        hold on;
        plot(x,y,[col_label, '+']);
        text(x + offset, y + offset, num2str(n),...
            'Color',col_label,'FontSize',9,'FontWeight','bold');
        hold off;
    end
end

%**************************************************************************
% variables -> output parameters
%--------------------------------------------------------------------------

%**************************************************************************
% subfunstions
%--------------------------------------------------------------------------
function drawellipse(x,y,a,b,c,scaling,col,lw)
    % draws the ellipse corresponding the each feature 
    figure(f);hold on;
    [v e]=eig([a b;b c]);

    l1=1/sqrt(e(1));
    l2=1/sqrt(e(4));

    alpha=atan2(v(4),v(3));
    t = 0:pi/50:2*pi;
    yt=scaling*(l2*sin(t));
    xt=scaling*(l1*cos(t));

    p=[xt;yt];
    R=[cos(alpha) sin(alpha);-sin(alpha) cos(alpha)];
    pt=R*p;
    % first plot blac ellipse and then narrower on top with the desired colour
    plot(pt(2,:)+x,pt(1,:)+y,'k-','LineWidth',1.5*lw);
    plot(pt(2,:)+x,pt(1,:)+y,'w-','LineWidth',lw);
    set(findobj(gca,'Type','line','Color',[1 1 1]),...
        'Color',col);
    hold off;
end

end