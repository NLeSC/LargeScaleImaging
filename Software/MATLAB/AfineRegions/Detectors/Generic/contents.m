% contents.m- contents of directory ...\Generic
%
% topic: Generic functionality used by all salient region detectors
% date: Sept/Oct 2015
%
%**************************************************************************
% functions
%**************************************************************************
% binary_detector.m- binary morphological detector
% gray_level_detector.m- salient regions in a cross-section of gray-level image
% binary_mask2features- obtain the equivalent elipses from a binary mask
% max_conncomp_thresholding.m- connected component-based thresholding
% visualize_regions_overlay.m- show salient regions overlaied on image 
% open_regions- open the saved results from the saliency detectors
% save_regions- function to save the results from a saliency detector
% compute_region_props.m- computing region properties from salient binary masks
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