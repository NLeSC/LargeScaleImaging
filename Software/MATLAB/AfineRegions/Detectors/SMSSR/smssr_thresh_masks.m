% smssr_thresh_masks- obtain the thresholded masks of the SMSSR detector 
%**************************************************************************
% [thresh_masks] = smssr_thresh_masks(acc_masks, saliency_thresh, verbose)
%
% author: Elena Ranguelova, NLeSc
% date created: 11 August 2015
% last modification date: 
% modification details: 
%**************************************************************************
% INPUTS:
% acc_masks    3-D array of the accumulated saliency masks of the regions
%                   for example acc_masks(:,:,1) contains the holes
% saliency_thresh  saliency threshold
% verbose          verbose flag
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
function [thresh_masks] = smssr_thresh_masks(acc_masks, saliency_thresh, verbose)

                                         
%**************************************************************************
% input control                                         
%--------------------------------------------------------------------------
if nargin < 3
    verbose = false';
end
if nargin < 2 || isempty(saliency_thresh)
    saliency_thresh = 0.75;
end
if nargin < 1
    error('smssr_thres_masks.m requires at least 1 input argument- the accululated saliency_masks!');
    thres_masks = [];
    return
end

%**************************************************************************
% input parameters -> variables
%--------------------------------------------------------------------------
holes_acc = acc_masks(:,:,1);
islands_acc = acc_masks(:,:,2);
indentations_acc = acc_masks(:,:,3);
protrusions_acc = acc_masks(:,:,4);

nrows = size(acc_masks,1);
ncols = size(acc_masks,2);

%**************************************************************************
% initialisations
%--------------------------------------------------------------------------
% thresholded saliency masks
holes_thresh = zeros(nrows,ncols);
islands_thresh = zeros(nrows,ncols);
indentations_thresh = zeros(nrows,ncols);
protrusions_thresh = zeros(nrows,ncols);

% final saliency masks
thresh_masks = zeros(nrows,ncols,4);

%**************************************************************************
% computations
%--------------------------------------------------------------------------
if verbose
    disp('Thresholding the saliency maps...');
end

tic;
t0 = clock;

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

if verbose
   disp('Elapsed time for the thresholding: ');toc
end


%**************************************************************************
%variables -> output parameters
%--------------------------------------------------------------------------
%all saliency masks in one array
thresh_masks(:,:,1) = holes_thresh;
thresh_masks(:,:,2) = islands_thresh;
thresh_masks(:,:,3) = protrusions_thresh;
thresh_masks(:,:,4) = indentations_thresh;
