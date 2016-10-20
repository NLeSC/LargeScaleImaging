% IsSameScene-  comparing if 2 images are of the same scene
% **************************************************************************
% [is_same, matches_ratio, transf_dist] = IsSameScene(im1, im2, ...
%                      exec_params, moments_params, cc_params, match_params)
%
% author: Elena Ranguelova, NLeSc
% date created: 19 October 2016
% last modification date:
% modification details:
%**************************************************************************
% INPUTS:
% im1/2          the input gray/color or binary images to be compared
% [exec_params]  the execution parameters structure [optional] with fields:
%                verbose- flag for verbose mode, default value {false}
%                visualize- flag for vizualizing the matching, {false}
%                area_filering - flag for performing region (cc) area
%                   filtering, {true}
%                matches_filering - flag for performing matches filtering,
%                {true}
% [moments_params] optional struct with the moment invariants parameters:
%                  order- moments order, {4}
%                  coeff_file- coefficients file filename, {'afinvs4_19.txt'}
%                  max_num_moments- maximun number of moments, {16}
% [cc_params]     optional struct with the connected components parameters:
%                 conn - CC computaiton connectivity, {8}
%                 list_props list of CC properties to be computed:
%                   {'Area','Centroid','MinorAxisLength','MajorAxisLength',
%                                               'Eccentricity','Solidity'};
%                 area_factor - factor what is considered large CC in an
%                   image, {0.0005}
% [match_params]  the matching parameters struct [optional] with fields:
%                 match_metric- feature matching metric, see 'Metric' of
%                   matchFeatures. {'ssd'} = Sum of Sqared Differences
%                 match_thresh - matching threshold, see 'MatchThreshold'
%                   of matchFeatures. {1}
%                 max_ratio - ratio threshold, see 'MaxRatio' of
%                   matchFeatures. {0.75}
%                 max_dist - max distance from point to projection for
%                   estimating the geometric trandorm between matches. See
%                   "help estimateGeometricTransfrom". Default is {10}.
%                 cost_thresh - matching cost threshold. The match is
%                   considered good it its matching cost is above this
%                   threhsold. Default value is {0.025}
%                 matches_ratio_thresh- Threhsold for the ration of good to
%                   all matches. Should be as high as possible for a good
%                   image match. Default is {0.5}.
%                 transf_dist_thesh- Transformation distance threshold.
%                   For a good match between images the distance between
%                   an image and transformed with estimated transformation
%                   image should be small. Default is {2}.
%**************************************************************************
% OUTPUTS:
% is_same           binary flag, true if images are showing (partially)
%                   the same scene and false otherwise
% matches_ratio     ratio of good matches and all matches
% transf_dist       transformation distance between the 2 images
%**************************************************************************
% NOTES: The data-driven binarization is performed with default parameters.
%**************************************************************************
% EXAMPLES USAGE:
%
% see test_IsSameScene.m
%**************************************************************************
% REFERENCES:
%**************************************************************************
function [is_same, matches_ratio, transf_dist] = IsSameScene(im1, im2,...
    exec_params,moments_params, cc_params,match_params)

%% input control
if nargin < 6 || isempty(match_params)
    match_params.match_metric = 'ssd';
    match_params.match_thrseh = 1;
    match_params.max_ratio = 0.75;
    match_params.max_dist = 10;
    match_params.cost_thresh = 0.025;
    match_params.matches_ratio_thresh = 0.5;
    match_params.transf_dist_thresh = 2;
end
if nargin < 5 || isempty(cc_params)
    cc_params.conn = 8;
    cc_params.list_props = {'Area','Centroid','MinorAxisLength',...
        'MajorAxisLength', 'Eccentricity','Solidity'};
    cc_params.area_factor = 0.0005;
end
if nargin < 4 || isempty(moments_params)
    moments_params.order = 4;
    moments_params.coeff_file = 'afinvs4_19.txt';
    moments_params.max_num_moments = 16;
end
if nargin < 3 || isempty(exec_params)
    exec_params.verbose = false;
    exec_params.visualize = false;
    exec_params.area_filtering = true;
    exec_params.matches_filtering = true;
end
if nargin < 2
    error('IsSameScene: the function expects minimum 2 input arguments- the images to be compared!');
end

%% unpack parameter structures into variables
v2struct(exec_params);
v2struct(moments_params);
v2struct(cc_params);
v2struct(match_params);


%% dependant parameters
if area_filtering
    list_props_all = {'Area','Centroid'};
    prop_types_filter = {'Area'};
    image_area1 = size(im1, 1) * size(im1,2);
    image_area2 = size(im2, 1) * size(im2,2);
    range1 = {[area_factor*image_area1 image_area1]};
    range2 = {[area_factor*image_area2 image_area2]};
end

%% initializations

%**************** Processing *******************************
if verbose
    disp('Comparing wether 2 images depict (partially) the same scene...');
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
    
    if ndims(im1) == 2
        if verbose
            disp('Data-driven binarization 1...');
        end
        [bw1,thresh1] = data_driven_binarizer(im1);
    end
    if ndims(im2) == 2
        if verbose
            disp('Data-driven binarization 2...');
        end
        [bw2,thresh2] = data_driven_binarizer(im2);
    end
    if verbose
        toc
    end
else
    bw1 = logical(im1); bw2 = logical(im2);
end


%% visualization
if visualize
    figure('Position',get(0, 'Screensize'));
    
    subplot(121); imshow(im1); title('Gray-scale image1'); axis on, grid on;
    subplot(122); imshow(double(bw1)); axis on;grid on;
    title(['Binarized image at level ' num2str(thresh1)]);
    figure('Position',get(0, 'Screensize'));
    
    subplot(121); imshow(im2); title('Gray-scale image2'); axis on, grid on;
    subplot(122); imshow(double(bw2)); axis on;grid on;
    title(['Binarized image at level ' num2str(thresh2)]);
end
%% CC computation and possibly filtering
if verbose
    disp('Computing the connected components...');
end
tic
cc1 = bwconncomp(bw1,conn);
cc2 = bwconncomp(bw2,conn);
if verbose
    toc
end
if area_filtering
    if verbose
        disp('Area filering of the connected components...');
    end
    tic
    stats_cc1 = regionprops(cc1, list_props_all);
    stats_cc2 = regionprops(cc2, list_props_all);
    
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
if verbose
    if length(matched_pairs) > 3
        T = struct2table(matched_pairs);
    else
        disp('Not enough matches found!');
        disp('NOT THE SAME SCENE!');
        is_same = false; matches_ratio = NaN; transf_dist = NaN;
        if verbose
            disp('Total elapsed time: ');
            etime(clock,t0)
        end
        return;
    end
    if visualize
        disp('Matches: '); disp(T);
    end
    disp(['Number of matches: ' , num2str(num_matches)])
    disp(['Mean matching cost: ', num2str(mean(cost))]);
end

%% Filtering of the matches
if matches_filtering
    if verbose
        disp('Filtering of the matches...');
    end
    tic
    [filt_matched_pairs, ~, ...
        filt_cost, filt_num_matches] = filter_matches(matched_pairs, ...
        matched_ind, cost, cost_thresh);
    if verbose
        toc
    end
    matches_ratio = filt_num_matches/num_matches;
    
    if verbose
        if length(filt_matched_pairs) > 3
            filtT = struct2table(filt_matched_pairs);
        else
            disp('Not enough strong matches found!');
            disp('NOT THE SAME SCENE!');
            is_same = false; transf_dist = NaN;
            if verbose
                disp('Total elapsed time: ');
                etime(clock,t0)
            end
            return;
        end
    end
    
    if visualize
        disp('Filtered matches:' ); disp(filtT);
    end
    disp(['Filtered number of matches: ' , num2str(filt_num_matches)])
    disp(['Filtered mean matching cost: ', num2str(mean(filt_cost))]);
    disp(['====> Ratio filtered/all number of matches : ', num2str(matches_ratio)]);
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
    bwm1_trans, bwm2_trans] = transformation_distance(bwm1, bwm2, tform);
transf_dist = (dist1 + dist2)/2;
if verbose
    toc
end
if verbose
    disp(['Transformation distance1 is: ' num2str(dist1) ]);
    disp(['Transformation distance2 is: ' num2str(dist2) ]);
    disp(['====> Final (average) transformation distance is: ' num2str(transf_dist) ]);
    
    if (transf_dist < transf_dist_thresh) && ...
            ( matches_ratio > matches_ratio_thresh)
        disp('THE SAME SCENE!');
        is_same = true;
        if verbose
            disp('Total elapsed time: ');
            etime(clock,t0)
        end
        return;
    end
    
else
    disp('PROBABLY NOT THE SAME SCENE!');
    is_same = false;
    if verbose
        disp('Total elapsed time: ');
        etime(clock,t0)
    end
    return;
    
end

if verbose
    disp('Total elapsed time: ');
    etime(clock,t0)
end


