% test_SMIdescriptor- testing the SMI descriptor computation for 
%                   an image (Oxford dataset)
%**************************************************************************
% author: Elena Ranguelova, NLeSc
% date created: 21-02-2017
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% last modification date: 
% modification details: 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% NOTE: see also test_IsSameScene_imagePair_Oxford and IsSameScene
%**************************************************************************
% REFERENCES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% parameters
% execution parameters
verbose = true;
visualize = true;
area_filtering = true;  % if true, perform area filterring on regions
binarized = true;

% moments parameters
order = 4;
coeff_file = 'afinvs4_19.txt';
max_num_moments = 16;

% CC parameters
conn = 8;
list_props = {'Area','Centroid','MinorAxisLength','MajorAxisLength',...
    'Eccentricity','Solidity'};
area_factor = 0.0005;

% paths
data_path_or = 'C:\Projects\eStep\LargeScaleImaging\Data\AffineRegions\';
if binarized
    data_path_bin = 'C:\Projects\eStep\LargeScaleImaging\Results\AffineRegions\';
    ext = '_bin.png';
else
    ext  ='.png';
end

%% load test data
% test_case = input('Enter base test case [graffiti|leuven|boat|bikes]: ','s');
% trans_deg = input('Enter the transformation degree [1(no transformation)|2|3|4|5|6]: ');

test_case = 'leuven'; trans_deg = 1;

if verbose
   disp('Loading the image...');
   if binarized
       disp('Already binarized image is used.');
   end
end

if binarized
    test_path = fullfile(data_path_bin,test_case);
else
    test_path = fullfile(data_path_or,test_case);
end

test_image = fullfile(test_path,[test_case num2str(trans_deg) ext]); 

im = imread(test_image);

if visualize
    if verbose
        disp('Displaying the test image');
    end;
    fig_scrnsz = get(0, 'Screensize');
    figure; set(gcf, 'Position', fig_scrnsz);
    imshow(im); title(['Image: ' test_case num2str(trans_deg)]);        
end

%% dependant patameters
list_props_all = {'Area','Centroid'};
if area_filtering
    prop_types_filter = {'Area'};
    image_area = size(im, 1) * size(im,2);
    range = {[area_factor*image_area image_area]};
end

%%
%**************** Processing *******************************
disp('Processing...');
t0 = clock;
%% binarization
if not( islogical(im))
    % find out the dimensionality
    if ndims(im) == 3
        im = rgb2gray(im);
    end
    tic
    
    if ismatrix(im)
        if verbose
            disp('Data-driven binarization ...');
        end
        [bw,~] = data_driven_binarizer(im);
    end
    if verbose
        toc
    end
else
    bw = logical(im); 
end

% visualization of the binarization result
if visualize
    f = figure; set(gcf, 'Position', fig_scrnsz);
    show_binary(bw, f, (221),'Binarized image');
end
%% CC computation and possibly filtering
if verbose
    disp('Computing the connected components...');
end
tic
cc = bwconncomp(bw,conn);

stats_cc = regionprops(cc, list_props_all);

if verbose
    toc
end
if area_filtering
    if verbose
        disp('Area filering of the connected components...');
    end
    tic
    [bw_f, index, ~] = filter_regions(bw, stats_cc, prop_types_filter,...
        {}, range, cc);
    if verbose
        toc
    end
    if visualize
        if verbose
            disp('Computing the filtered connected components...');
        end
        cc_f = bwconncomp(bw_f,conn);
    end
end
% visualization of the CCs
if visualize
    [labeled,~] = show_cc(cc, false, [], f, subplot(222),'Connected components');
    if area_filtering
        [labeled_f,~] = show_cc(cc_f, true, index, f, subplot(223),'Filtered connected components');        
    end
end

%% SMI descriptor computation
if verbose
    disp('Shape and Moment Invariants (SMI) descriptors computation...');
end
if area_filtering
    bw_d = bw_f;
else
    bw_d = bw;
end
tic
[SMI_descr,SMI_descr_struct] = SMIdescriptor(bw_d, conn, ...
    list_props, order, ...
    coeff_file, max_num_moments);
if verbose
    toc
end

% visualize
figure(f); subplot(224);
plot(1:20, SMI_descr', '*-');
legend(num2str(index),'Location','bestoutside');
axis on, grid on;
title('SMI descriptorsfor filtered regions');
xlabel('Descriptor dimension');
%%
if verbose
    disp('Total elapsed time: ');
    etime(clock,t0)
end