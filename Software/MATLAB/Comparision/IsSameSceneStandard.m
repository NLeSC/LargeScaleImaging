% IsSameSceneStandard-  comparing if 2 images are of the same scene
%               (with MSER detector + SURF descriptor)
% **************************************************************************
% [is_same, num_matches, mean_cost, transf_sim] = IsSameSceneStandard(im1, im2, ...
%                       match_params, vis_params, exec_params)
%
% author: Elena Ranguelova, NLeSc
% date created: 23 February 2016
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% last modification date:
% modification details:
%**************************************************************************
% INPUTS:
% im1/2          the input gray/color or binary images to be compared

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
%                sbp1/2_d - subplot location for descriptor points visualization
%                sbp1/2_m - subplot location for matches visualization
%                sbp1/2_fm - subplot location for filtered matches visual.
% [exec_params]  the execution parameters structure [optional] with fields:
%                verbose- flag for verbose mode, default value {false}
%                visualize- flag for vizualizing the matching, {false}
%                area_filering - flag for performing region (cc) area
%                   filtering, {true}- NOT USED for now!
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
% NOTES: The MSER detection is performed with default parameters.
%**************************************************************************
% EXAMPLES USAGE:
%
% see test_IsSameSceneStandard.m
%**************************************************************************
% REFERENCES:
%**************************************************************************
function [is_same, num_matches, mean_cost, transf_sim] = IsSameSceneStandard(im1, im2,...
    match_params, vis_params, exec_params)

%% input control
if nargin < 5 || isempty(exec_params)
    exec_params.verbose = false;
    exec_params.visualize = false;
    exec_params.matches_filtering = true;
end
if (nargin < 4 || isempty(vis_params)) && (exec_params.visualize)
    if exec_params.matches_filtering
        vis_params.sbp1 = (241);
        vis_params.sbp1_d = (242);
        vis_params.sbp1_m = (243);
        vis_params.sbp1_fm = (244);
        vis_params.sbp2 = (245);
        vis_params.sbp_f = (246);
        vis_params.sbp2_m = (247);
        vis_params.sbp2_fm = (248);
    else
        vis_params.sbp1 = (231);
        vis_params.sbp1_d = (232);
        vis_params.sbp1_m = (233);
        vis_params.sbp1_fm = [];
        vis_params.sbp2 = (234);
        vis_params.sbp2_d = (235);
        vis_params.sbp2_m = (236);
        vis_params.sbp2_fm = [];
    end
end
if nargin < 3 || isempty(match_params)
    match_params.match_metric = 'ssd';
    match_params.match_thrseh = 1;
    match_params.max_ratio = 1;
    match_params.max_dist = 10;
    match_params.cost_thresh = 0.025;
    % match_params.matches_ratio_thresh = 0.5;
    match_params.transf_sim_thresh = -0.5;
end
if nargin < 2
    error('IsSameSceneStandard: the function expects minimum 2 input arguments- the images to be compared!');
end

%% unpack parameter structures into variables
v2struct(exec_params);
v2struct(match_params);
if visualize
    v2struct(vis_params);
end
%% dependant parameters
list_props_all = {'Area','Centroid'};


%% processing
%**************** Processing *******************************
disp('Processing...');
if verbose
    disp('Comparing whether 2 images depict (partially) the same scene...');
    t0 = clock;
end

%% MSER region detection

% convert to gray if needed
if ndims(im1) == 3
    im1 = rgb2gray(im1);
end
if ndims(im2) == 3
    im2 = rgb2gray(im2);
end
tic

if ismatrix(im1)
    if verbose
        disp('MSER detection 1...');
    end
    [regions1,cc1] = detectMSERFeatures(im1);
    stats_cc1 = regionprops(cc1, list_props_all);
%     % convert the cc to binary image- not exactly precise as they overlap!
%     bw1 = zeros(size(im1)); bw1_cc = bw1;
%     for i = 1:length(cc1(1).PixelIdxList)
%         pxlist = cc1(1).PixelIdxList{i};
%         bw1_cc(pxlist) = 1;
%         bw1 = or(bw1, bw1_cc);
%         bw1_cc = zeros(size(im1));
%     end
end
if ismatrix(im2)
    if verbose
        disp('MSER detection 2...');
    end
    [regions2,cc2] = detectMSERFeatures(im2);
    stats_cc2 = regionprops(cc2, list_props_all);
%     % convert the cc to binary image- not exactly precise as they overlap!
%     bw2 = zeros(size(im2)); bw2_cc = bw2;
%     for i = 1:length(cc2(1).PixelIdxList)
%         pxlist = cc2(1).PixelIdxList{i};
%         bw2_cc(pxlist) = 1;
%         bw2 = or(bw2, bw2_cc);
%         bw2_cc = zeros(size(im2));
%     end
end
if verbose
    toc
end
%% visualization of the MSER regions
if visualize
    fig_scrnsz = get(0, 'Screensize');
    offset = offset_factor * fig_scrnsz(4);
    fig_scrnsz(2) = fig_scrnsz(2) + offset;
    fig_scrnsz(4) = fig_scrnsz(4) - offset;
    f = figure; set(gcf, 'Position', fig_scrnsz);
%     show_binary(bw1, f, subplot(sbp1),'Binary MSER image1');
%     show_binary(bw2, f, subplot(sbp2),'Binary MSER image2');
    [~,~] = show_cc(cc1, false, [], f, subplot(sbp1),'MSER Connected components1');
    [~,~] = show_cc(cc2, false, [], f, subplot(sbp2),'MSER Connected components2');
    pause(0.5);
end

%% SURF descriptor computaiton
if verbose
    disp('SURF descriptors computation...');
end

tic
[SURF_descr1, valid_points1] = extractFeatures(im1,regions1);
[SURF_descr2, valid_points2] = extractFeatures(im2,regions2);

if verbose
    toc
end

%% visualization of the SURF points
if visualize
    figure(f); subplot(sbp1_d);
    imshow(im1); hold on; plot(valid_points1,'showOrientation',true); hold off;
    title('SURF points 1');
    subplot(sbp2_d);
    imshow(im2); hold on; plot(valid_points2,'showOrientation',true); hold off;
    title('SURF points 2');
end
%% Matching the SURF descriptors
if verbose
    disp('SURF descriptors matching...');
end

ind1 = []; ind2 = [];

tic
[matched_pairs, cost, matched_ind, num_matches] = matching(...
    SURF_descr1, SURF_descr2, ...
    match_metric, ...
    match_thresh, ...
    max_ratio, true, ...
    false, ind1, ind2);
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

% visualize
matchedPoints1 = valid_points1(matched_ind(:,1));
matchedPoints2 = valid_points2(matched_ind(:,2));

figure(f); subplot(sbp1_m);
showMatchedFeatures(im1,im2,matchedPoints1,matchedPoints2);
legend('points 1','points 2', ...
    'Location', 'best');
title('Matching 1->2');
figure(f); subplot(sbp2_m);
showMatchedFeatures(im2,im1,matchedPoints2,matchedPoints1);
legend('points 2',' points 1', ...
    'Location', 'best');
title('Matches 2->1');


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
filtMatchedPoints1 = valid_points1(filt_matched_ind(:,1));
filtMatchedPoints2 = valid_points2(filt_matched_ind(:,2));

figure(f); subplot(sbp1_fm);
showMatchedFeatures(im1,im2,filtMatchedPoints1,filtMatchedPoints2);
legend('points 1','points 2', ...
    'Location', 'best');
title('Filtered matches 1->2');
figure(f); subplot(sbp2_fm);
showMatchedFeatures(im2,im1,filtMatchedPoints2,filtMatchedPoints1);
legend('points 2','points 1', ...
    'Location', 'best');
title('Filtered matches 2->1');
% if visualize
%     labeled1 = labelmatrix(cc1);
%     labeled2 = labelmatrix(cc2);
%     
%     matched1 = zeros(size(labeled1));
%     matched2 = zeros(size(labeled2));
%     
%     if matches_filtering
%         filt_matched1 = zeros(size(labeled1));
%         filt_matched2 = zeros(size(labeled2));
%         for m = 1:filt_num_matches
%             filt_matched1(labeled1 == filt_matched_ind(m, 1)) = m;
%             filt_matched2(labeled2 == filt_matched_ind(m, 2)) = m;
%         end
%     else
%         for m = 1:num_matches
%             matched1(labeled1 == matched_ind(m, 1)) = m;
%             matched2(labeled2 == matched_ind(m, 2)) = m;
%         end
%     end
%     
%     % make label matricies from the matched pairs
%     if matches_filtering
%         for m = 1:filt_num_matches
%             filt_region1_idx(m) = filt_matched_pairs(m).first;
%             filt_region2_idx(m) = filt_matched_pairs(m).second;
%         end
%     end
%     for m =1:num_matches
%         region1_idx(m) = matched_pairs(m).first;
%         region2_idx(m) = matched_pairs(m).second;
%     end
%     
%     
%     % display
%     show_labelmatrix(matched1, true, region1_idx, stats_cc1, f, ...
%         subplot(sbp1_m), 'Matched regions on image1');
%     
%     show_labelmatrix(matched2, true, region2_idx, stats_cc2, f, ...
%         subplot(sbp2_m), 'Matched regions image2');
%     
%     if matches_filtering
%         show_labelmatrix(filt_matched1, true, filt_region1_idx, stats_cc1, f, ...
%             subplot(sbp1_fm), 'Filtered matched regions on image1');
%         
%         show_labelmatrix(filt_matched2, true, filt_region2_idx, stats_cc2, f, ...
%             subplot(sbp2_fm), 'Filtered matched regions on image2');
%     end
%     pause(0.5);
% end

return
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
bwm1 = regions_subset2binary(bw1, indicies1, 8);
bwm2 = regions_subset2binary(bw2, indicies2, 8);

% compute the transformaition distance between the matched regions
[diff1, diff2, dist1, dist2, ...
    bwm1_trans, bwm2_trans] = transformation_distance(bwm1, bwm2, tform);
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


