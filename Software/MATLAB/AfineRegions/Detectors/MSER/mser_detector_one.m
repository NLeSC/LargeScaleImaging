% mser_detector_one.m- script for applying MSER detector on 1 image
%**************************************************************************
%
% author: Elena Ranguelova, TNO
% date created: 6 Mar 08
% last modification date: 
% modification details: 
%**************************************************************************
% NOTES: for now produces only regions in ellipse outpput format
%**************************************************************************
% EXAMPLES USAGE:
% simply type
%
% mser_detector_one
%
% and follow questions.
%........................................................................
% example to process whole image
% ------------------------------------------------------------------
%     Maximally Stable Extremal Regions (MSER) Detection      
% ------------------------------------------------------------------
%                                                                   
% Enter the full filename of the input image: C:\ely\TNO\saliency\data\other\newt_p11_1.jpg
% Display image? [y/n]: y
% Automatically generate the feature filename? [y/n]: y
% Default ellipse scale (1)? [y/n]: y
% Verbose mode? [y/n]: y
% ------------------------------------------------------------------
%                                                                   
% Total elapsed time:  0.203
%                                                                   
% ------------------------------------------------------------------
% Visualise the extracted regions? [y/n]: y
% Display all regions? [y/n]: y
% Scale the ellipses? [y/n]: n
% Thick line? [y/n]: n
% Show region numbers? [y/n]: n
% Different colour for each region? [y/n]: n
% --------------- The End ---------------------------------
% 
%**************************************************************************
clc; 
disp('------------------------------------------------------------------');
disp('    Maximally Stable Extremal Regions (MSER) Detection      ');
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

sav_fnames = input('Automatically generate the feature filename? [y/n]: ','s');
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

% ellipse scale
el = input('Default ellipse scale (1)? [y/n]: ','s');
if lower(el)=='y'
    ellipse_scale = 1;
else
    ellipse_scale = input('Enter the ellipse scale: ');
end

% output file type
%oft = input('Default output file type (2= ellipse)? [y/n]: ','s');
%if lower(oft)=='y'
    output_file_type = 2;
%else
%    output_file_type = input('Enter the output file type (0= RLE, 1= ExtBound, 3=GF, 4=Aff): ');
%end

% verbose flag
verb = input('Verbose mode? [y/n]: ','s');
if lower(verb)=='y'
    verbose = 1;
else
    verbose = 0;
end

disp('------------------------------------------------------------------');
disp('                                                                  ');

% Saliency detector
mser(image_fname, features_fname, ellipse_scale, ...
               output_file_type, verbose)
                                         
disp('                                                                  ');
disp('------------------------------------------------------------------');
    
% display the regions
vis = input('Visualise the extracted regions? [y/n]: ','s');
if lower(vis)=='y'
    vis_flag = 1;
else
    vis_flag = 0;
    disp('--------------- The End ---------------------------------');
    return
end

if vis_flag
   
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
   
    col_label = [];

    addpath('..\MSSR');
    display_features(image_fname, features_fname, [],[],0, ...
        list_regions, scaling, labels, col_ellipse, line_width, col_label, 0);
end
    title('MSER');
    disp('--------------- The End ---------------------------------');


