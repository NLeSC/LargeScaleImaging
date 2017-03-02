% IsSameScene-  comparing if 2 images are of the same scene (with smart 
%               binarization + SMI descriptor)
% **************************************************************************
% [is_same, num_matches, mean_cost, transf_sim] = IsSameScene(im1, im2, ...
%                      moments_params, cc_params, match_params, ...
%                      vis_params, exec_params)
%
% author: Elena Ranguelova, NLeSc
% date created: 19 October 2016
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% last modification date: 14 November 2016
% modification details: outcome depends on the transformaiton distance only
%                       removed matches_ratio_thresh in/out parameter
% last modification date: 4 November 2016
% modification details: transformation distance replaced with similarity
% last modification date: 29 October 2016
% modification details: added more output parameters
% last modification date: 21 October 2016
% modification details: added visualizations, swaped parameter order
%**************************************************************************
% INPUTS:
% im1/2          the input gray/color or binary images to be compared
% [moments_params] optional struct with the moment invariants parameters:
%                order- moments order, {4}
%                coeff_file- coefficients file filename, {'afinvs4_19.txt'}
%                max_num_moments- maximun number of moments, {16}
% [cc_params]    optional struct with the connected components parameters:
%                conn - CC computaiton connectivity, {8}
%                list_props list of CC properties to be computed:
%                   {'Area','Centroid','MinorAxisLength','MajorAxisLength',
%                                               'Eccentricity','Solidity'};
%                area_factor - factor what is considered large CC in an
%                   image, {0.0005}
% [match_params]   the matching parameters struct [optional] with fields:
%                match_metric- feature matching metric, see 'Metric' of
%                   matchFeatures. {'ssd'} = Sum of Sqared Differences
%                match_thresh - matching threshold, see 'MatchThreshold'
%                   of matchFeatures. {1}
%                max_ratio - ratio threshold, see 'MaxRatio' of
%                   matchFeatures. {0.75}
%                max_dist - max distance from point to projection for
%                   estimating the geometric trandorm between matches. See
%                   "help estimateGeometricTransfrom". Default is {10}.
%                cost_thresh - matching cost threshold. The match is
%                   considered good it its matching cost is above this
%                   threhsold. Default value is {0.025}
%                transf_sim_thresh- Transformation similarity (1-distance) threshold.
%                   For a good match between images the distance between
%                   an image and transformed with estimated transformation
%                   image should be small (similarity should be positive). Default is {-.5}.
% [vis_params]   optional struct with the visualization parameters:
%                sbp1/2 - subplot location for CC visualization
%                sbp1/2_f - subplot location for filtered CC visualization
%                sbp1/2_m - subplot location for matches visualization
%                sbp1/2_fm - subplot location for filtered matches visual.
% [exec_params]  the execution parameters structure [optional] with fields:
%                verbose- flag for verbose mode, default value {false}
%                visualize- flag for vizualizing the matching, {false}
%                area_filering - flag for performing region (cc) area
%                   filtering, {true}
%                matches_filering - flag for performing matches filtering,
%                {true}
%**************************************************************************
% OUTPUTS:
% is_same        binary flag, true if images are showing (partially)
%                the same scene and false otherwise
% num_matches    number of matches
% mean_cost      mean cost of matching
% transf_sim     transformation similarity (1-distance) between the 2 images
%**************************************************************************
% NOTES: The data-driven binarization is performed with default parameters.
%**************************************************************************
% EXAMPLES USAGE:
%
% see test_IsSameScene.m
%**************************************************************************
% REFERENCES:
%**************************************************************************
function [is_same, num_matches, mean_cost, transf_sim] = IsSameScene(im1, im2,...
    moments_params, cc_params, match_params, vis_params, exec_params)

%% input control
if nargin < 7 || isempty(exec_params)
    exec_params.verbose = false;
    exec_params.visualize = false;
    exec_params.area_filtering = true;
    exec_params.matches_filtering = true;
end
if (nargin < 6 || isempty(vis_params)) && (exec_params.visualize)
    if exec_params.matches_filtering
        vis_params.sbp1 = (241);
        vis_params.sbp1_f = (242);
        vis_params.sbp1_m = (243);
        vis_params.sbp1_fm = (244);
        vis_params.sbp2 = (245);
        vis_params.sbp_f = (246);
        vis_params.sbp2_m = (247);
        vis_params.sbp2_fm = (248);
    else
        vis_params.sbp1 = (231);
        vis_params.sbp1_f = (232);
        vis_params.sbp1_m = (233);
        vis_params.sbp1_fm = [];
        vis_params.sbp2 = (234);
        vis_params.sbp2_f = (235);
        vis_params.sbp2_m = (236);
        vis_params.sbp2_fm = [];
    end
end
if nargin < 5 || isempty(match_params)
    match_params.match_metric = 'ssd';
    match_params.match_thrseh = 1;
    match_params.max_ratio = 1;
    match_params.max_dist = 10;
    match_params.cost_thresh = 0.025;
   % match_params.matches_ratio_thresh = 0.5;
    match_params.transf_sim_thresh = -0.5;
end
if nargin < 4 || isempty(cc_params)
    cc_params.conn = 8;
    cc_params.list_props = {'Area','Centroid','MinorAxisLength',...
        'MajorAxisLength', 'Eccentricity','Solidity'};
    cc_params.area_factor = 0.0005;
end
if nargin < 3 || isempty(moments_params)
    moments_params.order = 4;
    moments_params.coeff_file = 'afinvs4_19.txt';
    moments_params.max_num_moments = 16;
end
if nargin < 2
    error('IsSameScene: the function expects minimum 2 input arguments- the images to be compared!');
end

%% unpack parameter structures into variables
v2struct(exec_params);
v2struct(moments_params);
v2struct(cc_params);
v2struct(match_params);
if visualize
    v2struct(vis_params);
end

%% dependant parameters
list_props_all = {'Area','Centroid'};
if area_filtering
    prop_types_filter = {'Area'};
    image_area1 = size(im1, 1) * size(im1,2);
    image_area2 = size(im2, 1) * size(im2,2);
    range1 = {[area_factor*image_area1 image_area1]};
    range2 = {[area_factor*image_area2 image_area2]};
end

%% processing
%**************** Processing *******************************
disp('Processing...');
if verbose
    disp('Comparing whether 2 images depict (partially) the same scene...');
    t0 = clock;
end

%% binarization
if not( islogical(im1) && islogical(im2) )
    % find out the dimensionality
    if ndims(im1) == 3
        im1 = rgb2gray(im1);
    end
    if ndims(im2) == 3
        im2 = rgb2gray(im2);
    end
    tic
    
    if ismatrix(im1)
        if verbose
            disp('Data-driven binarization 1...');
        end
        [bw1,~] = data_driven_binarizer(im1);
    end
    if ismatrix(im2)
        if verbose
            disp('Data-driven binarization 2...');
        end
        [bw2,~] = data_driven_binarizer(im2);
    end
    if verbose
        toc
    end
else
    bw1 = logical(im1); bw2 = logical(im2);
end
%% visualization of the binarization result
if visualize
    fig_scrnsz = get(0, 'Screensize');
    offset = offset_factor * fig_scrnsz(4);
    fig_scrnsz(2) = fig_scrnsz(2) + offset;
    fig_scrnsz(4) = fig_scrnsz(4) - offset;
    f = figure; set(gcf, 'Position', fig_scrnsz);
    show_binary(bw1, f, subplot(sbp1),'Binarized image1');
    show_binary(bw2, f, subplot(sbp2),'Binarized image2');
    pause(0.5);
end

%% CC computation and possibly filtering
if verbose
    disp('Computing the connected components...');
end
tic
cc1 = bwconncomp(bw1,conn);
cc2 = bwconncomp(bw2,conn);

stats_cc1 = regionprops(cc1, list_props_all);
stats_cc2 = regionprops(cc2, list_props_all);

if verbose
    toc
end
if area_filtering
    if verbose
        disp('Area filering of the connected components...');
    end
    tic
    [bw1_f, index1, ~] = filter_regions(bw1, stats_cc1, prop_types_filter,...
        {}, range1, cc1);
    [bw2_f, index2, ~] = filter_regions(bw2, stats_cc2, prop_types_filter,...
        {}, range2, cc2);
    if verbose
        toc
    end
    if visualize
        if verbose
            disp('Computing the filtered connected components...');
        end
        cc1_f = bwconncomp(bw1_f,conn);
        cc2_f = bwconncomp(bw2_f,conn);
    end
end
%% visualization of the CCs
if visualize
    if area_filtering
        [labeled1_f,~] = show_cc(cc1_f, true, index1, f, subplot(sbp1_f),'Filtered connected components1');
        [labeled2_f,~] = show_cc(cc2_f, true, index2, f, subplot(sbp2_f),'Filtered connected components2');
    else
        [labeled1,~] = show_cc(cc1, true, [], f, subplot(sbp1_f),'Connected components1');
        [labeled2,~] = show_cc(cc2, true, [], f, subplot(sbp2_f),'Connected components2');
    end
end

%% SMI descriptor computaiton
if verbose
    disp('Shape and Moment Invariants (SMI) descriptors computation...');
end
if area_filtering
    bw1_d = bw1_f; bw2_d = bw2_f;
else
    bw1_d = bw1; bw2_d = bw2;
end
tic
[SMI_descr1,SMI_descr1_struct] = SMIdescriptor(bw1_d, conn, ...
    list_props, order, ...
    coeff_file, max_num_moments);
[SMI_descr2,SMI_descr2_struct] = SMIdescriptor(bw2_d, conn, ...
    list_props, order, ...
    coeff_file, max_num_moments);

if verbose
    toc
end

%% Matching the SMI descriptors
if verbose
    disp('SMI descriptors matching...');
end
if area_filtering
    ind1 = index1; ind2 = index2;
else
    ind1 = []; ind2 = [];
end
tic
[matched_pairs, cost, matched_ind, num_matches] = matching(...
    SMI_descr1, SMI_descr2, ...
    match_metric, ...
    match_thresh, ...
    max_ratio, true, ...
    area_filtering, ind1, ind2);
if verbose
    toc
end

mean_cost = mean(cost);
if verbose
    disp(['Number of matches: ' , num2str(num_matches)])
    disp(['Mean matching cost: ', num2str(mean_cost)]);
end
% check if enough matches
if num_matches > 3
    if visualize
        T = struct2table(matched_pairs);
        if verbose
            disp('Matches: '); disp(T);
        end
    end
else
    if verbose
        disp('Not enough matches found!');
    end
    disp('NOT THE SAME SCENE!');
    is_same = false; transf_sim = NaN;
    if verbose
        disp('Total elapsed time: ');
        etime(clock,t0)
    end
    return;
end

%% Filtering of the matches
if matches_filtering
    if verbose
        disp('Filtering of the matches...');
    end
    tic
    [filt_matched_pairs, filt_matched_ind, ...
        filt_cost, filt_num_matches] = filter_matches(matched_pairs, ...
        matched_ind, cost, cost_thresh);
    if verbose
        toc
    end
    %matches_ratio = filt_num_matches/num_matches;
    
    if verbose
        disp(['Filtered number of matches: ' , num2str(filt_num_matches)])
        disp(['Filtered mean matching cost: ', num2str(mean(filt_cost))]);
       % disp(['====> Ratio filtered/all number of matches : ', num2str(matches_ratio)]);
    end
    % check if enough filtered matches
    if filt_num_matches > 3
        if visualize
            filtT = struct2table(filt_matched_pairs);
            if verbose
                disp('Filtered matches:' ); disp(filtT);
            end
        end
    else
        if verbose
            disp('Not enough strong matches found!');
        end
        disp('NOT THE SAME SCENE!');
        is_same = false; transf_sim = NaN;
        if verbose
            disp('Total elapsed time: ');
            etime(clock,t0)
        end
        return;
    end
% else
%     matches_ratio = 1;
end
%% visualization of matches
if visualize
    if area_filtering
        matched1 = zeros(size(labeled1_f));
        matched2 = zeros(size(labeled2_f));
        
        for m = 1:num_matches
            matched1(labeled1_f == matched_ind(m, 1)) = m;
            matched2(labeled2_f == matched_ind(m, 2)) = m;
        end
        
        if matches_filtering
            filt_matched1 = zeros(size(labeled1_f));
            filt_matched2 = zeros(size(labeled2_f));
            for m = 1:filt_num_matches
                filt_matched1(labeled1_f == filt_matched_ind(m, 1)) = m;
                filt_matched2(labeled2_f == filt_matched_ind(m, 2)) = m;
            end
        end
        
    else
        matched1 = zeros(size(labeled1));
        matched2 = zeros(size(labeled2));
        
        if matches_filtering
            filt_matched1 = zeros(size(labeled1));
            filt_matched2 = zeros(size(labeled2));
            for m = 1:filt_num_matches
                filt_matched1(labeled1 == filt_matched_ind(m, 1)) = m;
                filt_matched2(labeled2 == filt_matched_ind(m, 2)) = m;
            end
        else
            for m = 1:num_matches
                matched1(labeled1 == matched_ind(m, 1)) = m;
                matched2(labeled2 == matched_ind(m, 2)) = m;
            end
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
    show_labelmatrix(matched1, true, region1_idx, stats_cc1, f, ...
        subplot(sbp1_m), 'Matched regions on image1');
    
    show_labelmatrix(matched2, true, region2_idx, stats_cc2, f, ...
        subplot(sbp2_m), 'Matched regions image2');
    
    if matches_filtering
        show_labelmatrix(filt_matched1, true, filt_region1_idx, stats_cc1, f, ...
            subplot(sbp1_fm), 'Filtered matched regions on image1');
        
        show_labelmatrix(filt_matched2, true, filt_region2_idx, stats_cc2, f, ...
            subplot(sbp2_fm), 'Filtered matched regions on image2');
    end
    pause(0.5);
end

%% Estimation of affine transformation between the 2 images from the matches
if verbose
    disp('Estimating affine transformation from the matches...');
end

if matches_filtering
    matched_pairs_d = filt_matched_pairs;
else
    matched_pairs_d = matched_pairs;
end
tic
[tform,inl1, ~, status] = estimate_affine_tform(matched_pairs_d, ...
    stats_cc1, stats_cc2, max_dist);
if verbose
    toc
end
if verbose
    num_inliers = length(inl1);
    disp(['The transformation has been estimated from ' num2str(num_inliers) ' matches.']);
    
    switch status
        case 0
            disp(['Sucessful transf. estimation!']);
        case 1
            disp('Transformation cannot be estimated due to low number of matches!');
        case 2
            disp('Transformation cannot be estimated!');
    end
end

%% Compute differences between image and transformed image
if verbose
    disp('Computing the distances between the pairs <image, transformed_image>');
end

% get the matched region indicies
if matches_filtering
    for i = 1:filt_num_matches
        indicies1(i) = filt_matched_pairs(i).first;
        indicies2(i) =  filt_matched_pairs(i).second;
    end
else
    for i = 1:num_matches
        indicies1(i) =  matched_pairs(i).first;
        indicies2(i) = matched_pairs(i).second;
    end
end

% generate binary images only from the matched regions
tic
bwm1 = regions_subset2binary(bw1, indicies1, conn);
bwm2 = regions_subset2binary(bw2, indicies2, conn);

% compute the transformaition distance between the matched regions
[diff1, diff2, dist1, dist2, ...
    bwm1_trans, bwm2_trans] = transformation_distance_binary(bwm1, bwm2, tform);
transf_sim = 1 - ((dist1 + dist2)/2);
if verbose
    toc
end
if verbose
    disp(['Transformation distance1 is: ' num2str(dist1) ]);
    disp(['Transformation distance2 is: ' num2str(dist2) ]);
    disp(['====> Final (average) transformation similarity (1-distance) is: ' num2str(transf_sim) ]);
end
%if (transf_sim > transf_sim_thresh) && (matches_ratio > matches_ratio_thresh)
if (transf_sim > transf_sim_thresh)
    disp('THE SAME SCENE!');
    is_same = true;
    if verbose
        disp('Total elapsed time: ');
        etime(clock,t0)
    end
else
    % disp('PROBABLY NOT THE SAME SCENE!');
    disp('NOT THE SAME SCENE!');
    is_same = false;
    if verbose
        disp('Total elapsed time: ');
        etime(clock,t0)
    end
end
%% visualization of the transformation distance
if visualize
    ff = figure; set(gcf, 'Position', fig_scrnsz);
    
    show_binary(bwm1, ff, subplot(231),'Image1 (filt.) matched regions');
    show_binary(bwm2, ff, subplot(234),'Image2 (filt.) matched regions');
    
    show_binary(bwm2_trans, ff, subplot(232),'Reconstructed 1');
    show_binary(bwm1_trans, ff, subplot(235),'Reconstructed 2');
    
    show_binary(diff1, ff, subplot(233),'XOR(1, Reconstructed1)');
    show_binary(diff2, ff, subplot(236),'XOR(2, Reconstructed2)');
    
    pause(0.5);
end

end


