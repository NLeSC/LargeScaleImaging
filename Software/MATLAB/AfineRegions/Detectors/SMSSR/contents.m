% contents.m- contents of directory ...\SMSSR
%
% topic: Smart Morphologically-based Stable Salient Regions (SMSSR) detection 
% author: Elena Ranguelova, NLeSc
% date: May/June/July 2015
%
%**************************************************************************
% functions
%**************************************************************************
%--------------------------------------------------------------------------
% main
%--------------------------------------------------------------------------
% smssr- main function of the SMSSR detector 
% smssr_gray_level.m- salient regions in a cross-section of gray-level image
%--------------------------------------------------------------------------
% secondary
%--------------------------------------------------------------------------
% smssr_gray_thresh.m- salient regions in a in a thresholded gray-level image
% smssr_preproc.m- pre-processing for the SMMSR detector
%
% thresh_cumsum- thresholding based on cumulative sum
% thresh_area- thresholding based on the data's effective "area"
%
% clahe_clip.m- Contrast-Limited Adaptive Histogram Equalization 
% IMOVERLAY Create a mask-based image overlay.
%
% smssr_save- function to save the results from the SMSSR detector
% smssr_open- function to open the saved results from the SMSSR detector
% display_smart_regions.m- displays salient regions overlaid on the image
% smssr_detector_one.m- script for applying the SMSSR detector on 1 image
% hysteresis_thresholding- function forhysteresis thresholding
%**************************************************************************
% scripts
%**************************************************************************
% smssr_visualise_one.m- displaying the extracted SMSSR regions on 1 image
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