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
% dmsr- main function of the DMSR (Data-driven Morphology Salient Regions) detector
%--------------------------------------------------------------------------
% secondary
%--------------------------------------------------------------------------
% difference_masks- obtain the bidirectioal difference between binary masks
% integral_masks- obtain the sum along the level dim.from 3D binary masks
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