% dbscan_statisctics- computes statistics on the DBSCAN algorithm output
%**************************************************************************
% [stats] = dbscan_statistics(dbscan_vector)
%                                               
%
% author: Elena Ranguelova, NLeSc
% date created: 18 March 2015
% last modification date: 
% modification details: 
%**************************************************************************
% INPUTS:
% dbscan_vector- output of DBSCAN.m (see REFERENCES for code pointer)
%**************************************************************************
% OUTPUTS:
% list_centroids - the list of centroids ofthe filtered regions
%**************************************************************************
% NOTES: called from test_dbscan_filt_centroids.m
%**************************************************************************
% EXAMPLES USAGE: 
% see est_dbscan_filt_centroids.m
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
stats = [];
unique_elem = unique(dbscan_vector);
nonz_unique_elem = nonzeros(unique_elem)';
elem_per_class = zeros(1, length(nonz_unique_elem));

%% find the number of classes
num_classes = length(unique_elem);
% append output
stats = [stats num_classes];

%% find the elemtns which are considered noise
num_noise_elem = length(find(dbscan_vector==0));
% append output
stats = [stats num_noise_elem];

%% find the maximum index 
max_ind = max(unique_elem);

%% find the elements in each class

for cl = 1: max_ind
   [~,~,v] = find(dbscan_vector==cl);
   n = length(v);
   elem_per_class(cl) = n;
end


%% statistics from the elements per class
max_el = max(elem_per_class);
% append output
stats = [stats max_el];

min_el = min(elem_per_class);
% append output
stats = [stats min_el];

mean_el = mean(elem_per_class);
% append output
stats = [stats mean_el];

std_el = std(elem_per_class);
% append output
stats = [stats std_el];