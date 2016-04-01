% dbscan_statistics- computes statistics on the DBSCAN algorithm output
%**************************************************************************
% [stats] = dbscan_statistics(dbscan_vector)
%                                               
%
% author: Elena Ranguelova, NLeSc
% date created: 18 March 2016
% last modification date: 1 April 2016
% modification details: normalize the number of elements per class witht he
% total number of elements
% last modification date: 22 March 2016
% modification details: better code documentation
%**************************************************************************
% INPUTS:
% dbscan_vector- output of DBSCAN.m (see REFERENCES for code pointer)
%**************************************************************************
% OUTPUTS:
% stats - statistics derived from the dbscan_vector; stats has elements:
% 1: total number of classes; 
% 2: number of noise elements(class 0)
% vector of number ofelements per any other class than noise is constructed
% 3: max of the elements-per-class-vector (EPCV)
% 4: min of EPCV
% 5: mean of EPCV
% 6: std ofEPCV
%**************************************************************************
% NOTES: called from test_dbscan_filt_centroids.m
%**************************************************************************
% EXAMPLES USAGE: 
% see test_dbscan_filt_centroids.m
% also a simple test:
% dbscan_vector = [0 0 1 1 0 3 2 1 2 3 0 2];
% [stats] = dbscan_statistics(dbscan_vector)
% Result:
% stats =  4.0000    4.0000    3.0000    2.0000    2.6667    0.5774
%**************************************************************************
% REFERENCES:
% https://en.wikipedia.org/wiki/DBSCAN
% http://yarpiz.com/255/ypml110-dbscan-clustering
%**************************************************************************
function [stats] = dbscan_statistics(dbscan_vector)

%% argument check                                          
if nargin < 1
    error('dbscan_statistics requires 1 input argument!');
end

%% initializations
num_stats = 6; % 6 features are computed
stats = zeros(1, num_stats);
num_all_elem = length(dbscan_vector);
unique_elem = unique(dbscan_vector);
nonz_unique_elem = nonzeros(unique_elem)';
elem_per_class = zeros(1, length(nonz_unique_elem));

%% find the number of classes
num_classes = length(unique_elem);
% add
stats(1) = num_classes;

%% find the elemtns which are considered noise
num_noise_elem = length(find(dbscan_vector==0));
% add
stats(2) = num_noise_elem/num_all_elem;

%% find the maximum index 
max_ind = max(unique_elem);

if max_ind > 0
    %% find the elements in each class
    for cl = 1: max_ind
        [~,~,v] = find(dbscan_vector==cl);
        n = length(v);
        elem_per_class(cl) = n;
    end
    
    
    %% statistics from the elements per class
    max_el = max(elem_per_class);
    % add
    stats(3) = max_el/num_all_elem;
    
    min_el = min(elem_per_class);
    % append output
    stats(4) = min_el/num_all_elem;
    
    mean_el = mean(elem_per_class);
    % append output
    stats(5) = mean_el/num_all_elem;
    
    std_el = std(elem_per_class);
    % append output
    stats(6) = std_el;
end