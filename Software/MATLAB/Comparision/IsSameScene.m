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

%% dependant parameters
if exec_params.area_filtering
    list_props_all = {'Area','Centroid'};
    prop_types_filter = {'Area'};
    image_area1 = size(im1, 1) * size(im1,2);
    image_area2 = size(im2, 1) * size(im2,2);
    range1 = {[area_factor*image_area1 image_area1]};
    range2 = {[area_factor*image_area2 image_area2]};
end
    
%% initializations

%**************** Processing *******************************
if exec_params.verbose
    disp('Comparing wether 2 images depict (partially) the same scene...');
end
%% binarization
if not( islogical(im1) && islogical(im2) ) 
    % find out the dimensionality
    if ndims(im1) == 3 && ndims(im2) == 3
        im1 = rgb2sray(im1); im2 = rgb2gray(im2);
    end
    if ndims(im1) == 2 && ndims(im2) == 2
        if exec_params.verbose
            disp('Data-driven binariztion...');
        end
        
       [bw1,~] = data_driven_binarizer(im1);
       [bw2,~] = data_driven_binarizer(im2);
       
    else 
       bw1 = logical(im1); bw2 = logical(im2);
    end
end
 
%% CC computaiton and possibly filtering
if exec_params.verbose
     disp('Computing the connected components...');
end

cc1 = bwconncomp(bw1,cc_params.conn);
cc2 = bwconncomp(bw2,cc_params.conn);

if exec_params.area_filerting
    if exec_params.verbose
        disp('Area filering of the connected components...');
    end
    stats_cc1 = regionprops(cc1, list_props_all);
    stats_cc2 = regionprops(cc2, 'Centroid');
    
    [bw1_f, index1, ~] = filter_regions(bw1, stats_cc1, prop_types_filter,...
        {}, range1, cc1); 
    [bw2_f, index2, ~] = filter_regions(bw2, stats_cc2, prop_types_filter,...
        {}, range2, cc2);
    
    if exec_params.visualize
        if exec_params.verbose
            disp('Computing the filtered connected components...');
        end
        cc1_f = bwconncomp(bw1_f,conn);
        cc2_f = bwconncomp(bw2_f,conn);        
    end    
end

%% SMI descriptor computaiton
if exec_params.verbose
     disp('Shape and Moment Invariants (SMI) descriptors computaiton...');
end
if exec_params.area_filerting
    bw1_d = bw1_f; bw2_d = bw2_f;
else
    bw1_d = bw1; bw2_d = bw2;
end

[SMI_descr1,SMI_descr1_struct] = SMIdescriptor(bw1_d, conn, ...
    cc_params.list_props, moments_params.order, ...
    moments_params.coeff_file, moments_params.max_num_moments);
[SMI_descr2,SMI_descr2_struct] = SMIdescriptor(bw2_d, conn, ...
    cc_params.list_props, moments_params.order, ...
    moments_params.coeff_file, moments_params.max_num_moments);

%% Matching the SMI descriptors
if exec_params.verbose
     disp('SMI descriptors matching...');
end
if exec_params.area_filerting
    ind1 = index1; ind2 = index2;
else
    ind1 = []; ind2 = [];
end

[matched_pairs, cost, matched_ind, num_matches] = matching(...
    SMI_descr1, SMI_descr2, ...
    match_params.match_metric, ...
    match_params.match_thresh, ...
    match_params.max_ratio, true, ...    
    exec_params.area_filerting, ind1, ind2);

if exec_params.verbose    
    if length(matched_pairs) > 3
        T = struct2table(matched_pairs);
    else        
        disp('Not enough matches found!');
        disp('NOT THE SAME SCENE!');
        is_same = false; matches_ratio = NaN; transf_dist = NaN;
        return;
    end
    
    disp('Matches: '); disp(T);
    disp(['Number of matches: ' , num2str(num_matches)])
    disp(['Mean matching cost: ', num2str(mean(cost))]);
end
  
%% Filtering of the matches
if exec_params.matches_filtering
    if exec_params.verbose
        disp('Filtering of the matches...');
    end
    
    [filt_matched_pairs, filt_matched_ind, ...
        filt_cost, filt_num_matches] = filter_matches(matched_pairs, ...
        matched_ind, cost, match_params.cost_thresh);
    
    matches_ratio = filt_num_matches/num_matches;
    
    if exec_params.verbose
        if length(filt_matched_pairs) > 3
            filtT = struct2table(filt_matched_pairs);
        else
            disp('Not enough strong matches found!');
            disp('NOT THE SAME SCENE!');
            is_same = false; transf_dist = NaN;
            return;
        end
        
        disp('Filtered matches:' ); disp(filtT);
        disp(['Filtered number of matches: ' , num2str(filt_num_matches)])
        disp(['Filtered mean matching cost: ', num2str(mean(filt_cost))]);
        disp(['====> Ratio filtered/all number of matches : ', num2str(matches_ratio)]); 
    end
end

%% Estimation of affine transformation between the 2 images from the matches
if exec_params.verbose
   disp('Estimating affine transformation from the matches...');
end

if exec_params.matches_filerting
    matched_pairs_d = filt_matched_pairs;
else
    matched_pairs_d = matched_pairs;
end

[tform,inl1, inl2, status] = estimate_affine_tform(matched_pairs_d, ...
        stats_cc1, stats_cc2, max_dist);

if exec_params.verbose
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
if exec_params.verbose
   disp('Computing the distances between the pairs <image, transformed_image>');
end

% get the matched region indicies = TO DO check if equivalent to the commented code!!
% if exec_parameters.matches_filtering
%     for i = 1:filt_num_matches
%         indicies1(i) = filt_matched_pairs(i).first;
%         indicies2(i) =  filt_matched_pairs(i).second;        
%     end
% else
%     for i = 1:num_matches
%         indicies1(i) =  matched_pairs(i).first;
%         indicies2(i) = matched_pairs(i).second;
%     end
% end
if exec_parameters.matches_filtering
    indicies1 = filt_matched_ind(:,1);
    indicies2 = filt_matched_ind(:,2);
else
    indicies1 = matched_ind(:,1);
    indicies2 = matched_ind(:,2);
end

% generate binary images only from the matched regions
bwm1 = regions_subset2binary(bw1, indicies1, conn);
bwm2 = regions_subset2binary(bw2, indicies2, conn);

% compute the transformaition distance between the matched regions
[diff1, diff2, dist1, dist2, ...
    bwm1_trans, bwm2_trans] = transformation_distance(bwm1, bwm2, tform);
transf_dist = (dist1 + dist2)/2;

if exec_params.verbose
    disp(['Transformation distance1 is: ' num2str(dist1) ]);
    disp(['Transformation distance2 is: ' num2str(dist2) ]);
    disp(['====> Final (average) transformation distance is: ' num2str(transf_dist) ]);
    
    if (transf_dist < match_params.dist_thresh) && ...
            ( matches_ratio > match_params.match_ratio_thresh)
        disp('THE SAME SCENE!');
        is_same = true; 
        return;
        
    else
        disp('PROBABLY NOT THE SAME SCENE!');
        is_same = false;
        return;
    end
end


