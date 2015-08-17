% smssr_saliency_masks- obtain the saliency masks of the SMSSR detector 
%**************************************************************************
% [saliency_masks] = smssr_saliency_masks(acc_masks, saliency_type, num_masks)
%
% author: Elena Ranguelova, NLeSc
% date created: 14 August 2015
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
                                                                 num_masks)

                                         
%**************************************************************************
% input control                                         
%--------------------------------------------------------------------------
if nargin < 3 || isempty(num_masks)
    num_masks = 5;
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
% computations
%--------------------------------------------------------------------------

% % the holes and islands
% if logical(holes_flag) & logical(find(holes_acc))
%    % holes_thresh = thresh_cumsum(holes_acc, saliency_thresh, verbose);
%     holes_thresh = uint8(holes_acc > 0);
% end
% if logical(islands_flag) & logical(find(islands_acc))
%    % islands_thresh = thresh_cumsum(islands_acc, saliency_thresh, verbose);
%     islands_thresh = uint8(islands_acc > 0);
% end
% 
% % the indentations and protrusions
% if logical(indentations_flag) & logical(find(indentations_acc))
%    %indentations_thresh = thresh_area(indentations_acc, saliency_thresh, verbose);
%     indentations_thresh = uint8(indentaitons_acc > 0);
% end
% if logical(protrusions_flag) & logical(find(protrusions_acc))
%    %protrusions_thresh = thresh_area(protrusions_acc, saliency_thresh, verbose);
%    protrusions_thresh = uint8(protrusions_acc > 0);
% end


%**************************************************************************
%variables -> output parameters
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

toc