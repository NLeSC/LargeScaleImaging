% mser_visualise_one.m- script for displaying the extracted MSER on 1 image
%**************************************************************************
%
% author: Elena Ranguelova, TNO
% date created: 7 Mar 08
% last modification date: 
% modification details: 
%**************************************************************************
% NOTES:
%**************************************************************************
% EXAMPLES USAGE:
% simply type
%
% mser_visualise_one
%
% and follow questions.
%
% To display all regions without labels scaled (factor 2) and thick (2)
% line:
% ------------------------------------------------------------------
%       Visualisation: Maximally Stable Extremal Regions (MSER)     
% ------------------------------------------------------------------
%                                                                   
% Enter the full filename of the input image: C:\ely\TNO\saliency\data\tails\na0034_1_tail_image.jpg
% Display image? [y/n]: y
% Automatically generate the features filename? [y/n]: y
% Display all regions? [y/n]: y
% Scale the ellipses? [y/n]: y
% Enter the scaling factor: 2
% Thick line? [y/n]: y
% Enter line thickness: 2
% Show region numbers? [y/n]: n
% Different colour for each region? [y/n]: n
% --------------- The End ---------------------------------
% 
%.................................................................
%
% To show only some regions with labels each in different colour 
%(as for example after matching) no scaling thickness 1: 
% ------------------------------------------------------------------
%       Visualisation: Maximally Stable Extremal Regions (MSER)     
% ------------------------------------------------------------------
%                                                                   
% Enter the full filename of the input image: C:\ely\TNO\saliency\data\tails\na0034_1_tail_image.jpg
% Display image? [y/n]: n
% Automatically generate the features filename? [y/n]: y
% Display all regions? [y/n]: n
% Enter the list of region numbers as vector: [1:2:10]
% Scale the ellipses? [y/n]: n
% Thick line? [y/n]: n
% Show region numbers? [y/n]: y
% Different colour for each region? [y/n]: y
% --------------- The End ---------------------------------
%**************************************************************************

clc; 
disp('------------------------------------------------------------------');
disp('      Visualisation: Maximally Stable Extremal Regions (MSER)     ');
disp('------------------------------------------------------------------');
disp('                                                                  ');

% input image
image_fname = input('Enter the full filename of the input image: ','s');

I_or = imread(image_fname);

% display
im_disp = input('Display image? [y/n]: ','s');

if lower(im_disp)=='y'
    f1 = figure; imshow(I_or); title(image_fname, 'Interpreter','none');
end

% read the saved features
    sav_fnames = input('Automatically generate the features filename? [y/n]: ','s');
    if lower(sav_fnames)=='y'
        i = find(image_fname =='.');
        j = i(end);
        if isempty(j)
            features_fname = [image_fname '.mser'];    
        else
            features_fname = [image_fname(1:j-1) '.mser'];
        end
    else
        features_fname = input('Enter the full filename for the features (ellipse representation): ','s');
    end
    
% visualise
    % open the saved regions
    [num_regions, features] = mser_open(features_fname);
    
    % enter the visualisation parameters
    all = input('Display all regions? [y/n]: ','s');
    if lower(all)=='y'
        list_regions = [];
    else
        list_regions = input('Enter the list of region numbers as vector: ');
    end
    
    scale = input('Scale the ellipses? [y/n]: ','s');
    if lower(scale)=='y'
        scaling = input('Enter the scaling factor: ');
    else
        scaling = 1;
    end

    line = input('Thick line? [y/n]: ','s');
    if lower(line)=='y'
        line_width = input('Enter line thickness: ');
    else
        line_width = 1;
    end

    lab = input('Show region numbers? [y/n]: ','s');
    if lower(lab)=='y'
        labels = 1;
    else
        labels = 0;
    end
    
        col = input('Different colour for each region? [y/n]: ','s');
        if lower(col)=='y'
            col_ellipse = [];
            load list_col_ellipse.mat
    %        col_ellipse = input('Enter the list of colours (one RGB triple per region): ');
            if lower(all)=='y'
                col_ellipse = list_col_ellipse(1:num_regions,:);
            else
                for i=1:length(list_regions)
                    col_ellipse = [col_ellipse; list_col_ellipse(list_regions(i),:)];  
                end
            end

        else
            col_ellipse = [];
        end
    col_label = []; % use default for now
    
   
    %addpath('..\MSSR');
    display_features_mser(image_fname, features_fname, [],[],0, ...
        list_regions, scaling, labels, col_ellipse, line_width, col_label, 0);

    title('MSER');
    disp('--------------- The End ---------------------------------');


