% test_rotmi- testing the Flusser's book MATLAB code rotmi function
%                                          (rotaiton translation and scaling)
%**************************************************************************
% author: Elena Ranguelova, NLeSc
% date created: 5-08-2016
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% last modification date:
% modification details:
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

% moments order
order = input('Enter the order of the moments: ');

%% load a simple binary test image and make a transformed image
if verbose
    disp('Loading a binary test image and transforming it...');
end

%bw = imread('Binary_islands.png');
bw = rgb2gray(imread('blob.png'));
bw = logical(bw);
% define translation matrix
dx = 25; dy = 35;
Ht = [1 0 dx; 0 1 dy; 0 0 1];
% define scaling matrix
sx = 2; sy = 2;
Hs = [sx 0 0; 0 sy 0; 0 0 1];
% define sheer
ssx = 0.5; ssy = 0.2;
Hsh = [ssx ssy 0; 0 ssy 0; 0 0 1];
% define rotation matrix
theta = deg2rad(30);
cos_theta = cos(theta); sin_theta = sin(theta);
Hr = [cos_theta -sin_theta 0; sin_theta cos_theta 0; 0 0 1];
% define affine matrix
Ha = Hr*Hsh*Hs*Ht;

%  obtain transformed images
bw_t = logical(applyAffineTransform(bw, Ht', 0));
bw_s = logical(applyAffineTransform(bw, Hs', 0));
bw_sh = logical(applyAffineTransform(bw, Hsh', 0));
bw_r = logical(applyAffineTransform(bw, Hr', 0));
bw_a = logical(applyAffineTransform(bw, Ha', 0));

% visualise
if vis
    f = figure; subplot(321);imshow(bw); title('Binary'); axis on, grid on;
    %subplot(323);imshow(bw_t); title('Binary (translation)'); axis on, grid on;
    subplot(323);imshow(bw_s); title('Binary (scaling)'); axis on, grid on;
    subplot(324);imshow(bw_r); title('Binary (rotation)'); axis on, grid on;
    subplot(325);imshow(bw_sh); title('Binary (sheer)'); axis on, grid on;
    subplot(326);imshow(bw_a); title('Binary (affine)'); axis on, grid on;
end


% %% obtain connected components
% if verbose
%     disp('Obtain the connected components...');
% end
% [regions_properties, conn_comp] = compute_region_props(bw, conn, list_properties);
% [regions_properties_tr, conn_comp_tr] = compute_region_props(bwtr, conn, list_properties);
%
% % visualise
% if vis
%     cc = bwconncomp(bw);
%     labeled = labelmatrix(cc);
%     RGB_label = label2rgb(labeled);
%     figure(f); subplot(223);imshow(RGB_label); title('Connected Components'); axis on, grid on;
%     cc_tr = bwconncomp(bwtr);
%     labeled = labelmatrix(cc_tr);
%     RGB_label = label2rgb(labeled);
%     subplot(224);imshow(RGB_label); title('Connected Components - rotated'); axis on, grid on;
% end

%% compute scale moments invariants of all CCs

if verbose
    disp('Processing original image ... ');
    disp('Compute the moments...');
end
[moment_invariants] = rotmi(bw, order);
if verbose
    disp('Moment invariants: '); disp(moment_invariants);
    disp('--------------------------------------------');
end

if verbose
    disp('Processing translated image ... ');
    disp('Compute the moments...');
end
[moment_invariants_t] = rotmi(bw_t, order);
if verbose
    disp('Moment invariants: '); disp(moment_invariants_t);
    disp('--------------------------------------------');
end

if verbose
    disp('Processing scaled image ... ');
    disp('Compute the moments...');
end
[moment_invariants_s] = rotmi(bw_s, order);
if verbose
    disp('Moment invariants: '); disp(moment_invariants_s);
    disp('--------------------------------------------');
end

if verbose
    disp('Processing rotated image ... ');
    disp('Compute the moments...');
end
[moment_invariants_r] = rotmi(bw_r, order);
if verbose
    disp('Moment invariants: '); disp(moment_invariants_r);
    disp('--------------------------------------------');
end

%% visualize the moments as features
if vis
    num_moments = length(moment_invariants);
    figure;
    plot(1:num_moments, moment_invariants, 'k.',...
        1:num_moments, moment_invariants_t, 'g+',...
        1:num_moments, moment_invariants_s, 'm*',...
        1:num_moments, moment_invariants_r, 'bs');
   legend('original', 'translaton','scaling', 'rotation');     
   title(['RTS Moment invariants for the 2D binary shape']);
   axis on; grid on;
        
end