% test_matching_SMI_descr_affine_dataset- testing matching with
%                       shape and moment invariants (SMI) as descriptors
%                       of the salient regions for the Oxford dataset
%**************************************************************************
% author: Elena Ranguelova, NLeSc
% date created: 14-09-2016
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% last modification date: 15-09-2016
% modification details: fixing bug when filtering is false; adding visual.
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
filtering = true; % true if to perform Area filterring (large regions remain)

% for now test only 1 type
sal_type = 2;

% moments parameters
%order = input('Enter the order (up to 4) of the moments: ');
order = 4;

coeff_file = 'afinvs4_19.txt';
%num_moments =  input('How many invariants to consider (max 66)?: ');
%max_num_moments = 66;
max_num_moments = 12;

% CC parameters
conn = 8; %4;
list_props = {'Area','Centroid','MinorAxisLength','MajorAxisLength',...
    'Eccentricity','Solidity'};
if filtering
    list_props_all = {'Area','Centroid'};
    prop_types_filter = {'Area'};
    if sal_type == 2
        area_factor = 0.0005;
    elseif sal_type == 1
        area_factor = 0.00005;
    end
else
    area_factor =  0;
end

% matching parameters
dist_type = 'euclidean';
match_type = 'ssd';


%% load DMSR regions for base image and possibly filter out small ones
if verbose
    disp('Loading a binary DMSR regions files...');
end

%load('C:\Projects\eStep\LargeScaleImaging\Results\AffineRegions\graffiti\graffiti1_dmsrregions.mat','saliency_masks');
load('C:\Projects\eStep\LargeScaleImaging\Results\AffineRegions\leuven\leuven1_dmsrregions.mat','saliency_masks')
%load('C:\Projects\eStep\LargeScaleImaging\Results\AffineRegions\boat\boat1_dmsrregions.mat', 'saliency_masks')
%load('C:\Projects\eStep\LargeScaleImaging\Results\AffineRegions\bikes\bikes1_dmsrregions.mat','saliency_masks');

dim  = ndims(saliency_masks);
num_masks = 1; %size(saliency_masks,dim);

% fill the small holes
bw_o = imfill(saliency_masks(:,:,sal_type),'holes');
clear saliency_masks

% make it of class logical
bw_o =  logical(bw_o);

% CC
cc_o = bwconncomp(bw_o,conn);
if filtering
    stats_cc = regionprops(cc_o, list_props_all);
else
    if vis
        stats_cc = regionprops(cc_o, 'Centroid');
    end
end

% image area
imageArea = size(bw_o, 1) * size(bw_o,2);

% filter out the smallest regions and compute the SMI descriptor
if filtering
    range = {[area_factor*imageArea imageArea]};
    [bw_o_f, index_o, ~] = filter_regions(bw_o, stats_cc, prop_types_filter, {}, range, cc_o);
    cc_o_f = bwconncomp(bw_o_f,conn);
    [SMI_descr_o,~] = SMIdescriptor(bw_o_f, conn, list_props, ...
        order, coeff_file, max_num_moments);
else
    [SMI_descr_o,~] = SMIdescriptor(bw_o, conn, list_props, ...
        order, coeff_file, max_num_moments);
end

%% visualise
if vis
    % original images  (masks)
    if num_masks <= 2
        f = figure; set(gcf, 'Position', get(0, 'Screensize'));
        show_binary(bw_o, f, subplot(231),'Binary mask or. (holes)');
        
        
        if filtering
            [labeled_o_f, ~] = show_cc(cc_o_f, true, f, subplot(232), 'Conn. Comp. (after filtering)');
            labeled = labeled_o_f;
        else
            [labeled_o, ~] = show_cc(cc_o, true, f, subplot(232), 'Conn. Comp. ');
            labeled = labeled_o;
        end
        clear cc_o cc_o_f
        
        if num_masks > 1
            subplot(222);imshow(bw_o(:,:,2)); title('Binary mask or. (islands)'); axis on, grid on;
        end
    else if num_masks <= 4
            f1 =  figure; set(gcf, 'Position', get(0, 'Screensize'));
            subplot(221);imshow(bw_o(:,:,3)); title('Binary mask or. (indent.)'); axis on, grid on;
            if num_masks > 3
                subplot(222);imshow(bw_o(:,:,4)); title('Binary mask or. (protr.)'); axis on, grid on;
            end
        end
    end
end

clear bw_o bw_o_f labeled
%% load DMSR regions for transformed image(s)
for h = 6 % 4:6
    
    %% loading and filtering
    % load(['C:\Projects\eStep\LargeScaleImaging\Results\AffineRegions\graffiti\graffiti' num2str(h) '_dmsrregions.mat'],'saliency_masks');
    load(['C:\Projects\eStep\LargeScaleImaging\Results\AffineRegions\leuven\leuven' num2str(h) '_dmsrregions.mat'],'saliency_masks');
    % load(['C:\Projects\eStep\LargeScaleImaging\Results\AffineRegions\boat\boat' num2str(h) '_dmsrregions.mat'], 'saliency_masks')
    %load(['C:\Projects\eStep\LargeScaleImaging\Results\AffineRegions\bikes\bikes' num2str(h) '_dmsrregions.mat'],'saliency_masks');
    
    % fill the small holes
    bw_a = imfill(saliency_masks(:,:,sal_type),'holes');
    clear saliency_masks
    
    % make it of class logical
    bw_a =  logical(bw_a);
    
    % CCs
    cc_a = bwconncomp(bw_a,conn);
    if filtering
        stats_cc_a = regionprops(cc_a, list_props_all);
    else
        if vis
            stats_cc_a = regionprops(cc_a, 'Centroid');
        end
    end
    
    % image area
    imageArea = size(bw_a, 1) * size(bw_a,2);
    
    % filter out the smallest regions
    if filtering
        stats_cc_a = regionprops(cc_a, list_props_all);
        range = {[area_factor*imageArea imageArea]};
        [bw_a_f, index_a, ~] = filter_regions(bw_a, stats_cc_a, prop_types_filter, {}, range, cc_a);
        cc_a_f = bwconncomp(bw_a_f,conn);
    end
    
    
    %% visualise
    if vis
        % original images  (masks)
        if num_masks <= 2            
            show_binary(bw_a, f, subplot(234),'Binary mask transf. (holes)');
            if filtering
                [labeled_a_f, ~] = show_cc(cc_a_f, true, f, subplot(235), 'Conn. Comp. transf. (after filtering)'); 
                labeled = labeled_a_f;
            else
                [labeled_a, ~] = show_cc(cc_a, true, f, subplot(235), 'Conn. Comp. tranf.');
                labeled = labeled_a;
            end
            clear cc_a cc_a_f                                  
            
            if num_masks > 1
                subplot(224);imshow(bw_a(:,:,2)); title('Binary mask transf. (islands)'); axis on, grid on;
            end
        else if num_masks <= 4
                figure(f1); subplot(221);imshow(bw_o(:,:,3)); title('Binary mask or. (indent.)'); axis on, grid on;
                subplot(223);imshow(bw_a(:,:,3)); title('Binary mask transf. (indent.)'); axis on, grid on;
                if num_masks > 3
                    subplot(224);imshow(bw_a(:,:,4)); title('Binary mask transf. (protr.)'); axis on, grid on;
                end
            end
        end
        
    end
    
    clear labeled
    
    
    %% compute SMI descriptors
    if filtering
        [SMI_descr_a,~] = SMIdescriptor(bw_a_f, conn, list_props, ...
            order, coeff_file, max_num_moments);
    else
        [SMI_descr_a,~] = SMIdescriptor(bw_a, conn, list_props, ...
            order, coeff_file, max_num_moments);
    end
    
    clear bw_a bw_a_f
    %% matching the descriptos and count the matches
    [matched_indicies,cost] = matchFeatures(SMI_descr_o, SMI_descr_a,...
        'Metric',match_type, 'Unique', true);
    num_matches = size(matched_indicies,1);
    
    clear SMI_descr_a 
    % generate the matched pairs
    if filtering
        for i = 1:num_matches
            matched_pairs(i).first_region = index_o(matched_indicies(i,1));
            matched_pairs(i).second_region = index_a(matched_indicies(i,2));
        end
    else
        for i = 1:num_matches
            matched_pairs(i).first_region = matched_indicies(i,1);
            matched_pairs(i).second_region = matched_indicies(i,2);
        end
    end
    
    if length(matched_pairs) >=1
        T = struct2table(matched_pairs);
    else
        T =  [];
    end
   
    
    %% final display of results
    if vis
        % make label matricies from the matched pairs
        if filtering
            matched_o = zeros(size(labeled_o_f));
            matched_a = zeros(size(labeled_a_f));
            for m = 1:num_matches
                matched_o(labeled_o_f == matched_indicies(m, 1)) = m;
                matched_a(labeled_a_f == matched_indicies(m, 2)) = m;
            end
        else
            matched_o = zeros(size(labeled_o));
            matched_a = zeros(size(labeled_a));
            for m = 1:num_matches
                matched_o(labeled_o == matched_indicies(m, 1)) = m;
                matched_a(labeled_a == matched_indicies(m, 2)) = m;
            end
        end
        
        
        for k = 1:num_matches
            region1_idx(k) = matched_pairs(k).first_region;
            region2_idx(k) = matched_pairs(k).second_region;
        end
        
        show_labelmatrix(matched_o, true, region1_idx, stats_cc, f, ...
            subplot(233), 'Matched regions on original image');
        
        show_labelmatrix(matched_a, true, region2_idx, stats_cc_a, f, ...
            subplot(236), 'Matched regions on transf. image');
    end
    
    
    if verbose
        disp(['Matches for 1 and ' num2str(h),': ']); disp(T);
        disp(['Number of matches: ' , num2str(num_matches)])
        disp(['Mean matching cost: ', num2str(mean(cost))]);
    end
    clear matched_pairs matched_a matched_o labeled_a_f labeled_a stats_cc_a
    
%     disp('Press a key to continue');
%     pause;
end