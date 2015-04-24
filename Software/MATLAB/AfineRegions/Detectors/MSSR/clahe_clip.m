% clahe_clip.m- Contrast-Limited Adaptive Histogram Equalization given a
% clip limit
%**************************************************************************
% [im_eq] = clahe_clip(im_or, clip_limit);
%
% author: Elena Ranguelova
% date created: 24/03/06
% last modification date: 
% modification details: 
%**************************************************************************
% INPUTS:
% im_or- the original image
% clip_limit- the clip limit (scalar in [0 1] specifying the contrast
% enhance limit, lager- larger contrast)
%**************************************************************************
% OUTPUTS:
% im_eq- the equalized image
%**************************************************************************
% EXAMPLES USAGE:
%**************************************************************************
% NOTES: uses MATLAB's adapthisteq
%**************************************************************************

function [im_eq] = clahe_clip(im_or, clip_limit)

% image dimensions
[nrows, ncols, ndims] = size(im_or);

% equalize each channel separately
for i = 1:ndims
    im_eq(:,:,i) = adapthisteq(im_or(:,:,i), 'ClipLimit', clip_limit);
end