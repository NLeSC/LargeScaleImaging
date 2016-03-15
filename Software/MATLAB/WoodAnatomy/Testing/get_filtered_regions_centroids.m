% get_filtered_regions_centroids- gets the centroids of filtered regions
%**************************************************************************
% [list_centroids] = get_filtered_regions_centroids(regions_props_filename, ...
%                                              filtered_regions_filename)
%                                               
%
% author: Elena Ranguelova, NLeSc
% date created: 15 March 2015
% last modification date: 
% modification details: 
%**************************************************************************
% INPUTS:
% regions_props_filename- regions properties filename
% filtered_regions_filename- filtered regions filename
%**************************************************************************
% OUTPUTS:
% list_centroids - the list of centroids ofthe filtered regions
%**************************************************************************
% NOTES: called from testing scripts
%**************************************************************************
% EXAMPLES USAGE: 
% see scrpits (for example test.....m)
%**************************************************************************
% REFERENCES:
%**************************************************************************
function [list_centroids] = get_filtered_regions_centroids(regions_props_filename, ...
                                              filtered_regions_filename)
%% argument check                                          
if nargin < 2
    error('get_filtered_regions_centroids requires 2 input arguments!');
end                                       


%% get the centroids form the data in the input files

% get the indicies of the filtered regions
load(filtered_regions_filename,'filtered_regions_idx'); 

% get the regions properties of all regions
load(regions_props_filename, 'regions_properties');

% get the centroids of all regions
all_centroids = cat(1,regions_properties.Centroid);

% get only the filtered centroids
list_centroids = all_centroids(filtered_regions_idx,:);
