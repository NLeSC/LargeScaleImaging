% test_matching_SMI_descr_affine_dataset- testing matching with
%                       shape and moment invariants (SMI) as descriptors
%                       of the salient regions for the Oxford dataset
%**************************************************************************
% author: Elena Ranguelova, NLeSc
% date created: 14-09-2016
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% last modification date: 30-09-2016
% modification details: using regions_subset2binary
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
matches_filtering = true; % if true, perform filterring on the matches
binary = true; % true of using the directly binarization result raher than the detector's output

inverted = false;

% for now test only 1 type
sal_type = 2;

% moments parameters
%order = input('Enter the order (up to 4) of the moments: ');
order = 4;

coeff_file = 'afinvs4_19.txt';
%max_num_moments =  input('How many invariants to consider (max 66)?: ');
%max_num_moments = 66;
max_num_moments = 16;

% CC parameters
conn = 8;
list_props = {'Area','Centroid','MinorAxisLength','MajorAxisLength',...
    'Eccentricity','Solidity'};
if filtering
    list_props_all = {'Area','Centroid'};
    prop_types_filter = {'Area'};
    if sal_type == 2
        area_factor = 0.0005;
    elseif sal_type == 1
        area_factor = 0.00001;
    end
else
    area_factor =  0;
end

% matching parameters
match_type = 'ssd';
%match_thresh =  input('Matching threshold (0, 100]?: ');
match_thresh = 1;
if inverted
    max_ratio = 0.6;
else
    max_ratio = 0.75;
end

%max_ratio = input('Max ratio (0, 1]?: ');
max_dist = 10;

cost_thresh = 0.025;

match_ratio_thresh = 0.5;
dist_thresh = 2;
% visualization parameters
if vis
    if matches_filtering
        sbp_or = (241);
        sbp_or_l = (242);
        sbp_or_m = (243);
        sbp_or_fm = (244);
        sbp_a = (245);
        sbp_a_l = (246);
        sbp_a_m = (247);
        sbp_a_fm = (248);
    else
        sbp_or = (231);
        sbp_or_l = (232);
        sbp_or_m = (233);
        sbp_a = (234);
        sbp_a_l = (235);
        sbp_a_m = (236);
    end
end

%% load DMSR regions for base image and possibly filter out small ones
base_case = input('Enter base test case [graffiti|leuven|boat|bikes]: ','s');
%base_case = 'boat';
trans_deg = input('Enter the transformation degree [1(no transformation)|2|3|4|5|6]: ');

if verbose
    if binary
        disp('Loading a binarized image...');
    else
        disp('Loading a binary DMSR regions files...');
    end
end

h = trans_deg;
 if binary
        switch base_case
            case 'graffiti'
                bw_o = imread(['C:\Projects\eStep\LargeScaleImaging\Results\AffineRegions\graffiti\graffiti' num2str(h) '_bin.png']);
            case 'leuven'
                bw_o = imread(['C:\Projects\eStep\LargeScaleImaging\Results\AffineRegions\leuven\leuven' num2str(h) '_bin.png']);
            case 'boat'
                bw_o = imread(['C:\Projects\eStep\LargeScaleImaging\Results\AffineRegions\boat\boat' num2str(h) '_bin.png']);
            case 'bikes'
                bw_o = imread(['C:\Projects\eStep\LargeScaleImaging\Results\AffineRegions\bikes\bikes' num2str(h) '_bin.png']);
            otherwise
                error('Unknown transf. case!');
        end
    else
        switch base_case
            case 'graffiti'
                load(['C:\Projects\eStep\LargeScaleImaging\Results\AffineRegions\graffiti\graffiti' num2str(h) '_dmsrregions.mat'],'saliency_masks');
            case 'leuven'
                load(['C:\Projects\eStep\LargeScaleImaging\Results\AffineRegions\leuven\leuven' num2str(h) '_dmsrregions.mat'],'saliency_masks');
            case 'boat'
                load(['C:\Projects\eStep\LargeScaleImaging\Results\AffineRegions\boat\boat' num2str(h) '_dmsrregions.mat'], 'saliency_masks');
            case 'bikes'
                load(['C:\Projects\eStep\LargeScaleImaging\Results\AffineRegions\bikes\bikes' num2str(h) '_dmsrregions.mat'],'saliency_masks');
            otherwise
                error('Unknown transf. case!');
        end
    end

if binary
    num_masks = 1;
else
    dim = ndims(saliency_masks);
    num_masks = 1; %size(saliency_masks,dim);
end
% fill the small holes
if binary
    % bw_o = imfill(bw_o,'holes');
    if inverted
        bw_o = imcomplement(bw_o);
    end
else
    %bw_o = imfill(saliency_masks(:,:,sal_type),'holes');
    bw_o = saliency_masks(:,:,sal_type);
    clear saliency_masks
end

% make it of class logical
bw_o =  logical((bw_o));

disp('Computations for image 1...');
% CC
cc_o = bwconncomp(bw_o,conn);
if filtering
    stats_cc = regionprops(cc_o, list_props_all);
else
    %if vis
    stats_cc = regionprops(cc_o, 'Centroid');
    %end
end

% image area
imageArea = size(bw_o, 1) * size(bw_o,2);

% filter out the smallest regions and compute the SMI descriptor
if filtering
    range = {[area_factor*imageArea imageArea]};
    [bw_o_f, index_o, ~] = filter_regions(bw_o, stats_cc, prop_types_filter, {}, range, cc_o);
    cc_o_f = bwconncomp(bw_o_f,conn);
    [SMI_descr_o,SMI_descr_o_struct] = SMIdescriptor(bw_o_f, conn, list_props, ...
        order, coeff_file, max_num_moments);
else
    [SMI_descr_o,SMI_descr_o_struct] = SMIdescriptor(bw_o, conn, list_props, ...
        order, coeff_file, max_num_moments);
end


%% load DMSR regions for transformed image(s)

aff_case = input('Enter second test case [graffiti|leuven|boat|bikes]: ','s');
%aff_case = 'graffiti';
trans_deg = input('Enter the transformation degree [1(no transformation)|2|3|4|5|6]: ');
%trans_deg = 3;

if verbose
    if binary
        disp('Loading a binarized transformed image...');
    else
        disp('Loading a binary DMSR regions files for the transformed image...');
    end
end

disp('Computations for image 2...');

for h = trans_deg
    
    %% loading and filtering
    if binary
        switch aff_case
            case 'graffiti'
                bw_a = imread(['C:\Projects\eStep\LargeScaleImaging\Results\AffineRegions\graffiti\graffiti' num2str(h) '_bin.png']);
            case 'leuven'
                bw_a = imread(['C:\Projects\eStep\LargeScaleImaging\Results\AffineRegions\leuven\leuven' num2str(h) '_bin.png']);
            case 'boat'
                bw_a = imread(['C:\Projects\eStep\LargeScaleImaging\Results\AffineRegions\boat\boat' num2str(h) '_bin.png']);
            case 'bikes'
                bw_a = imread(['C:\Projects\eStep\LargeScaleImaging\Results\AffineRegions\bikes\bikes' num2str(h) '_bin.png']);
            otherwise
                error('Unknown transf. case!');
        end
    else
        switch aff_case
            case 'graffiti'
                load(['C:\Projects\eStep\LargeScaleImaging\Results\AffineRegions\graffiti\graffiti' num2str(h) '_dmsrregions.mat'],'saliency_masks');
            case 'leuven'
                load(['C:\Projects\eStep\LargeScaleImaging\Results\AffineRegions\leuven\leuven' num2str(h) '_dmsrregions.mat'],'saliency_masks');
            case 'boat'
                load(['C:\Projects\eStep\LargeScaleImaging\Results\AffineRegions\boat\boat' num2str(h) '_dmsrregions.mat'], 'saliency_masks');
            case 'bikes'
                load(['C:\Projects\eStep\LargeScaleImaging\Results\AffineRegions\bikes\bikes' num2str(h) '_dmsrregions.mat'],'saliency_masks');
            otherwise
                error('Unknown transf. case!');
        end
    end
    
    if binary
        % bw_a = imfill(bw_a,'holes');
        if inverted
            bw_a = imcomplement(bw_a);
        end
    else
        % fill the small holes
        %bw_a = imfill(saliency_masks(:,:,sal_type),'holes');
        bw_a = saliency_masks(:,:,sal_type);
        clear saliency_masks
    end
    
    % make it of class logical
    bw_a =  logical((bw_a));
    
    % CCs
    cc_a = bwconncomp(bw_a,conn);
    if filtering
        stats_cc_a = regionprops(cc_a, list_props_all);
    else
        % if vis
        stats_cc_a = regionprops(cc_a, 'Centroid');
        % end
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
            f = figure; set(gcf, 'Position', get(0, 'Screensize'));
            show_binary(bw_o, f, subplot(sbp_or),'Binary mask or. (holes)');
            
            if filtering
                [labeled_o_f, ~] = show_cc(cc_o_f, true, index_o, f, subplot(sbp_or_l), 'Conn. Comp. (after filtering)');
                labeled = labeled_o_f;
            else
                [labeled_o, ~] = show_cc(cc_o, true, [], f, subplot(sbp_or_l), 'Conn. Comp. ');
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
    
    %clear bw_o bw_o_f labeled
    %% visualise
    if vis
        % original images  (masks)
        if num_masks <= 2
            show_binary(bw_a, f, subplot(sbp_a),'Binary mask transf. (holes)');
            if filtering
                [labeled_a_f, ~] = show_cc(cc_a_f, true, index_a, f, subplot(sbp_a_l), 'Conn. Comp. transf. (after filtering)');
                labeled = labeled_a_f;
            else
                [labeled_a, ~] = show_cc(cc_a, true, [], f, subplot(sbp_a_l), 'Conn. Comp. tranf.');
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
        [SMI_descr_a,SMI_descr_a_struct] = SMIdescriptor(bw_a_f, conn, list_props, ...
            order, coeff_file, max_num_moments);
    else
        [SMI_descr_a,SMI_descr_a_struct] = SMIdescriptor(bw_a, conn, list_props, ...
            order, coeff_file, max_num_moments);
    end
    
    %clear bw_a bw_a_f
    %% matching the descriptos
    if filtering
        [matched_pairs, cost, matched_indicies, num_matches] = matching(SMI_descr_o,...
            SMI_descr_a, ...
            match_type, match_thresh, max_ratio, true, ...
            filtering, index_o, index_a);
    else
        [matched_pairs, cost, matched_indicies, num_matches] = matching(SMI_descr_o,...
            SMI_descr_a, ...
            match_type, match_thresh, max_ratio, true, ...
            filtering);
    end
    %% text display
    if length(matched_pairs) > 3
        T = struct2table(matched_pairs);
    else
        T =  [];
        disp('Not enough matches found!');
        disp('NOT THE SAME SCENE!');
        return;
    end
    if verbose
        %if vis
        disp(['Matches for 1 and ' num2str(h),': ']); disp(T);
        %end
    end
    disp(['Number of matches: ' , num2str(num_matches)])
    disp(['Mean matching cost: ', num2str(mean(cost))]);    
 
    
    
    %% filtering of the matches
    if matches_filtering
        [filt_matched_pairs, filt_matched_ind, filt_cost, filt_num_matches] = filter_matches(matched_pairs, ...
            matched_indicies, cost, cost_thresh);
        
        %% text display
        if length(filt_matched_pairs) > 3
            filtT = struct2table(filt_matched_pairs);
        else
            filtT =  [];
            disp('Not enough strong matches found!');
            disp('NOT THE SAME SCENE!');
            return;
        end     
        if verbose
            %if vis
            disp(['Filtered matches for 1 and ' num2str(h),': ']); disp(filtT);
            %end
        end
        disp(['Filtered number of matches: ' , num2str(filt_num_matches)])
        disp(['Filtered mean matching cost: ', num2str(mean(filt_cost))]);
        
        match_ratio = filt_num_matches/num_matches;
        disp(['====> Ratio filtered/all number of matches : ', num2str(match_ratio)]);                          
        
    end
    
    %     pause;
    %     disp('Press any key to continue...');
    %% final display of results
    if vis
        if filtering
            matched_o = zeros(size(labeled_o_f));
            matched_a = zeros(size(labeled_a_f));
            
            for m = 1:num_matches
                matched_o(labeled_o_f == matched_indicies(m, 1)) = m;
                matched_a(labeled_a_f == matched_indicies(m, 2)) = m;
            end
            
            if matches_filtering
                filt_matched_o = zeros(size(labeled_o_f));
                filt_matched_a = zeros(size(labeled_a_f));
                for m = 1:filt_num_matches
                    filt_matched_o(labeled_o_f == filt_matched_ind(m, 1)) = m;
                    filt_matched_a(labeled_a_f == filt_matched_ind(m, 2)) = m;
                end
            end
            
        else
            matched_o = zeros(size(labeled_o));
            matched_a = zeros(size(labeled_a));
            
            if matches_filtering
                filt_matched_o = zeros(size(labeled_o));
                filt_matched_a = zeros(size(labeled_a));
                for m = 1:filt_num_matches
                    filt_matched_o(labeled_o == filt_matched_ind(m, 1)) = m;
                    filt_matched_a(labeled_a == filt_matched_ind(m, 2)) = m;
                end
            end
            for m = 1:num_matches
                matched_o(labeled_o == matched_indicies(m, 1)) = m;
                matched_a(labeled_a == matched_indicies(m, 2)) = m;
            end
            
        end
        % make label matricies from the matched pairs
        if matches_filtering
            for m = 1:filt_num_matches
                filt_region1_idx(m) = filt_matched_pairs(m).first;
                filt_region2_idx(m) = filt_matched_pairs(m).second;
            end
        end
        for m =1:num_matches
            region1_idx(m) = matched_pairs(m).first;
            region2_idx(m) = matched_pairs(m).second;
        end
        
        
        % display
        show_labelmatrix(matched_o, true, region1_idx, stats_cc, f, ...
            subplot(sbp_or_m), 'Matched regions on original image');
        
        show_labelmatrix(matched_a, true, region2_idx, stats_cc_a, f, ...
            subplot(sbp_a_m), 'Matched regions on transf. image');
        
        if matches_filtering
            show_labelmatrix(filt_matched_o, true, filt_region1_idx, stats_cc, f, ...
                subplot(sbp_or_fm), 'Filtered matched regions on or. image');
            
            show_labelmatrix(filt_matched_a, true, filt_region2_idx, stats_cc_a, f, ...
                subplot(sbp_a_fm), 'Filtered matched regions on transf. image');
        end
    end
end


clear matched_a matched_o labeled_a_f labeled_a

%% estimate affine transformation
if matches_filtering
    [tform,inl1, inl2, status] = estimate_affine_tform(filt_matched_pairs, stats_cc,...
        stats_cc_a, max_dist);
    
else
    [tform,inl1, inl2, status] = estimate_affine_tform(matched_pairs, stats_cc,...
        stats_cc_a, max_dist);
end

if verbose
    num_inliers = length(inl1);
    disp(['The transformation has been estimated from ' num2str(num_inliers) ' matches.']);
    % disp(['The ratio inliers/all matches is ' num2str(num_inliers/num_matches*100) ' %.']);
    
    
    switch status
        case 0
            disp(['Sucessful transf. estimation!']);
        case 1
            disp('Transformation cannot be estimated due to low number of matches!');
        case 2
            disp('Transformation cannot be estimated!');
    end
end

% show the inliers
if vis
    figure(f);
    if matches_filtering
        subplot(sbp_or_fm);
    else
        subplot(sbp_or_m);
    end
    for i = 1:length(inl1)
        hold on;
        plot(inl1(i,1)+5, inl1(i,2)+5, 'b*');
        text(inl1(i,1)+8, inl1(i,2)+8, ...
            num2str(i), 'Color', 'b', 'HorizontalAlignment', 'center');
    end
    hold off;
    figure(f);
    if matches_filtering
        subplot(sbp_a_fm);
    else
        subplot(sbp_a_m);
    end
    for i = 1:length(inl2)
        hold on;
        plot(inl2(i,1)+5, inl2(i,2)+5, 'b*');
        text(inl2(i,1)+8, inl2(i,2)+8, ...
            num2str(i), 'Color', 'b', 'HorizontalAlignment', 'center');
    end
    hold off;
end
    
%% compute difference between original and transformed images
if status == 0    
    
    % get the region indicies
    if matches_filtering
        for i = 1:filt_num_matches
            indicies_o(i) = filt_matched_pairs(i).first;
            indicies_a(i) =  filt_matched_pairs(i).second;
        end
    else
        for i = 1:num_matches
            indicies_o(i) =  matched_pairs(i).first;
            indicies_a(i) = matched_pairs(i).second;
        end
    end
    % generate binary images only from the matched regions
        bw1 = regions_subset2binary(bw_o, indicies_o, conn);
        bw2 = regions_subset2binary(bw_a, indicies_a, conn);
%     bw1 = bw_o;
%     bw2 = bw_a;
    
    % compute the transformaition distance between the matched regions
    [diff1, diff2, dist1, dist2, bw1_trans, bw2_trans] = transformation_distance(bw1, bw2, tform);
    av_dist = (dist1 + dist2)/2;
    
    disp(['Transformation distance1 is: ' num2str(dist1) ]);
    disp(['Transformation distance2 is: ' num2str(dist2) ]);
    disp(['====> Final (average) transformation distance is: ' num2str(av_dist) ]);
    
    
    if (av_dist < dist_thresh) && ( match_ratio > match_ratio_thresh)
        disp('THE SAME SCENE!');
    else
        disp('PROBABLY NOT THE SAME SCENE!');
    end
    
    
    if vis
        ff = figure; set(gcf, 'Position', get(0, 'Screensize'));
        
        show_binary(bw1, ff, subplot(231),'Image1 (filt.) matched regions');
        show_binary(bw2, ff, subplot(234),'Image2 (filt.) matched regions');
                
        show_binary(bw2_trans, ff, subplot(232),'Reconstructed 1');
        show_binary(bw1_trans, ff, subplot(235),'Reconstructed 2');
        
        show_binary(diff1, ff, subplot(233),'XOR(1, Reconstructed1)');
        show_binary(diff2, ff, subplot(236),'XOR(2, Reconstructed2)');
    end
end