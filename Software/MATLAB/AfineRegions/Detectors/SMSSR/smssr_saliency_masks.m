% smssr_saliency_masks- obtain the saliency masks of the SMSSR detector 
%**************************************************************************
% [saliency_masks] = smssr_saliency_masks(acc_masks, saliency_type, ...
%                                                    saliency_thresh, num_masks)
%
% author: Elena Ranguelova, NLeSc
% date created: 14 August 2015
% last modification date: 18 August 2015 
% modification details: added number of gray levels as parameter
% last modification date: 17 August 2015 
% modification details: made the output saliency masks 4D, 3th dim is per
%                       group of gray levels, 4this per saliency type
%**************************************************************************
% INPUTS:
% acc_masks    3-D array of the accumulated saliency masks of the regions
%                   for example acc_masks(:,:,1) contains the holes
% [saliency_type]  array with 4 flags for the 4 saliency types 
%                  (Holes, Islands, Indentations, Protrusions)
%                  [optional], if left out- default is [1 1 1 1]
% [saliency_thresh] saliency threshold
% [num_masks]    number of masks (clusters of levels)
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
                                                      saliency_thresh,num_masks)

                                         
%**************************************************************************
% input control                                         
%--------------------------------------------------------------------------
if nargin < 4 || isempty(num_masks)
    num_masks = 5;
end
if nargin < 3 || isempty(saliency_thresh)
    saliency_thresh = 0.75;
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

%**************************************************************************
% grouping evidence from the accumulatted masks
%--------------------------------------------------------------------------
if holes_flag
%    [max_value, start_value] = range_mask(holes_acc, saliency_thresh);
    for j = 2 : num_masks
       holes(:,:,j) = summarize_masks(holes_acc,num_masks, j);
    end
end
if islands_flag
%    [max_value, start_value] = range_mask(islands_acc, saliency_thresh);
     for j = 2 : num_masks
        islands(:,:,j) = summarize_masks(islands_acc,num_masks,j);
    end
end
if protrusions_flag
%    [max_value, start_value] = range_mask(protrusions_acc, saliency_thresh);
     for j = 2 : num_masks
        protrusions(:,:,j) = summarize_masks(protrusions_acc,num_masks,j);
    end
end
if indentations_flag
%    [max_value, start_value] = range_mask(indentations_acc, saliency_thresh);
     for j = 2 : num_masks
        indentations(:,:,j) = summarize_masks(indentations_acc,num_masks,j);
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

    function [max_value, start_value] = range_mask(in_mask, saliency_thresh)
        max_value = max(max(in_mask));  
        start_value = fix(saliency_thresh*max_value);
    end

    function [out_mask] = summarize_masks(in_mask, num_masks,index)
        % the output should contain logical OR of the mask non-zero values
        % between index - num_masks: index 
        [rows, cols] = size(in_mask);
        out_mask = zeros(rows, cols);
        for value = num_masks*index-1: num_masks*index
            binary_mask = in_mask == value;
            out_mask = out_mask + binary_mask;
        end
    end

toc
end