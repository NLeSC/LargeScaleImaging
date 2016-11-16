% display_oxfrei_dataset.m - function to display the OxFrei Dataset
%**************************************************************************
% [] = display_oxfrei_dataset(path, ext)
%
% author: Elena Ranguelova, NLeSc
% date created: 16 Nov 2016
% last modification date:
% modification details:
%**************************************************************************
% INPUTS:
% data_path        where the dataset is located
% [ext]            optional image filenames extension, {.png}
%**************************************************************************
% OUTPUTS:
%**************************************************************************
% NOTE:
%**************************************************************************
% EXAMPLES USAGE:
% data_path = 'C:\Projects\eStep\LargeScaleImaging\Data\OxFrei';
% display_oxfrei_dataset(data_path);
%% OR
% data_path = 'C:\Projects\eStep\LargeScaleImaging\Results\OxFrei\';
% ext = '_bin.png';
% display_oxford_dataset_structured(data_path, ext);
%**************************************************************************
% REFERENCES:
%**************************************************************************
function [] = display_oxfrei_dataset(path, ext)

%% input control
if nargin < 2
    ext = '.png';
end
if nargin < 1
    error(' display_oxfrei_dataset: the function expects minimum 1 input argument- the path of the dataset!');
end

disp('***********************************************************************');
disp('WARNING: For each of the 9 test cases only 9 images are displayed: ');
disp('the original and the first and last images of each of');
disp('the 4 transfomations: blur, lighting, scaling and viewpoint! ');
disp('The total number of images per test case is 21, here only 9 are shown! ');

%% parameters
test_cases = {'01_graffiti','02_freiburg_center', '03_freiburg_from_munster_crop',...
    '04_freiburg_innenstadt','05_cool_car', '06_freiburg_munster',...
    '07_graffiti','08_hall', '09_small_palace'};

%% make the figure
fig_scrnsz = get(0, 'Screensize');
offset = 0.25 * fig_scrnsz(4);
fig_scrnsz(2) = fig_scrnsz(2) + offset;
fig_scrnsz(4) = fig_scrnsz(4) - offset;
f1 = figure; set(gcf, 'Position', fig_scrnsz);
f2 = figure; set(gcf, 'Position', fig_scrnsz);
f3 = figure; set(gcf, 'Position', fig_scrnsz);

%% load and display
for i = 1: numel(test_cases)
    if ismember(i,[1 4 7])
        ind = 0;
    end
    
    test_case = char(test_cases{i});
    test_path = fullfile(path,test_case, 'PNG');
    image_fnames = dir(fullfile(test_path,'*.png'));
    
    for j = [1 2 6 7 11 12 16 17 21]
        
        fname = image_fnames(j).name;
        test_image = char(fullfile(test_path, fname));
        im = imread(test_image);
        
        if (i >=1) && (i<=3)
            figure(f1); hold on;
            ind = ind + 1;
        end
        if (i >=4) && (i<=6)
            figure(f2); hold on;
            ind = ind + 1;
        end
        if (i >=7) && (i<=9)
            figure(f3); hold on;
            ind = ind + 1;
        end
        subplot(3,9,ind);
        imshow(im);
        if j == 1
            xlabel_str = [num2str(j) ': ' fname];
            title_str = test_case;
        else
            title_str = '';
            if ismember(j, [2 7 12 17])
                xlabel_str = [num2str(j) ': ' fname ' ...'];
            else
                xlabel_str = [num2str(j) ': ' fname];
            end
        end
        title(title_str,'FontSize',12,'Interpreter','None');
        xlabel(xlabel_str,'FontSize',11,'Interpreter','None');
    end
    hold off;
end



