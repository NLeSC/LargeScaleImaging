% test_flusser_moment.m- script for testing Flusser moment computation
%**************************************************************************
% author: Elena Ranguelova, NLeSc
% date created: 1-0-2016
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% last modification date: 
% modification details: 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% NOTE: replaces test_mssr_binary.m
%**************************************************************************

%% define some parameters
% execution parameters
verbose = 1;
vis = 1;

% CCes and properties
conn = 8;
list_properties = {'Centroid', 'Area', 'PixelList'};

% moments
u = 1;
v = 1;

%% load a simple binary test image
if verbose
    disp('Loading and binarising a test image...');
end

I = imread('circlesBrightDark.png');

if vis
   f = figure; subplot(221); imshow(I); title('Test image'); axis on, grid on;
end

%% binarise the image
bw = (I > 200) | (I < 100);

% visualise
if vis
    figure(f); subplot(222);imshow(bw); title('Binarised'); axis on, grid on;
end


% obtain connected components
if verbose
    disp('Obtain the connected components...');
end
[regions_properties, conn_comp] = compute_region_props(bw, conn, list_properties);

% visualise
if vis
  cc = bwconncomp(bw);
  labeled = labelmatrix(cc);  
  RGB_label = label2rgb(labeled);
  figure(f); subplot(223);imshow(RGB_label); title('Connected Components'); axis on, grid on;
end

%% compute complex central moments
region_idx = 2;

pixel_list = regions_properties(region_idx).PixelList;
centroid = regions_properties(region_idx).Centroid;

if verbose
    disp('Compute the Flusser moment...');
end

[complex_moment] = flusser_moment(u, v, pixel_list,centroid)
