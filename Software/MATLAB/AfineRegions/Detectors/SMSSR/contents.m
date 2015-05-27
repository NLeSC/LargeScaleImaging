% contents.m- contents of directory ...\SMSSR
%
% topic: Smart Morphologically-based Stable Salient Regions (SMSSR) detection 
% author: Elena Ranguelova, NLeSc
% date: May/June 2015
%
%**************************************************************************
% functions
%**************************************************************************
%--------------------------------------------------------------------------
% main
%--------------------------------------------------------------------------
% smssr- main function of the SMSSR detector 
%--------------------------------------------------------------------------
% secondary
%--------------------------------------------------------------------------
% smssr_gray_thresh.m- salient regions in a in a thresholded gray-level image
%
% thresh_cumsum- thresholding based on cumulative sum
% thresh_area- thresholding based on the data's effective "area"
%
% clahe_clip.m- Contrast-Limited Adaptive Histogram Equalization 
% IMOVERLAY Create a mask-based image overlay.
%**************************************************************************
% scripts
%**************************************************************************
%**************************************************************************
% misc
%**************************************************************************
% cl - clear the workspace and the screen 
%
% MyColormaps.mat - custom colour map (mycmap) for displaying the 
%                                                accumulative saliency maps
% list_col_ellipse.mat- file containing 343 different colours to display
%                       features as ellipses
% freezeColors.m-  lock colors of an image to current colors