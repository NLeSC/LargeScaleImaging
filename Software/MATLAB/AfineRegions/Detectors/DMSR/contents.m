% contents.m- contents of directory ...\DMSR
%
% topic: Data-driven Morphologically-based Salient Regions (DMSR) detection 
% author: Elena Ranguelova, NLeSc
% date: September 2015
%
%**************************************************************************
% functions
%**************************************************************************
%--------------------------------------------------------------------------
% main
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
% secondary
%--------------------------------------------------------------------------
% difference_masks- obtain the bidirectioal difference between binary masks
% integral_masks- obtain the sum along the level dim.from 3D binary masks
% dmsr_save- function to save the results from the DMSR detector
% dmsr_open- function to open the saved results from the DMSR detector
%**************************************************************************
% scripts
%**************************************************************************

%**************************************************************************
% misc (in the MATLAB path)
%**************************************************************************
% cl - clear the workspace and the screen 
%
% MyColormaps.mat - custom colour map (mycmap) for displaying the 
%                                                accumulative saliency maps
% list_col_ellipse.mat- file containing 343 different colours to display
%                       features as ellipses
% freezeColors.m-  lock colors of an image to current colors