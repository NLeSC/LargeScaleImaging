% smssr_thresh_masks- obtain the thresholded masks of the SMSSR detector 
%**************************************************************************
% [thresh_masks] = smssr_thresh_masks(acc_masks, saliency_type, ...
%                                       saliency_thresh, verbose)
%
% author: Elena Ranguelova, NLeSc
% date created: 11 August 2015
% last modification date: 14 August 2015
% modification details: added saliency_type parameter
%**************************************************************************
% INPUTS:
% acc_masks    3-D array of the accumulated saliency masks of the regions
%                   for example acc_masks(:,:,1) contains the holes
%[saliency_type]  array with 4 flags for the 4 saliency types 
%                  (Holes, Islands, Indentations, Protrusions)
%                  [optional], if left out- default is [1 1 1 1]
% [saliency_thresh]  saliency threshold, [optional], default 0.75
% [verbose]          verbose flag,[optional], default false
%**************************************************************************
% OUTPUTS:
% thresh_masks    3-D array of the thresholded saliency masks of the regions
%                   for example acc_masks(:,:,1) contains the holes
%**************************************************************************
% SEE ALSO
% smssr_old- the oldimplemntation of the SMSSR detector 
%**************************************************************************
% RERERENCES:
%**************************************************************************
function [thresh_masks] = smssr_thresh_masks(acc_masks, saliency_type, ...
                                                saliency_thresh, verbose)

                                         
%**************************************************************************
% input control                                         
%--------------------------------------------------------------------------
if nargin < 4
    verbose = false;
end
if nargin < 3 || isempty(saliency_thresh)
    saliency_thresh = 0.75;
end
if nargin < 2 || isempty(saliency_type)
    saliency_type = [1 1 1 1];
end
if nargin < 1
    error('smssr_thres_masks.m requires at least 1 input argument- the accululated saliency_masks!');
    thres_masks = [];
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
% thresholded saliency masks
if holes_flag
    holes_thresh = zeros(nrows,ncols);
end
if islands_flag
    islands_thresh = zeros(nrows,ncols);
end
if indentations_flag
    indentations_thresh = zeros(nrows,ncols);
end
if protrusions_flag
    protrusions_thresh = zeros(nrows,ncols);
end
% final saliency masks
num_saliency_types = length(find(saliency_type));
thresh_masks = zeros(nrows,ncols,num_saliency_types);

%**************************************************************************
% computations
%--------------------------------------------------------------------------
if verbose
    disp('Thresholding the saliency maps...');
end

tic;
t0 = clock;

% the holes and islands
if logical(holes_flag) & logical(find(holes_acc))
   % holes_thresh = thresh_cumsum(holes_acc, saliency_thresh, verbose);
    holes_thresh = uint8(holes_acc > 0);
end
if logical(islands_flag) & logical(find(islands_acc))
   % islands_thresh = thresh_cumsum(islands_acc, saliency_thresh, verbose);
    islands_thresh = uint8(islands_acc > 0);
end

% the indentations and protrusions
if logical(indentations_flag) & logical(find(indentations_acc))
   %indentations_thresh = thresh_area(indentations_acc, saliency_thresh, verbose);
    indentations_thresh = uint8(indentaitons_acc > 0);
end
if logical(protrusions_flag) & logical(find(protrusions_acc))
   %protrusions_thresh = thresh_area(protrusions_acc, saliency_thresh, verbose);
   protrusions_thresh = uint8(protrusions_acc > 0);
end

if verbose
   disp('Elapsed time for the thresholding: ');toc
end


%**************************************************************************
%variables -> output parameters
%--------------------------------------------------------------------------
%all saliency masks in one array
i = 0;
if holes_flag
    i =i+1;
    thresh_masks(:,:,i) = holes_thresh;
end
if islands_flag
    i =i+1;
    thresh_masks(:,:,2) = islands_thresh;
end
if protrusions_flag
    i =i+1;
    thresh_masks(:,:,3) = protrusions_thresh;
end
if indentations_flag
    i =i+1;
    thresh_masks(:,:,4) = indentations_thresh;
end
