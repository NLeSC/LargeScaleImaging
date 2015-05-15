% contents.m- contents of directory ...\MSSR
%
% topic: Morphologically-based Stable Salient Regions (MSSR) detection 
% author: Elena Ranguelova, CWI, TNO, PV, NLeSc
% date: February/ March 2008, February 2010, April/May 2015
%
%**************************************************************************
% functions
%**************************************************************************
%--------------------------------------------------------------------------
% main
%--------------------------------------------------------------------------
% mssr- main function of the MSSR detector 
% mssr_gray_level_2008 .m- salient regions in a cross-section of gray-level 
%                           imag (version 2008)
% mssr_binary.m- binary MSSR
% mssr_binary_2008.m- binary MSSR (version of 2008)
% mssr_save- function to save the results from the MSSR detector
% mssr_open- function to open the saved results from the MSSR detector
%
% 
%--------------------------------------------------------------------------
% secondary
%--------------------------------------------------------------------------
% thresh_cumsum- thresholding based on cumulative sum
% thresh_area- thresholding based on the data's effective "area"
%
% clahe_clip.m- Contrast-Limited Adaptive Histogram Equalization 
% otsu_threshols.m- Otsu's threshols
% conversion_ellipse.m- function to obtain the parameters of an MSER
%
% display_features.m- displays salient regions (ellipses) on the image
% visualize_mssr_binary.m- visualize the MSSR regions overlayed on the 
%                          original binary image
% visualize_mssr_gray_levely.m- visualize the MSSR regions from a single 
%                           gray-level threshold overlayed on the 
%                          original gray-level image
%
% IMOVERLAY Create a mask-based image overlay.
%**************************************************************************
% scripts
%**************************************************************************
% mssr_detector_one.m- script for applying MSSR detector on 1 image
% mssr_detector_one_default_vis.m- script for applying MSSR detector on 1
%                                  image with default visualisation
% mssr_detector_many.m - script for applying MSSR detector on many images
% mssr_visualise_one.m- script for displaying the extracted MSSR on 1 image
% roi_selection_many.m- script for Region Of Interest selection on many images
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