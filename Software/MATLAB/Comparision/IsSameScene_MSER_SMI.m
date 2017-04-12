% IsSameScene_MSER_SMI-  comparing if 2 images are of the same scene
%               (with MSER detector + SMI descriptor)
% **************************************************************************
% [is_same, num_matches, mean_cost, mean_transf_sim] = IsSameScene_MSER_SMI(im1o, im2o, ...
%                      moments_params, cc_params, match_params, ...
%                      vis_params, exec_params)
%
% author: Elena Ranguelova, NLeSc
% date created: 11 April 2017
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% last modification date: 
% modification details:
%**************************************************************************
% INPUTS:
% im1/2o          the input gray/color images to be compared
% [moments_params] optional struct with the moment invariants parameters:
%                order- moments order, {4}
%                coeff_file- coefficients file filename, {'afinvs4_19.txt'}
%                max_num_moments- maximun number of moments, {16}
% [cc_params]    optional struct with the connected components parameters:
%                list_props list of CC properties to be computed:
%                   {'Area','Centroid','MinorAxisLength','MajorAxisLength',
%                                               'Eccentricity','Solidity'};
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
%                conf - confidence of finding maximum number ofinliers. See
%                   "help estimateGeometricTransfrom". Default is {90}.
%                max_num_trials - maximum random trials. See
%                   "help estimateGeometricTransfrom". Default is {100}.
%                cost_thresh - matching cost threshold. The match is
%                   considered good it its matching cost is above this
%                   threhsold. Default value is {0.025}
%                transf_sim_thresh- Transformation similarity (1-distance) threshold.
%                   For a good match between images the distance between
%                   an image and transformed with estimated transformation
%                   image should be small (similarity should be positive).
%                   Default is {+.3}.
%                num_sim_runs - number of similarity runs, the final transf_sim 
%                   is the average of number of runs. Default is 20.
% [vis_params]   optional struct with the visualization parameters:
%                sbp1/2 - subplot location for CC visualization
%                sbp1/2_f - subplot location for filtered CC visualization
%                sbp1/2_m - subplot location for matches visualization
%                sbp1/2_fm - subplot location for filtered matches visual.
% [exec_params]  the execution parameters structure [optional] with fields:
%                verbose- flag for verbose mode, default value {false}
%                visualize- flag for vizualizing the matching, {false}
%                matches_filtering - flag for performing matches filtering,
%                {true}
%**************************************************************************
% OUTPUTS:
% is_same        binary flag, true if images are showing (partially)
%                the same scene and false otherwise
% num_matches    number of matches
% mean_cost      mean cost of matching
% mean_transf_sim  mean transformation similarity between the 2 images
%**************************************************************************
% NOTES: 
%**************************************************************************
% EXAMPLES USAGE:
%
% see test_IsSameScene.m
%**************************************************************************
% REFERENCES:
%**************************************************************************
function [is_same, num_matches, mean_cost, mean_transf_sim] = IsSameScene_MSER_SMI(im1o,...
    im2o, moments_params, cc_params, match_params, vis_params, exec_params)

%% input control
if nargin < 7 || isempty(exec_params)
    exec_params.verbose = false;
    exec_params.visualize = false;
    exec_params.matches_filtering = true;
end
if (nargin < 6 || isempty(vis_params)) && (exec_params.visualize)
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
if nargin < 5 || isempty(match_params)
    match_params.match_metric = 'ssd';
    match_params.match_thrseh = 1;
    match_params.max_ratio = 1;
    match_params.max_dist = 10;
    match_params.conf = 90;
    match_params.max_num_trials = 100;
    match_params.cost_thresh = 0.025;
    match_params.transf_sim_thresh = 0.3;
    match_params.num_sim_runs = 20;
end
if nargin < 4 || isempty(cc_params)
    cc_params.list_props = {'Area','Centroid','MinorAxisLength',...
        'MajorAxisLength', 'Eccentricity','Solidity'};
end
if nargin < 3 || isempty(moments_params)
    moments_params.order = 4;
    moments_params.coeff_file = 'afinvs4_19.txt';
    moments_params.max_num_moments = 16;
end
if nargin < 2
    error('IsSameScene_SURF_SMI: the function expects minimum 2 input arguments- the images to be compared!');
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
image_area1 = size(im1o, 1) * size(im1o,2);
image_area2 = size(im2o, 1) * size(im2o,2);
list_props_all = {'Area','Centroid'};
transf_sim = zeros(1, num_sim_runs);
mean_transf_sim = 0;

%% processing
%**************** Processing *******************************
disp('Processing...');
if verbose
    disp('Comparing whether 2 images depict (partially) the same scene...');
    t0 = clock;
end

%% MSER region detection

% convert to gray if needed
if ndims(im1o) == 3
    im1 = rgb2gray(im1o);
else
    im1 =im1o;
end
if ndims(im2o) == 3
    im2 = rgb2gray(im2o);
else
    im2 = im2o;
end
tic

if ismatrix(im1)
    if verbose
        disp('MSER detection 1...');
    end
    [~,cc1] = detectMSERFeatures(im1);
    stats_cc1 = regionprops(cc1, list_props_all);
end
if ismatrix(im2)
    if verbose
        disp('MSER detection 2...');
    end
    [~,cc2] = detectMSERFeatures(im2);
    stats_cc2 = regionprops(cc2, list_props_all);

end
if verbose
    toc
end

%% visualization of the MSER regions
if visualize
    fig_scrnsz = get(0, 'Screensize');
    offset = offset_factor * fig_scrnsz(4);
    fig_scrnsz(1) = fig_scrnsz(1) + 10;
    fig_scrnsz(3) = fig_scrnsz(3) + 10;
    fig_scrnsz(2) = fig_scrnsz(2) + offset;
    fig_scrnsz(4) = fig_scrnsz(4) - offset;
    f = figure; set(gcf, 'Position', fig_scrnsz);
    [~,~] = show_cc(cc1, false, [], f, subplot(sbp1),'MSER Connected components1');
    [~,~] = show_cc(cc2, false, [], f, subplot(sbp2),'MSER Connected components2');
    pause(0.5);
end

%% SMI descriptor computaiton
if verbose
    disp('Shape and Moment Invariants (SMI) descriptors computation...');
end

tic
[SMI_descr1,SMI_descr1_struct] = ccSMIdescriptor(cc1_d, image_area1, ...
    list_props, order, ...
    coeff_file, max_num_moments);
[SMI_descr2,SMI_descr2_struct] = ccSMIdescriptor(cc2_d, image_area2, ...
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
[matched_pairs, cost, matched_ind, num_matches] =...
    matching( SMI_descr1, SMI_descr2, ...
    match_metric, match_thresh, ...
    max_ratio, true, ...
    area_filtering, ind1, ind2);
if verbose
    toc
end

mean_cost = mean(cost);
%if verbose
disp(['Number of matches: ' , num2str(num_matches)])
disp(['Mean matching cost: ', num2str(mean_cost)]);
%end
% check if enough matches
if num_matches < 1
    if verbose
        disp('Zero matches found!');
    end
    disp('NOT THE SAME SCENE!');
    is_same = false; transf_sim = NaN;
    if verbose
        et = etime(clock,t0);
        disp(['Total elapsed time: ' num2str(et)]);
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
        filt_cost, filt_num_matches] = ...
        filter_matches(matched_pairs, matched_ind, cost, cost_thresh);
    if verbose
        toc
    end
    
    if verbose
        disp(['Filtered number of matches: ' , num2str(filt_num_matches)])
        disp(['Filtered mean matching cost: ', num2str(mean(filt_cost))]);
    end
    % check if enough filtered matches
    if filt_num_matches < 1
        if verbose
            disp('Zero strong matches found!');
        end
        disp('NOT THE SAME SCENE!');
        is_same = false; transf_sim = NaN;
        if verbose
            et = etime(clock,t0);
            disp(['Total elapsed time: ' num2str(et)]);
        end
        return;
    end
end
%% visualization of matches
if visualize

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

for nsr = 1: num_sim_runs
    
    
    if matches_filtering
        matched_pairs_d = filt_matched_pairs;
    else
        matched_pairs_d = matched_pairs;
    end
    tic
    [tform{nsr},inl1, ~, status] = estimate_affine_tform(matched_pairs_d, ...
        stats_cc1, stats_cc2, max_dist, conf, max_num_trials);
 
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
        disp('Computing the transformation correlation between the pairs <image, transformed_image>');
    end
    
    % compute the transformaition correlation between the matched regions
    tic
    [correl1, correl2, im1_trans, im2_trans] = transformation_correlation(im1, im2, tform{nsr});
    transf_sim(nsr) = ((correl1 + correl2)/2);
    disp(['Transformation similarity for this run is: ' num2str(transf_sim(nsr))]);
    if verbose
        toc
    end

end

%% final similarity and decision
mean_transf_sim = mean(transf_sim);
disp(['====> Final (mean) transformation similarity  is: ' num2str(mean_transf_sim) ]);

if (mean_transf_sim > transf_sim_thresh)
    disp('THE SAME SCENE!');
    is_same = true;
    if verbose
        et = etime(clock,t0);
        disp(['Total elapsed time: ' num2str(et)]);
    end
else
    disp('NOT THE SAME SCENE!');
    is_same = false;
    if verbose
        et = etime(clock,t0);
        disp(['Total elapsed time: ' num2str(et)]);
    end
end
%% visualization of the transformation distance
if visualize
    ff = figure; set(gcf, 'Position', fig_scrnsz);
    
    figure(ff); subplot(231); imshow(im1o); axis on, grid on, title('Image1');
    figure(ff); subplot(234); imshow(im2o); axis on, grid on, title('Image2');
    
    figure(ff); subplot(232); imshow(im1_trans); axis on, grid on, title('Last Transformed Image1');
    figure(ff); subplot(235); imshow(im2_trans); axis on, grid on, title('Last Transformed Image2');
    
    figure(ff); subplot(233); imshowpair(im1, im2_trans, 'blend'); axis on, grid on, title('Overlay of Image1 and transformed Image2');
    figure(ff); subplot(236); imshowpair(im2, im1_trans, 'blend'); axis on, grid on, title('Overlay of Image2 and transformed Image1');
        
    pause(0.5);
end

end

