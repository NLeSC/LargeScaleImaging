% show_cc - visualize CCs in a given figure/subplot with title w or w/o label
% **************************************************************************
% [label_mat, centr_cc] = show_cc(cc, show_label, idx, hfig, hsbplt, title_str)
%
% author: Elena Ranguelova, NLeSc
% date created: 15 Sep 2016
% last modification date: 19 Sep 2016
% modification details: added a new parameter- vector of region indecies to be shown
%**************************************************************************
% INPUTS:
% cc            connected components (as returned by bwconncomp(binary image)
% [show_label]  logical flag. If true the CC index is shown at the centroid
%               of each CC. Optional. Default is true.
% [idxs]        vector of region indecies to be shown. Optional.
% [hfig]        figure handle. Optional. If not given new figure is created
% [hsbplt]      subplot. Optional. If not given (111) is assumed, i.e. no subplot.
% [title_str]   title string. Optional. If not given no title is displayed.
%**************************************************************************
% OUTPUTS:
% label_mat    the label matrix used to visualize the CCs
% [center_cc]    structure with the CC's centroids (only if show_label is true)
%**************************************************************************
% NOTES:
%**************************************************************************
% EXAMPLES USAGE:
%
% see test_matching_SMI_desc_affine_dataset.m
%**************************************************************************
% REFERENCES:
%**************************************************************************
function [label_mat, centr_cc] = show_cc(cc, show_label,idxs, hfig, hsbplt, title_str)

%% input parameters
if nargin < 6
    title_str =[]; % no title
end
if nargin < 5
    hsbplt = subplot(111);
end
if nargin < 4
    hfig = figure;
end
if nargin < 3
    idxs =[];
end
if nargin < 2
    show_label = true;
end
if nargin < 1
    error('show_cc requires min. 1 input argument!');
end

%% input parameters -> variables
if isempty(idxs)
    num_regions = -1;
else
    num_regions = length(idxs);    
end

%% initializations
figure(hfig);
subplot(hsbplt);
centr_cc = struct();

%% computations
label_mat = labelmatrix(cc);

if num_regions < 0
    num_regions = cc.NumObjects;
end

%% visualize
imshow(label2rgb(label_mat));
axis on; grid on;

if show_label
    centr_cc = regionprops(cc,'Centroid');
    hold on;
    for k = 1:num_regions
        if num_regions > 10 && k <= 5
            col = 'm';
        else
            col = 'k';
        end
        if isempty(idxs)
            ind = k;
        else
            ind = idxs(k);
        end
        text(centr_cc(k).Centroid(1), centr_cc(k).Centroid(2), ...
            num2str(ind), 'Color', col, 'HorizontalAlignment', 'center');
    end
    hold off;
end

title(title_str);
end
