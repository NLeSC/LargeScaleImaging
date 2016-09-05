% test_matching_mominv_affine_dataset- testing matching with Flusser's affine moment
%                       invariants as descriptors of the salient regions
%                       for the oxford dataset
%**************************************************************************
% author: Elena Ranguelova, NLeSc
% date created: 10-08-2016
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% last modification date: 15-08-2016
% modification details: using region filtering
% last modification date: 11-08-2016
% modification details: using affine_invariants function
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
verbose = 0;
vis = 1;
regions = true; % true if matching per individual regions

% moments parameters
%order = input('Enter the order (up to 4) of the moments: ');
order = 4;

coeff_file = 'afinvs4_19.txt';
%num_moments =  input('How many invariants to consider (max 66)?: ');
%max_num_moments = 66;
max_num_moments = 4;
dist_type = 'euclidean'; %'hamming';
match_type = 'sad';

% CC parameters
list_properties = {'Centroid','Area'};
area_factor = 0.0005;

%% load DMSR regions for base image
if verbose
    disp('Loading a binary DMSR regions files...');
end


%load('C:\Projects\eStep\LargeScaleImaging\Results\AffineRegions\graffiti\graffiti1_dmsrregions.mat','saliency_masks');
%load('C:\Projects\eStep\LargeScaleImaging\Results\AffineRegions\leuven\leuven1_dmsrregions.mat','saliency_masks')
load('C:\Projects\eStep\LargeScaleImaging\Results\AffineRegions\boat\boat1_dmsrregions.mat', 'saliency_masks')
%load('C:\Projects\eStep\LargeScaleImaging\Results\AffineRegions\bikes\bikes1_dmsrregions.mat','saliency_masks');


% determine the number of saliency types
dim  = ndims(saliency_masks);
num_masks = 1; %size(saliency_masks,dim);
ind = 2; % only islands

imageArea = size(saliency_masks,1) * size(saliency_masks,2);
%for m = 1:num_masks
saliency_masks_o = imfill(saliency_masks(:,:,ind),'holes');
%end


%% load DMSR regions for transformedimage(s)
for h = 2:6
    load(['C:\Projects\eStep\LargeScaleImaging\Results\AffineRegions\graffiti\graffiti' num2str(h) '_dmsrregions.mat'],'saliency_masks');
  %  load(['C:\Projects\eStep\LargeScaleImaging\Results\AffineRegions\leuven\leuven' num2str(h) '_dmsrregions.mat'],'saliency_masks');
  %  load(['C:\Projects\eStep\LargeScaleImaging\Results\AffineRegions\boat\boat' num2str(h) '_dmsrregions.mat'], 'saliency_masks')
  %  load(['C:\Projects\eStep\LargeScaleImaging\Results\AffineRegions\bikes\bikes' num2str(h) '_dmsrregions.mat'],'saliency_masks');
    
    
    %for m = 1:num_masks
    saliency_masks_a = imfill(saliency_masks(:,:,ind),'holes');
    %end
    
    
    %% obtain connected components
    if verbose
        disp('Obtain the connected components...');
    end
    cc = bwconncomp(saliency_masks_o);
    cc_a = bwconncomp(saliency_masks_a);
    
    %% filter out the smallest regions
    stats_cc = regionprops(cc,list_properties);
    stats_cc_a = regionprops(cc_a,list_properties);
    
    prop_types = {'Area'};
    ranges = {[area_factor*imageArea imageArea]};
    if regions
        [saliency_mask_o_f, index_o, ~] = filter_regions(saliency_masks_o, stats_cc, prop_types, {}, ranges, cc);
        [saliency_mask_a_f, index_a, ~] = filter_regions(saliency_masks_a, stats_cc_a, prop_types, {}, ranges, cc_a);
    else
        [saliency_mask_o_f, ~, ~] = filter_regions(saliency_masks_o, stats_cc, prop_types, {}, ranges, cc);
        [saliency_mask_a_f, ~, ~] = filter_regions(saliency_masks_a, stats_cc_a, prop_types, {}, ranges, cc_a);
        
    end
    
    % obtain the new filtered CCs
    cc_f = bwconncomp(saliency_mask_o_f);
    cc_a_f = bwconncomp(saliency_mask_a_f);
    
    %% visualise
    if vis
        % original images  (masks)
        if num_masks <= 2
            f = figure; set(gcf, 'Position', get(0, 'Screensize'));
            subplot(221);imshow(saliency_masks_o(:,:,1)); title('Binary mask or. (holes)'); axis on, grid on;
            subplot(223);imshow(saliency_masks_a(:,:,1)); title('Binary mask transf. (holes)'); axis on, grid on;
            if num_masks > 1
                subplot(222);imshow(saliency_masks_o(:,:,2)); title('Binary mask or. (islands)'); axis on, grid on;
                subplot(224);imshow(saliency_masks_a(:,:,2)); title('Binary mask transf. (islands)'); axis on, grid on;
            end
        else if num_masks <= 4
                f1 =  figure; set(gcf, 'Position', get(0, 'Screensize'));
                subplot(221);imshow(saliency_masks_o(:,:,3)); title('Binary mask or. (indent.)'); axis on, grid on;
                subplot(223);imshow(saliency_masks_a(:,:,3)); title('Binary mask transf. (indent.)'); axis on, grid on;
                if num_masks > 3
                    subplot(222);imshow(saliency_masks_o(:,:,4)); title('Binary mask or. (protr.)'); axis on, grid on;
                    subplot(224);imshow(saliency_masks_a(:,:,4)); title('Binary mask transf. (protr.)'); axis on, grid on;
                end
            end
        end
        
        
        % filtered
        if regions                        
            labeled = labelmatrix(cc_f);
            figure(f); subplot(222);imshow(label2rgb(labeled));
            hold on;
            for k = 1:length(index_o)
                if length(index_o) > 3 && k <= 2
                    col = 'm';
                else
                    col = 'k';
                end
                text(stats_cc(index_o(k)).Centroid(1), stats_cc(index_o(k)).Centroid(2), ...
                    num2str(index_o(k)), 'Color', col, 'HorizontalAlignment', 'center')
            end
            hold off;
            
            title('Conn. Comp. (after filtering)'); axis on, grid on;
            
            labeled = labelmatrix(cc_a_f);
            subplot(224);imshow(label2rgb(labeled));
            hold on;
            for k = 1:length(index_a)
                if length(index_a) > 3 && k <= 2
                    col = 'm';
                else
                    col = 'k';
                end
                text(stats_cc_a(index_a(k)).Centroid(1), stats_cc_a(index_a(k)).Centroid(2),...
                    num2str(index_a(k)), 'Color', col, 'HorizontalAlignment', 'center')
            end
            hold off;
            title('Conn. Comp. transf. (after filt.)'); axis on, grid on;
        else % the binary mask seen as a whole
            figure(f); subplot(222);imshow(saliency_mask_o_f);
            title('Conn. Comp. (after filtering)'); axis on, grid on;
            subplot(224);imshow(saliency_mask_a_f);
            title('Conn. Comp. transf. (after filt.)'); axis on, grid on;
            
        end
    end
    
    
    %% compute scale moments invariants of all CCs
    
    % load coefficients
    coeff = readinv(coeff_file);
    
    if verbose
        disp('Processing original image ... ');
    end
    
    
    if regions
        num_regions = length(index_o); %cc.NumObjects;
        
        for i = 1:num_regions
            bwi = zeros(size(saliency_mask_o_f));
            bwi(cc_f.PixelIdxList{i}) = 1;
            [moment_invariants(i,:)] = affine_invariants(bwi, order, coeff);
        end
        
    else
        moment_invariants = sal_masks2aff_inv(saliency_mask_o_f, order, coeff);
    end
    
    if verbose
        disp('Moment invariants: '); disp(moment_invariants);
        disp('--------------------------------------------');
    end
    
    if verbose
        disp('Processing affine image ... ');
    end
    
    if regions
        num_regions = length(index_a); %cc_a.NumObjects;
        for i = 1:num_regions
            bwi = zeros(size(saliency_mask_a_f));
            bwi(cc_a_f.PixelIdxList{i}) =1;
            [moment_invariants_a(i,:)] = affine_invariants(bwi, order, coeff);
        end
    else
        moment_invariants_a = sal_masks2aff_inv(saliency_mask_a_f, order, coeff);
    end
    
    if verbose
        disp('Moment invariants: '); disp(moment_invariants_a);
        disp('--------------------------------------------');
    end
    
    %% compute the mean squared error as a function of number of moments
    for i = 1:num_masks
        for j = 1:max_num_moments
           % err(i,j) = norm(moment_invariants(i,1:j) - moment_invariants_a(i,1:j));
           %  err(i,j) = immse(moment_invariants(i,1:j), moment_invariants_a(i,1:j));
             dist(i,j) = pdist2(moment_invariants(i,1:j), moment_invariants_a(i,1:j),dist_type);
        end
    end
    
    % visualise
    if vis
        figure;
        subplot(211);
        if num_masks >= 1
            plot(1:max_num_moments, moment_invariants(1,1:max_num_moments),'b-o',...
                1:max_num_moments, moment_invariants_a(1,1:max_num_moments),'b--o');
            if num_masks >=2
                hold on;
                plot(1:max_num_moments, moment_invariants(2,1:max_num_moments),'y-o',...
                    1:max_num_moments, moment_invariants_a(2,1:max_num_moments),'y--o');
                if num_masks >=3
                    hold on;
                    plot(1:max_num_moments, moment_invariants(3,1:max_num_moments),'g-o',...
                        1:max_num_moments, moment_invariants_a(3,1:max_num_moments),'g--o');
                    if num_masks ==3
                        hold on;
                        plot(1:max_num_moments, moment_invariants(4,1:max_num_moments),'r-o',...
                            1:max_num_moments, moment_invariants_a(4,1:max_num_moments),'r--o');
                    end
                end
            end
        end
        hold off
        axis on; grid on;
        legend({'original', 'affine'});
        title('Moment invariants');
       % subplot(212);plot(1:max_num_moments, err);
        subplot(212);plot(1:max_num_moments, dist);
        axis on; grid on;
      %  title('MSE');
      title('Distance');
    end
    
    if regions
        %% matching the invariants and count the matches
        matched_pairs = [];
        matched_indicies = {};
        num_matches = zeros(1, max_num_moments);
        for m = 2:max_num_moments
            features = moment_invariants(:,1:m);
            features_a = moment_invariants_a(:,1:m);
            [matched_indicies{m},cost{m}] = matchFeatures(features, ...
                features_a,'Metric',match_type);
            num_matches(m) = size(matched_indicies{m},1);
        end
        
        for i = 1:num_matches(max_num_moments)
            matched_pairs(i).first_region = index_o(matched_indicies{max_num_moments}(i,1));
            matched_pairs(i).second_region = index_a(matched_indicies{max_num_moments}(i,2));
        end
        
        T = struct2table(matched_pairs);
        clear matched_pairs index_o index_a features features_a
        %% matches
        %     if vis
        %
        %             figure; set(gcf, 'Position', get(0, 'Screensize'));
        %             plot(1:max_num_moments,num_matches, 'r-^');
        %             axis on; grid on;
        %             xlabel('Number of invariants');
        %             title('Matched regions');
        %     end
        
        if regions            
            disp(['Matches for 1 and ' num2str(h),': ']); disp(T);
        end
    end
    
     
    
    if true
       % disp(['Final MSE: ', num2str(err(end))]);
        disp(['Final distance: ', num2str(dist(end))]);
    end
    
end