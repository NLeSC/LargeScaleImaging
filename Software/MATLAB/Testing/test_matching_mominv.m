% test_matching_mominv- testing matching using the Flusser's affine moment
%                       invariants as descriptors of the salient regions
%**************************************************************************
% author: Elena Ranguelova, NLeSc
% date created: 10-08-2016
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% last modification date: 
% modification details: 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% NOTE: matchFeatures from the CVS Toolbox is used
%**************************************************************************
% REFERENCES
% Flusser, Suk and Zitova, "Moments and Moment Invariants for Pattern
% Recognition", 2009, http://zoi_zmije.utia.cas.cz/moment_invariants
% http://zoi_zmije.utia.cas.cz/mi/codes
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% define some parameters
% execution parameters
verbose = 1;
vis = 1;
% the test image contains multiple binary shapes?
multiple = input('Test image with muliple regions? [1/0]: ');
% moments order
%order = input('Enter the order (up to 4) of the moments: ');
order = 4;

%num_moments =  input('How many invariants to consider (max 66)?: ');
max_num_moments = 66;
%num_moments = 9;

list_properties = {'Centroid'};

%% load a simple binary test image and make a transformed image
if verbose
    disp('Loading a binary test image and transforming it...');
end

if multiple
   % bw = imread('Binary_islands.png');
    bw = rgb2gray(imread('Blobs.png'));
else
    bw = rgb2gray(imread('blob.png'));
end
bw = logical(bw);
% define translation matrix
dx = 15; dy = 35;
Ht = [1 0 dx; 0 1 dy; 0 0 1];
% define scaling matrix
sx = 2; sy = 2;
Hs = [sx 0 0; 0 sy 0; 0 0 1];
% define sheer
ssx = 0.5; ssy = 0.2;
Hsh = [ssx ssy 0; 0 ssy 0; 0 0 1];
%define rotation matrix
theta = deg2rad(30);
cos_theta = cos(theta); sin_theta = sin(theta);
Hr = [cos_theta -sin_theta 0; sin_theta cos_theta 0; 0 0 1];
% define affine matrix
Ha = Hr*Hsh*Hs*Ht;

%  obtain transformed images
bw_a = logical(applyAffineTransform(bw, Ha', 0));

% visualise
if vis
    f = figure; 
    set(gcf, 'Position', get(0, 'Screensize'));
    subplot(221);imshow(bw); title('Binary'); axis on, grid on;
    subplot(222);imshow(bw_a); title('Binary (affine)'); axis on, grid on;
end

%% obtain connected components
if verbose
    disp('Obtain the connected components...');
end
cc = bwconncomp(bw);
cc_a = bwconncomp(bw_a);

% visualise
if vis
    stats_cc = regionprops(cc,list_properties);
    labeled = labelmatrix(cc);
    figure(f); subplot(223);imshow(label2rgb(labeled));
    hold on;
    for k = 1:numel(stats_cc)
        if numel(stats_cc) > 3 && k <= 2
            col = 'w';
        else
            col = 'k';
        end
        text(stats_cc(k).Centroid(1), stats_cc(k).Centroid(2), num2str(k), ...
        'Color', col, 'HorizontalAlignment', 'center')
    end
    hold off;

    title('Connected Components'); axis on, grid on;
    

    stats_cc_a = regionprops(cc_a,list_properties);
    labeled = labelmatrix(cc_a);
    subplot(224);imshow(label2rgb(labeled)); 
    hold on;
    for k = 1:numel(stats_cc_a)
        if numel(stats_cc) > 3 && k <= 2
            col = 'w';
        else
            col = 'k';
        end
        text(stats_cc_a(k).Centroid(1), stats_cc_a(k).Centroid(2), num2str(k), ...
            'Color', col, 'HorizontalAlignment', 'center')
    end
    hold off;
    title('Connected Components (affine)'); axis on, grid on;
end

%% compute scale moments invariants of all CCs

% load coefficients
coeff = readinv('afinvs4_19.txt');

if verbose
    disp('Processing original image ... ');
end

num_regions = cc.NumObjects;

for i = 1:num_regions
    bwi = zeros(size(bw));
    bwi(cc.PixelIdxList{i}) = 1;
    moments = cm(bwi,order);
    [moment_invariants(i,:)] = cafmi(coeff, moments);    %#ok<*SAGROW>
end
if verbose
    disp('Moment invariants: '); disp(moment_invariants);
    disp('--------------------------------------------');
end

if verbose
    disp('Processing affine image ... ');
end
%num_regions = cc_t.NumObjects;
for i = 1:num_regions
    bwi = zeros(size(bw_a));
    bwi(cc_a.PixelIdxList{i}) =1;
    moments = cm(bwi,order);
    [moment_invariants_a(i,:)] = cafmi(coeff, moments);    %#ok<*SAGROW>
end
if verbose
    disp('Moment invariants: '); disp(moment_invariants_a);
    disp('--------------------------------------------');
end
%% matching the invariants and count the matches
matched_pairs = {};
num_matches = zeros(1, max_num_moments);
for m = 2:max_num_moments
    features = moment_invariants(:,1:m);
    features_a = moment_invariants(:,1:m);
    matched_pairs{m} = matchFeatures(features, features_a);
    num_matches(m) = size(matched_pairs{m},1);
end

%% matches
if vis
    
    figure; set(gcf, 'Position', get(0, 'Screensize'));
    plot(1:max_num_moments,num_matches, 'r-^');
    axis on; grid on;
    xlabel('Number of invariants');
    title('Matched regions');
end
