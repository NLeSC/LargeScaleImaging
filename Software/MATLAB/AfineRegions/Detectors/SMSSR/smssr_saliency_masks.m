% smssr_saliency_masks- obtain the saliency masks of the SMSSR detector 
%**************************************************************************
% [saliency_masks] = smssr_saliency_masks(acc_masks, saliency_type, ...
%                                                    saliency_thresh, vis)
%
% author: Elena Ranguelova, NLeSc
% date created: 14 August 2015
% last modification date: 16 September 2015 
% modification details: added visualization flag for debugging purposes
% last modification date: 21 August 2015 
% modification details: adapted code to multiple saliency threhsolds
% last modification date: 17 August 2015 
% modification details: made the output saliency masks 4D, 3th dim is per
%                       group of gray levels, 4th is per saliency type
%**************************************************************************
% INPUTS:
% acc_masks    3-D array of the accumulated saliency masks of the regions
%                   for example acc_masks(:,:,1) contains the holes
% [saliency_type]  array with 4 flags for the 4 saliency types 
%                  (Holes, Islands, Indentations, Protrusions)
%                  [optional], if left out- default is [1 1 1 1]
% [saliency_thresh] saliency thresholds
% [vis]             visualization flag; default is [false]
%**************************************************************************
% OUTPUTS:
% saliency_masks    4-D array of the thresholded saliency masks of the regions
%                   for example acc_masks(:,:,:,1) contains the holes masks
%**************************************************************************
% SEE ALSO
%**************************************************************************
% RERERENCES:
%**************************************************************************
function [saliency_masks] = smssr_saliency_masks(acc_masks, saliency_type,...
                                                      saliency_thresh, vis)

                                         
%**************************************************************************
% input control                                         
%--------------------------------------------------------------------------
if nargin < 4 || isempty(vis)
    vis = false;
end
if nargin < 3 || isempty(saliency_thresh)
    saliency_thresh = [0.05 0.15 0.25 0.5 0.75];
end
if nargin < 2 || isempty(saliency_type)
    saliency_type = [1 1 1 1];
end
if nargin < 1
    error('smssr_saliency_masks.m requires at least 1 input argument- the accululated saliency_masks!');
    saliency_masks = [];
    return
end

%**************************************************************************
% input parameters -> variables
%--------------------------------------------------------------------------
% number of masks
num_masks = length(saliency_thresh);

% saliency flags
holes_flag = saliency_type(1);
islands_flag = saliency_type(2);
indentations_flag = saliency_type(3);
protrusions_flag = saliency_type(4);

i = 0;
if holes_flag
    i =i+1;
    holes_acc = acc_masks(:,:,i);
end
if islands_flag
    i =i+1;
    islands_acc = acc_masks(:,:,i);
end
if indentations_flag
    i =i+1;
    indentations_acc = acc_masks(:,:,i);
end
if protrusions_flag
    i =i+1;
    protrusions_acc = acc_masks(:,:,i);
end

nrows = size(acc_masks,1);
ncols = size(acc_masks,2);

%**************************************************************************
% initialisations
%--------------------------------------------------------------------------
% saliency masks
if holes_flag
    holes = ones(nrows,ncols,num_masks);
end
if islands_flag
    islands = ones(nrows,ncols,num_masks);
end
if indentations_flag
    indentations = ones(nrows,ncols, num_masks);
end
if protrusions_flag
    protrusions = ones(nrows,ncols, num_masks);
end
% final saliency masks
num_saliency_types = length(find(saliency_type));
saliency_masks = zeros(nrows,ncols,num_masks, num_saliency_types);

% figures
if vis
    if holes_flag
        f1 = figure;
    end
    if islands_flag
        f2 = figure;
    end
    if indentations_flag
        f3 = figure;
    end
    if protrusions_flag
        f4 = figure;
    end
end

%**************************************************************************
% grouping evidence from the accumulatted masks
%--------------------------------------------------------------------------
if holes_flag
    [thresh_values] = mask_values(holes_acc, saliency_thresh);
    for j = 1 : num_masks
       holes(:,:,j) = thresh_masks(holes_acc,thresh_values(j), thresh_values(j+1));
       if vis
           figure(f1); imshow(holes(:,:,j)); title(['holes between: ' num2str(thresh_values(j)) ' and ' num2str(thresh_values(j+1))]);
           pause;
       end
    end
end
if islands_flag
    [thresh_values] = mask_values(islands_acc, saliency_thresh);
    for j = 1 : num_masks
       islands(:,:,j) = thresh_masks(islands_acc,thresh_values(j), thresh_values(j+1));
       if vis
           figure(f2); imshow(islands(:,:,j)); title(['islands between: ' num2str(thresh_values(j)) ' and ' num2str(thresh_values(j+1))]);
           pause;
       end

    end
end
if indentations_flag
    [thresh_values] = mask_values(indentations_acc, saliency_thresh);
    for j = 1 : num_masks
       indentations(:,:,j) = thresh_masks(indentations_acc,thresh_values(j), thresh_values(j+1));
       if vis
           figure(f4); imshow(indentations(:,:,j)); title(['indentations between: ' num2str(thresh_values(j)) ' and ' num2str(thresh_values(j+1))]);
           pause;
       end       
    end
end
if protrusions_flag
    [thresh_values] = mask_values(protrusions_acc, saliency_thresh);
    for j = 1 : num_masks
       protrusions(:,:,j) = thresh_masks(protrusions_acc,thresh_values(j), thresh_values(j+1));
       if vis
           figure(f3); imshow(protrusions(:,:,j)); title(['protrusions between: ' num2str(thresh_values(j)) ' and ' num2str(thresh_values(j+1))]);
           pause;
       end       
    end
end


%**************************************************************************
% variables -> output parameters
%--------------------------------------------------------------------------
%all saliency masks in one array
i = 0;
if holes_flag
    i =i+1;
    saliency_masks(:,:,:,i) = holes;
end
if islands_flag
    i =i+1;
    saliency_masks(:,:,:,i) = islands;
end
if protrusions_flag
    i =i+1;
    saliency_masks(:,:,:,i) = protrusions;
end
if indentations_flag
    i =i+1;
    saliency_masks(:,:,:,i) = indentations;
end

    function [thresh_values] = mask_values(in_mask, saliency_thresh)
        num_thresh = length(saliency_thresh);
        thresh_values = zeros(1, num_thresh + 1);
        max_value = max(max(in_mask));
        thresh_values(1) = max_value;
        for i = 1:num_thresh
            thresh_values(i+1) = max_value*(1 - saliency_thresh(i));
        end         
    end

    function [out_mask] = thresh_masks(in_mask, high_value, low_value)
        high_mask = in_mask <= high_value;
        low_mask =  in_mask > low_value;
        out_mask = and(high_mask, low_mask);               
    end

toc
end