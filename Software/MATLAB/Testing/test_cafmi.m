% test_cafmi- testing the Flusser's book MATLAB code cafmi function
%                                               (affine moment invariants)
%**************************************************************************
% author: Elena Ranguelova, NLeSc
% date created: 09-08-2016
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
% the test image contains multiple binary shapes?
multiple = input('Test image with muliple regions? [1/0]: ');
% moments order
%order = input('Enter the order (up to 4) of the moments: ');
order = 4;

num_moments =  input('How many invariants to consider (max 66)?: ');
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

%% compute the mean squared error as a function of number of moments
for i = 1:num_regions
    for j = 1:max_num_moments
        err(i,j) = immse(moment_invariants(i,1:j), moment_invariants_a(i,1:j));
    end
end

%% visualize the moments as features
if vis
    
    % determine the number of subplots necessary to display each region in a
    % separate subplot
    if num_regions <= 4
        hsbp = 2; vsbp = 2;
    end
    if num_regions > 4 && num_regions <= 6
        hsbp = 2; vsbp = 3;
    end
    if num_regions > 6 && num_regions <= 9
        hsbp = 3; vsbp = 3;
    end
    if num_regions > 9 && num_regions <= 12
        hsbp = 3; vsbp = 4;
    end
    if num_regions > 12 && num_regions <= 16
        hsbp = 4; vsbp = 4;
    end
    if num_regions > 16 && num_regions <= 20
        hsbp = 4; vsbp = 5;
    end
    if num_regions > 20
        disp('Cannot plot features for more than 20 regions');
        return
    end
    %% features figure
    %num_moments = size(moment_invariants,2);
    figure; set(gcf, 'Position', get(0, 'Screensize'));
    for j = 1:num_regions
        subplot(hsbp,vsbp,j);
        plot(1:num_moments, moment_invariants(j,1:num_moments), 'ko-',...            
            1:num_moments, moment_invariants_a(j,1:num_moments), 'r--*');       
        axis on; grid on;
        legend({'original', 'affine'});
        xlabel(['Region ' num2str(j)]);
        title(['Affine Moment invariants for the 2D binary shape']);
    end
    
    %% difference figure
    figure; set(gcf, 'Position', get(0, 'Screensize'));
    for j = 1:num_regions
        subplot(hsbp,vsbp,j);
        plot(1:num_moments, ...
            moment_invariants(j,1:num_moments) - moment_invariants_a(j,1:num_moments),...,
            'b-d');      
        axis([0 num_moments+1 -0.3 0.3]);
        axis on; grid on;
        legend({'difference between original and affine'});
        xlabel(['Region ' num2str(j)]);
        title(['Affine Moment invariants for the 2D binary shape']);
    end
    
    %% mean sqaured error figure
     figure; set(gcf, 'Position', get(0, 'Screensize'));
     for j = 1:num_regions
        subplot(hsbp,vsbp,j);
        plot(1:max_num_moments,err(j,:), 'r-^');
        axis([0 num_moments+1 -0.006 0.006])
        axis on; grid on;
        xlabel(['Region ' num2str(j)]);
        title('MSE as f(number of invaiants)');             
     end
    
     
end