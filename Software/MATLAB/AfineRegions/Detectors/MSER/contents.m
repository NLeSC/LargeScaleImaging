% contents.m- contents of directory ...\MSER
%
% topic: Maximally Stable Extremal Regions (MSER) detection 
% author: Elena Ranguelova, TNO
% date: March 2008
%
%**************************************************************************
% functions
%**************************************************************************
%--------------------------------------------------------------------------
% main
%--------------------------------------------------------------------------
% mser.exe- binary executable of the MSER detector (from 
%           http://www.robots.ox.ac.uk/~vgg/research/affine/detectors.html)
% mser.m- main function (calling mser.exe) for the MSER derector from
%         Matlab
% mser_open- function to open the saved results from the MSER detector
%
% 
%--------------------------------------------------------------------------
% secondary
%--------------------------------------------------------------------------
% README.txt- the readme file for the mser. exe
%
%**************************************************************************
% scripts
%**************************************************************************
% mser_detector_one.m- script for applying MSER detector on 1 image
% mser_detector_many.m- script for applying MSER detector on many images
% mser_visualise_one.m- script for displaying the extracted MSER on 1 image
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