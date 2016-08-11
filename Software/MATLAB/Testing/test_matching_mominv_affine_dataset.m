% test_matching_mominv_affine_dataset- testing matching with Flusser's affine moment
%                       invariants as descriptors of the salient regions
%                       for the oxford dataset
%**************************************************************************
% author: Elena Ranguelova, NLeSc
% date created: 10-08-2016
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
verbose = 1;
vis = 1;

% moments parameters
%order = input('Enter the order (up to 4) of the moments: ');
order = 4;

coeff_file = 'afinvs4_19.txt';
%num_moments =  input('How many invariants to consider (max 66)?: ');
max_num_moments = 66;
%max_num_moments = 8;

% CC parameters
list_properties = {'Centroid'};

%% load DMSR regions
if verbose
    disp('Loading a binary DMSR regions files...');
end
load('C:\Projects\eStep\LargeScaleImaging\Results\AffineRegions\graffiti\graffiti1_dmsrregions.mat','saliency_masks');
%load('C:\Projects\eStep\LargeScaleImaging\Results\AffineRegions\leuven\leuven1_dmsrregions.mat','saliency_masks')
%load('C:\Projects\eStep\LargeScaleImaging\Results\AffineRegions\boat\boat1_dmsrregions.mat', 'saliency_masks')
saliency_masks_o = saliency_masks;
load('C:\Projects\eStep\LargeScaleImaging\Results\AffineRegions\graffiti\graffiti3_dmsrregions.mat','saliency_masks');
%load('C:\Projects\eStep\LargeScaleImaging\Results\AffineRegions\leuven\leuven5_dmsrregions.mat','saliency_masks');
%load('C:\Projects\eStep\LargeScaleImaging\Results\AffineRegions\boat\boat3_dmsrregions.mat', 'saliency_masks')
saliency_masks_a = saliency_masks;

% determine the number of saliency types
dim  = ndims(saliency_masks);
num_masks = size(saliency_masks,dim);

% visualise
if vis
    if num_masks <= 2
        figure; set(gcf, 'Position', get(0, 'Screensize'));
        subplot(221);imshow(saliency_masks_o(:,:,1)); title('Binary mask or. (holes)'); axis on, grid on;
        subplot(223);imshow(saliency_masks_a(:,:,1)); title('Binary mask trans. (holes)'); axis on, grid on;
        if num_masks > 1
            subplot(222);imshow(saliency_masks_o(:,:,2)); title('Binary mask or. (islands)'); axis on, grid on;
            subplot(224);imshow(saliency_masks_a(:,:,2)); title('Binary mask trans. (islands)'); axis on, grid on;
        end
    else if num_masks <= 4
            figure; set(gcf, 'Position', get(0, 'Screensize'));
            subplot(221);imshow(saliency_masks_o(:,:,3)); title('Binary mask or. (indent.)'); axis on, grid on;
            subplot(223);imshow(saliency_masks_a(:,:,3)); title('Binary mask trans. (indent.)'); axis on, grid on;
            if num_masks > 3 
                subplot(222);imshow(saliency_masks_o(:,:,4)); title('Binary mask or. (protr.)'); axis on, grid on;
                subplot(224);imshow(saliency_masks_a(:,:,4)); title('Binary mask trans. (protr.)'); axis on, grid on;
            end
        end
    end
end

% %% obtain connected components
% if verbose
%     disp('Obtain the connected components...');
% end
% cc = bwconncomp(bw);
% cc_a = bwconncomp(bw_a);
% 
% % visualise
% if vis
%     stats_cc = regionprops(cc,list_properties);
%     labeled = labelmatrix(cc);
%     figure(f); subplot(223);imshow(label2rgb(labeled));
%     hold on;
%     for k = 1:numel(stats_cc)
%         if numel(stats_cc) > 3 && k <= 2
%             col = 'w';
%         else
%             col = 'k';
%         end
%         text(stats_cc(k).Centroid(1), stats_cc(k).Centroid(2), num2str(k), ...
%         'Color', col, 'HorizontalAlignment', 'center')
%     end
%     hold off;
% 
%     title('Connected Components'); axis on, grid on;
%     
% 
%     stats_cc_a = regionprops(cc_a,list_properties);
%     labeled = labelmatrix(cc_a);
%     subplot(224);imshow(label2rgb(labeled)); 
%     hold on;
%     for k = 1:numel(stats_cc_a)
%         if numel(stats_cc) > 3 && k <= 2
%             col = 'w';
%         else
%             col = 'k';
%         end
%         text(stats_cc_a(k).Centroid(1), stats_cc_a(k).Centroid(2), num2str(k), ...
%             'Color', col, 'HorizontalAlignment', 'center')
%     end
%     hold off;
%     title('Connected Components (affine)'); axis on, grid on;
% end

%% compute scale moments invariants of all CCs

% load coefficients
coeff = readinv(coeff_file);

if verbose
    disp('Processing original image ... ');
end

moment_invariants = sal_masks2aff_inv(saliency_masks_o, order, coeff);
if verbose
    disp('Moment invariants: '); disp(moment_invariants);
    disp('--------------------------------------------');
end

if verbose
    disp('Processing affine image ... ');
end

moment_invariants_a = sal_masks2aff_inv(saliency_masks_a, order, coeff);    %#ok<*SAGROW>

if verbose
    disp('Moment invariants: '); disp(moment_invariants_a);
    disp('--------------------------------------------');
end

%% compute the mean squared error as a function of number of moments
for j = 1:max_num_moments
    err(j) = immse(moment_invariants(:,1:j), moment_invariants_a(:,1:j));
end

%% visualise
if vis
    figure;
    subplot(211);
    if num_masks >= 1
        plot(1:max_num_moments, moment_invariants(1,:),'b-o',...
            1:max_num_moments, moment_invariants_a(1,:),'b--o');
        if num_masks >=2
            hold on;
            plot(1:max_num_moments, moment_invariants(2,:),'y-o',...
                1:max_num_moments, moment_invariants_a(2,:),'y--o');
            if num_masks >=3
                hold on;
                plot(1:max_num_moments, moment_invariants(3,:),'g-o',...
                    1:max_num_moments, moment_invariants_a(3,:),'g--o');
                if num_masks ==3
                    hold on;
                    plot(1:max_num_moments, moment_invariants(4,:),'r-o',...
                        1:max_num_moments, moment_invariants_a(4,:),'r--o');
                end
            end
        end
    end
    hold off
    axis on; grid on;
    legend({'original', 'affine'});
    title('Moment invariants');
    subplot(212);plot(1:max_num_moments, err,'r-o');
    axis on; grid on;
    title('MSE');
end

%% matching the invariants and count the matches
% matched_pairs = {};
% num_matches = zeros(1, max_num_moments);
% for m = 2:max_num_moments
%     features = moment_invariants(:,1:m);
%     features_a = moment_invariants_a(:,1:m);
%     matched_pairs{m} = matchFeatures(features, features_a);
%     num_matches(m) = size(matched_pairs{m},1);
% end

%% matches
if vis
    
%     figure; set(gcf, 'Position', get(0, 'Screensize'));
%     plot(1:max_num_moments,num_matches, 'r-^');
%     axis on; grid on;
%     xlabel('Number of invariants');
%     title('Matched regions');
end
