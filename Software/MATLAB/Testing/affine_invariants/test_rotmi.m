% test_rotmi- testing the Flusser's book MATLAB code rotmi function
%                                          (rotaiton translation and scaling)
%**************************************************************************
% author: Elena Ranguelova, NLeSc
% date created: 05-08-2016
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% last modification date: 08-08-2016
% modification details: the script can test single or multiple regions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% NOTE:
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
order = input('Enter the order of the moments: ');

%% load a simple binary test image and make a transformed image
if verbose
    disp('Loading a binary test image and transforming it...');
end

if multiple
    bw = imread('Binary_islands.png');
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
% % define sheer
% ssx = 0.5; ssy = 0.2;
% Hsh = [ssx ssy 0; 0 ssy 0; 0 0 1];
% define rotation matrix
theta = deg2rad(30);
cos_theta = cos(theta); sin_theta = sin(theta);
Hr = [cos_theta -sin_theta 0; sin_theta cos_theta 0; 0 0 1];
% % define affine matrix
% Ha = Hr*Hsh*Hs*Ht;

%  obtain transformed images
bw_t = logical(applyAffineTransform(bw, Ht', 1));
bw_s = logical(applyAffineTransform(bw, Hs', 0));
%bw_sh = logical(applyAffineTransform(bw, Hsh', 0));
bw_r = logical(applyAffineTransform(bw, Hr', 0));
%bw_a = logical(applyAffineTransform(bw, Ha', 0));

% visualise
if vis
    f = figure; subplot(221);imshow(bw); title('Binary'); axis on, grid on;
    subplot(222);imshow(bw_t); title('Binary (translation)'); axis on, grid on;
    subplot(223);imshow(bw_s); title('Binary (scaling)'); axis on, grid on;
    subplot(224);imshow(bw_r); title('Binary (rotation)'); axis on, grid on;
    %   subplot(325);imshow(bw_sh); title('Binary (sheer)'); axis on, grid on;
    %   subplot(326);imshow(bw_a); title('Binary (affine)'); axis on, grid on;
end

%% obtain connected components
if verbose
    disp('Obtain the connected components...');
end
cc = bwconncomp(bw);
cc_t = bwconncomp(bw_t);
cc_s = bwconncomp(bw_s);
cc_r = bwconncomp(bw_r);
%cc_sh = bwconncomp(bw_sh);
%cc_a = bwconncomp(bw_a);

% visualise
if vis
    labeled = labelmatrix(cc);
    f1 = figure; subplot(221);imshow(label2rgb(labeled)); title('Connected Components'); axis on, grid on;
    
    labeled = labelmatrix(cc_t);
    subplot(222);imshow(label2rgb(labeled)); title('Connected Components (translation)'); axis on, grid on;
    
    labeled = labelmatrix(cc_s);
    subplot(223);imshow(label2rgb(labeled)); title('Connected Components (scaling)'); axis on, grid on;
    
    labeled = labelmatrix(cc_r);
    subplot(224);imshow(label2rgb(labeled)); title('Connected Components (rotation)'); axis on, grid on;
    
    %         labeled = labelmatrix(cc_sh);
    %         subplot(325);imshow(label2rgb(labeled)); title('Connected Components (sheer)'); axis on, grid on;
    %
    %         labeled = labelmatrix(cc_a);
    %         subplot(326);imshow(label2rgb(labeled)); title('Connected Components (affine)'); axis on, grid on;
end

%% compute scale moments invariants of all CCs
if verbose
    disp('Processing original image ... ');
end

num_regions = cc.NumObjects;

for i = 1:num_regions
    bwi = zeros(size(bw));
    bwi(cc.PixelIdxList{i}) = 1;
    [moment_invariants(i,:)] = rotmi(bwi, order);    %#ok<*SAGROW>
end
if verbose
    disp('Moment invariants: '); disp(moment_invariants);
    disp('--------------------------------------------');
end

if verbose
    disp('Processing translated image ... ');
end
%num_regions = cc_t.NumObjects;
for i = 1:num_regions
    bwi = zeros(size(bw_t));
    bwi(cc_t.PixelIdxList{i}) =1;
    [moment_invariants_t(i,:)] = rotmi(bwi, order);    %#ok<*SAGROW>
end
if verbose
    disp('Moment invariants: '); disp(moment_invariants_t);
    disp('--------------------------------------------');
end

if verbose
    disp('Processing rotated image ... ');
end
%num_regions = cc_r.NumObjects;
for i = 1:num_regions
    bwi = zeros(size(bw_r));
    bwi(cc_r.PixelIdxList{i}) =1;
    [moment_invariants_r(i,:)] = rotmi(bwi, order);    %#ok<*SAGROW>
end
if verbose
    disp('Moment invariants: '); disp(moment_invariants_r);
    disp('--------------------------------------------');
end

if verbose
    disp('Processing scaled image ... ');
end
%num_regions = cc_t.NumObjects;
for i = 1:num_regions
    bwi = zeros(size(bw_s));
    bwi(cc_s.PixelIdxList{i}) =1;
    [moment_invariants_s(i,:)] = rotmi(bwi, order);    %#ok<*SAGROW>
end
if verbose
    disp('Moment invariants: '); disp(moment_invariants_s);
    disp('--------------------------------------------');
end

%% visualize the moments as features
if vis
    num_moments = size(moment_invariants,2);
    figure;
    for j = 1:num_regions
        plot(1:num_moments, moment_invariants(j,:), 'ko-',...
            1:num_moments, moment_invariants_t(j,:), 'g:+',...
            1:num_moments, moment_invariants_s(j,:), 'm-.*',...
            1:num_moments, moment_invariants_r(j,:), 'b--s');
        hold on
        legend({'original', 'translation','scaling', 'rotation'});
    end
    hold off
    title(['RTS Moment invariants for the 2D binary shape']);
    axis on; grid on;
    
end