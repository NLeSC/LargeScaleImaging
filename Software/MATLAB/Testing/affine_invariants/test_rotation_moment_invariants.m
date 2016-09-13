% test_rotation_moment_invariants.m- script for testing rotation moment invariants computation
%**************************************************************************
% author: Elena Ranguelova, NLeSc
% date created: 4-08-2016
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% last modification date: 
% modification details: 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% NOTE:
%**************************************************************************

%% define some parameters
% execution parameters
verbose = 1;
vis = 1;

% CCes and properties
conn = 8;
list_properties = {'Centroid', 'Area', 'PixelList'};


%% load a simple binary test image and make a transformed image
if verbose
    disp('Loading a binary test image and transforming it...');
end

bw = imread('Binary_islands.png');
%bw = rgb2gray(imread('blob.png'));
bw = logical(bw);
% define rotation matrix 
theta = deg2rad(30);
cos_theta = cos(theta); sin_theta = sin(theta);
H = [3*cos_theta -sin_theta 10; sin_theta 3*cos_theta -20; 0 0 1];
%  obtain a transformed image
bwtr = applyAffineTransform(bw, H', 0);
bwtr = logical(bwtr);

% visualise
if vis
    f = figure; subplot(221);imshow(bw); title('Binary'); axis on, grid on;
    subplot(222);imshow(bwtr); title('Binary (rotated)'); axis on, grid on;
end


%% obtain connected components
if verbose
    disp('Obtain the connected components...');
end
[regions_properties, conn_comp] = compute_region_props(bw, conn, list_properties);
[regions_properties_tr, conn_comp_tr] = compute_region_props(bwtr, conn, list_properties);

% visualise
if vis
    cc = bwconncomp(bw);
    labeled = labelmatrix(cc);
    RGB_label = label2rgb(labeled);
    figure(f); subplot(223);imshow(RGB_label); title('Connected Components'); axis on, grid on;
    cc_tr = bwconncomp(bwtr);
    labeled = labelmatrix(cc_tr);
    RGB_label = label2rgb(labeled);
    subplot(224);imshow(RGB_label); title('Connected Components - rotated'); axis on, grid on;
end

%% compute scale moments invariants of all CCs

num_regions = length(cat(1,regions_properties.Area));
moment_invariants = zeros(num_regions, 6);

 if verbose
      disp('Processing original image ... '); 
 end
    
for region_idx = 1: num_regions
    
    if verbose
      disp('Processing region #: '); disp(region_idx);
    end
    pixel_list = regions_properties(region_idx).PixelList;
    centroid = regions_properties(region_idx).Centroid;
    area = regions_properties(region_idx).Area;
    
    if verbose
        disp('Compute the rotation moments...');
    end
    
    [moment_invariants(region_idx,:)] = rotation_moment_invariants(pixel_list, ...
        centroid, area);
    if verbose
        disp('Rotation moment invariants: '); disp(moment_invariants(region_idx,:));
    end
end

num_regions_tr = length(cat(1,regions_properties_tr.Area));
moment_invariants_tr = zeros(num_regions_tr, 6);

if verbose
    disp('------------------------------------');
    disp('Processing scaled image...'); 
end
 
for region_idx_tr = 1: num_regions_tr
    
    
    if verbose
        disp('Processing region #: '); disp(region_idx_tr);
    end
    pixel_list = regions_properties_tr(region_idx_tr).PixelList;
    centroid = regions_properties_tr(region_idx_tr).Centroid;
    area = regions_properties_tr(region_idx_tr).Area;
    
    if verbose
        disp('Compute the rotation moments...');
    end
    
    [moment_invariants_tr(region_idx_tr,:)] = rotation_moment_invariants(pixel_list, ...
        centroid, area);
    if verbose
        disp('Rotation moment invariants (transf.): '); disp(moment_invariants_tr(region_idx_tr,:));
    end
    
end

%% visualize the moments as features
if vis
      figure;
      for i = 1:num_regions
        plot(real(moment_invariants(i,:)), imag(moment_invariants(i,:)),'r*',...
             real(moment_invariants_tr(i,:)), imag(moment_invariants_tr(i,:)), 'bo');
        legend('original', 'rotated');
        hold on;       
     end
     hold off
     title(['Rotation Moment invariants for the 2D binary shape']);
     axis on; grid on;
end
