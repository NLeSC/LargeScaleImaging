% filter_regions- filters binary regions on a pre-computed regionprops
% **************************************************************************
% [bw_filt, regions_idx, threshs] = filter_regions(bw, region_props, ...
%                                   prop_types, logic_ops, range, conn_comp) 
%
% author: Elena Ranguelova, NLeSc
% date created: 15 Aug 2016
% last modification date: 
% modification details: 
%**************************************************************************
% INPUTS:
% bw            binary image (logical)- can be mask of detected regions
% region_props  region properties as result of MATLAB's regionprops
% prop_types    list of types of properties to filter on
% [logic_ops]   list of logical operations between the filter conditions;
%               if empty- default is 'AND'; the order of evaluaiton is
%               strictly left to right
% [ranges]      list of vectors of ranger (2 thresholds) per property type 
%               to filter on; 
%               if empty- every range is [0.1 0.9]*max_value(prop_types{i})
% [conn_comp]   connected components pre-computed from bw (e.g. by a detector)
%               if empty- they are computed from bw using default connectivity
%**************************************************************************
% OUTPUTS:
% bw_filt       binary image (logical) containing the filtered regions
% regions_idx   index of filtered regions
% threshs       the threshold values = ranges or ranges*max_value (per property)
%**************************************************************************
% NOTES: 
%**************************************************************************
% EXAMPLES USAGE: 
% 
% see test_filter_regions.m
%**************************************************************************
% REFERENCES:
%**************************************************************************
function [bw_filt, regions_idx, threshs] = filter_regions(bw, region_props, ...
                                   prop_types, logic_ops, ranges, conn_comp)

%% input parameters
if nargin < 3
    error('filter_regions requires min. 3 input arguments!');
else
   num_conds = length(prop_types);
end
if nargin < 6 || isempty(conn_comp)  
    conn_comp = bwconncomp(bw);
end
if nargin < 5 || isempty(ranges)
        auto_range = true;
    for i = 1:num_conds
        ranges{i} = [0.1 0.9];
    end
else
    auto_range = false;
end
if nargin < 4 || isempty(logic_ops)
    if num_conds > 1
        for j =  1: num_conds - 1
            logic_ops{j} = 'AND';
        end
    end
end
num_logic_ops = length(logic_ops);
possible_logic_ops = {'or', 'and'};
for j = 1:num_logic_ops
    if ~ismember(lower(char(logic_ops{j})), possible_logic_ops)
        error('Parameter logic_ops per element can be only one of: AND|OR');
    end
end
if num_logic_ops ~= (num_conds - 1)
    error('The number of the logical operations should be with 1 less than the number of filterring conditions');
end

%% initializations
bw_filt = false((size(bw)));
threshs = cell(1, num_conds);
num_regions = numel(region_props);
index = ones(num_regions,1);

%% processing
for i = 1:num_conds
    prop_stat = char(prop_types{i});
    % values per property type
    stats_values = cat(1,region_props.(prop_stat));
    range = ranges{i};
    % show the histogram for debugging
%     h =  histcounts(stats_values, 50, 'Normalization','probability');
%     figure; bar(h);
    
    %% compute the thresholds
    if auto_range
        max_value  = max(stats_values(:));
        lo_thr = range(1)*max_value;
        hi_thr = range(2)*max_value;
    else
        lo_thr = range(1);
        hi_thr = range(2);
    end
    %% select the regions within [lo_thr hi_thr]
    sub_index = (stats_values >= lo_thr) & (stats_values <= hi_thr);
    if i == 1 
        index = and(index, sub_index);
    else
        oper = char(logic_ops{i-1});
        switch lower(oper)
            case 'and'
                index = and(index, sub_index);
            case 'or'
                index = or(index, sub_index);
        end
    end
    threshs{i} = [lo_thr hi_thr];
    clear stats_values sub_index
end

%% find the pixel indicies to keep
pixels_idx = conn_comp.PixelIdxList(index);
clear conn_comp
pixels_idx = vertcat(pixels_idx{:});

%% make the new binary image and return the non-zero region indicies and threshold
bw_filt(pixels_idx) = true;

regions_idx = find(index);

end
