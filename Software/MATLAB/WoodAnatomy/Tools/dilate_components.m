% dilate_components.m - dilateabinary image and return the number of CCs
% **************************************************************************
% [num_cc, bw_dil] = dilate_components(bw, SE_size) 
%
% author: Elena Ranguelova, NLeSc
% date created: 08 April 2016
% last modification date: 
% modification details: 
%**************************************************************************
% INPUTS:
% bw        - binary image (logical)- can be a mask of detected regions
% SE_size   - the size of the structuring element (radius of a disk)
%**************************************************************************
% OUTPUTS:
% num_cc    - number of Connected Components (CCs)
% bw_dil    - the dilated binary image
%**************************************************************************
% NOTES: called from testing scripts
%**************************************************************************
% EXAMPLES USAGE: 
% I = imread('coins.png');
% bw = im2bw(I);
% cc = bwconncomp(bw);
% disp('Number of CC: ');disp(cc.NumObjects);
% imshow(bw); title('Input binary');
% SE_size = 5;
% [num_cc, bw_dil] = dilate_components(bw, SE_size);
% figure; imshow(bw_dil); title('Dilated binary');
% disp('Number of CC: ');disp(num_cc);
% [num_cc1, bw_dil1] = dilate_components(bw_dil, SE_size);
% figure; imshow(bw_dil1); title('Dilated binary twice');
% disp('Number of CC: ');disp(num_cc1);
% Results should be: 15, 6 and 3
% OR
% see test_dilate_components.m
%**************************************************************************
% REFERENCES:
%**************************************************************************
function [num_cc, bw_dil] = dilate_components(bw, SE_size)

%% input parameters
if nargin < 2
    error('dilate_components requires min. 2 input arguments!');
end

%% initialiazations
SE = strel('disk', SE_size);

%% computaitons
% image dilation
bw_dil =  imdilate(bw, SE);

% new number of CC
CC = bwconncomp(bw_dil);
num_cc = CC.NumObjects;

end

