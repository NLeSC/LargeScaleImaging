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
% smssr_binary.m- binary SMSSR detector
% smssr_preproc.m- pre-processing for the SMMSR detector
%
% thresh_cumsum- thresholding based on cumulative sum
% thresh_area- thresholding based on the data's effective "area"
%
% smssr_saliency_masks- obtain the saliency masks of the SMSSR detector 
% smssr_acc_masks- obtain the accumulated masks of the SMSSR detector 
% smssr_thresh_masks- obtain the thresholded masks of the SMSSR detector 
%
% clahe_clip.m- Contrast-Limited Adaptive Histogram Equalization 
% IMOVERLAY Create a mask-based image overlay.
%
% smssr_detector_one.m- script for applying the SMSSR detector on 1 image
% smssr_detector_many.m- script for applying the SMSSR detector on many images
% hysteresis_thresholding- function forhysteresis thresholding
%**************************************************************************
% scripts
%**************************************************************************
% smssr_visualise_one.m- displaying the extracted SMSSR regions on 1 image
% smssr_visualise_many.m- displaying the extracted SMSSR regions on manyimages
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