% show_labelmatrix - visualize a label matrix in a given figure/subplot
%                    with title w or w/o labels
% **************************************************************************
% show_labelmatrix(lm, show_ind, idxs, centr_cc, hfig, hsbplt, title_str)
%
% author: Elena Ranguelova, NLeSc
% date created: 16 Sep 2016
% last modification date:
% modification details:
%**************************************************************************
% INPUTS:
% lm            label matrix 
% [show_ind]    logical flag. If true the CC index is shown at the centroid
%               of each CC. Optional. Default is true.
% [idxs]        vector of region indecies to be shown
% [center_cc]   structure with the CC's centroids (only if show_label is true)
% [hfig]        figure handle. Optional. If not given new figure is created
% [hsbplt]      subplot. Optional. If not given (111) is assumed, i.e. no subplot.
% [title_str]   title string. Optional. If not given no title is displayed.
%**************************************************************************
% OUTPUTS:
%**************************************************************************
% NOTES:
%**************************************************************************
% EXAMPLES USAGE:
%
% see test_matching_SMI_desc_affine_dataset.m
%**************************************************************************
% REFERENCES:
%**************************************************************************
function [] = show_labelmatrix(lm, show_ind, idxs, centr_cc, hfig, hsbplt, title_str)

%% input parameters
if nargin < 7
    title_str =[]; % no title
end
if nargin < 6
    hsbplt = subplot(111);
end
if nargin < 5
    hfig = figure;
end
if nargin < 4 && show_ind
    error('show_labelmatrix requires structure with centroids to display labels!');
end
if nargin < 3 && show_ind
    error('show_labelmatrix requires vector with region indexes for display!');
end
if nargin < 2
    show_ind = true;
end
if nargin < 1
    error('show_labelmatrix requires min. 1 input argument!');
end

%% input parameters -> variables
num_regions = length(idxs);

%% initializations
figure(hfig);
subplot(hsbplt);

%% computations


%% visualize
imshow(label2rgb(lm));
axis on; grid on;

if show_ind
    hold on;
    for k = 1:num_regions
        if num_regions > 50 && k <= 20
            col = 'm';
        else
            col = 'k';
        end
        ind = idxs(k);
        text(centr_cc(ind).Centroid(1), centr_cc(ind).Centroid(2), ...
            num2str(ind), 'Color', col, 'HorizontalAlignment', 'center');
    end
    hold off;
end

title(title_str);
end
