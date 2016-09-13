% struct2array.m- convert structure with numetic values to array
%**************************************************************************
% [array] = struct2array(struct)
%
% author: Elena Ranguelova, NLeSc
% date created: 13 Sept 2016
% last modification date: 
% modification details: 
%**************************************************************************
% INPUTS:
% struct         structure with all numeric values
%**************************************************************************
% OUTPUTS:
% array          all structure values converted to homogeneous numeric array
%**************************************************************************
% NOTE:
%**************************************************************************
% EXAMPLES USAGE:
% a = rgb2gray(imread('circlesBrightDark.png'));
% bw = a < 100;
% conn = 4;
% imshow(bw); title('Image with Circles'); axis on, grid on;
% list = {'Centroid', 'Area','MinorAxisLength','MajorAxisLength','Solidity'};
% [regions_properties, ~] = compute_region_props(bw, conn, list);
% props_array = struct2array(regions_properties)
%**************************************************************************
% REFERENCES: 
%**************************************************************************

function [array] = struct2array(struct)

%**************************************************************************
% input control    
%--------------------------------------------------------------------------
if nargin < 1
    error('struct2array requires at least 1 input argument!');
end

%**************************************************************************
% input parameters -> variables
%--------------------------------------------------------------------------
%**************************************************************************
% initialisations
%--------------------------------------------------------------------------
%**************************************************************************
% computations
%--------------------------------------------------------------------------
table = struct2table(struct);
array = table2array(table);