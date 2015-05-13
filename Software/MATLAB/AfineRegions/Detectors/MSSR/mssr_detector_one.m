% mssr_detector_one.m- script for applying MSSR detector on 1 image
%**************************************************************************
%
% author: Elena Ranguelova, TNO
% date created: 3 Mar 08
% last modification date: 17 Feb 10
% modification details: added saving and opening and displaying the
%                       features as ellipses
%                       made it less verbose ;-)
%**************************************************************************
% NOTES: if masked image is to be processed use the mask from separate file!!
%**************************************************************************
% EXAMPLES USAGE:
% simply type
%
% mssr_detector_one
%
% and follow questions.
% Below is example of how to process a ROI in an image, show the detection
% process, save the features and display them as ellipses depending on the
% saliency type.
% ------------------------------------------------------------------
%     Morphology-based Stable Salient Regions (MSSR) Detection      
% ------------------------------------------------------------------
%                                                                   
% Enter the full filename of the input image: V:\WIR\Video_processing\projects\saliency\mssr_demo\test_images\tails\na3683_2_tail_image.jpg
% Display image? [y/n]: y
% Process the Image (I) or a Region Of Interest (ROI)? [I/R]: r
% Does the ROI binary mask already exist in a .mat file? [y/n]: y
% Enter the full filename for the ROI mask file: V:\WIR\Video_processing\projects\saliency\mssr_demo\test_images\tails\na3683_2_tail.mat
% Default saliency types [holes-Yes islands-Yes indent.-Yes protr.-Yes]? Y/N: y
% Verbose mode? [y/n]: y
% Vusualise major detection steps? [y/n]: y
% Vusualise minor detection steps? [y/n]: n
% ------------------------------------------------------------------
%                                                                   
% Preprocessing...
% -----Here program's messages-------------------
%                                                                   
% ------------------------------------------------------------------
% Save the extracted regions (for viewing/ processing)? [y/n]: y
% Automatically generate results filenames? [y/n]: y
% Visualise the extracted regions? [y/n]: y
% Distinguish regions saliency type (hole/island/indentaion/protrusion)? [y/n]: y
% Display all regions? [y/n]: y
% Scale the ellipses? [y/n]: y
% Enter the scaling factor: 2
% Thick line? [y/n]: y
% Enter line thickness: 
% Show region numbers? [y/n]: n
% Show original region outlines? [y/n]: n
% --------------- The End ---------------------------------
%
%..........................................................................
% example of processing only interactively selected ROI from an image and
% finding only some types of saleint regions
%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% NOTE: manual selection of ROI using roipoly is very slow!!
%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++    
% ------------------------------------------------------------------
%     Morphology-based Stable Salient Regions (MSSR) Detection      
% ------------------------------------------------------------------
%                                                                   
% Enter the full filename of the input image: V:\WIR\Video_processing\projects\saliency\mssr_demo\test_images\other\newt_downscaled.jpg
% Display image? [y/n]: y
% Process the Image (I) or a Region Of Interest (ROI)? [I/R]: r
% Does the ROI binary mask already exist in a .mat file? [y/n]: n
% 
% %-- Use the interactive ROI tool to select only the newt's body here-----
% 
% Enter the full filename for the ROI mask file: V:\WIR\Video_processing\projects\saliency\mssr_demo\test_images\other\newt_downscaled_roi.mat
% Default saliency types [holes-Yes islands-Yes indent.-Yes protr.-Yes]? Y/N: n
% Holes (Isolated dark on bright BG)? Y/N: y
% Islands (Isolated bright on dark BG)? Y/N: n
% Indentations (Border dark on bright BG)? Y/N: y
% Protrusions (Border bright on dark BG)? Y/N: n
% Verbose mode? [y/n]: n
% Vusualise major detection steps? [y/n]: y
% Vusualise minor detection steps? [y/n]: n
% ------------------------------------------------------------------
%                                                                   
% %------processing here---------------------------------------
% 
% ------------------------------------------------------------------
% Save the extracted regions (for viewing/ processing)? [y/n]: y
% Automatically generate results filenames? [y/n]: y
% Visualise the extracted regions? [y/n]: y
% Distinguish regions saliency type (hole/island/indentaion/protrusion)? [y/n]: y
% Display all regions? [y/n]: y
% Scale the ellipses? [y/n]: n
% Thick line? [y/n]: n
% Show region numbers? [y/n]: n
% Show original region outlines? [y/n]: y
% --------------- The End ---------------------------------
%........................................................................
% example to process whole image
% ------------------------------------------------------------------
%     Morphology-based Stable Salient Regions (MSSR) Detection      
% ------------------------------------------------------------------
%                                                                   
% Enter the full filename of the input image: V:\WIR\Video_processing\projects\saliency\mssr_demo\test_images\other\graffiti1.jpg
% Display image? [y/n]: y
% Process the Image (I) or a Region Of Interest (ROI)? [I/R]: i
% Default saliency types [holes-Yes islands-Yes indent.-Yes protr.-Yes]? Y/N: y
% Verbose mode? [y/n]: n
% Vusualise major detection steps? [y/n]: n
% ------------------------------------------------------------------
%                                                                   
%                                                                   
% ------------------------------------------------------------------
% Save the extracted regions (for viewing/ processing)? [y/n]: y
% Automatically generate results filenames? [y/n]: y
% Visualise the extracted regions? [y/n]: y
% Distinguish regions saliency type (hole/island/indentaion/protrusion)? [y/n]: y
% Display all regions? [y/n]: y
% Scale the ellipses? [y/n]: n
% Thick line? [y/n]: n
% Show region numbers? [y/n]: y
% Show original region outlines? [y/n]: n
% --------------- The End ---------------------------------

%**************************************************************************
clc; 
disp('------------------------------------------------------------------');
disp('    Morphology-based Stable Salient Regions (MSSR) Detection      ');
disp('------------------------------------------------------------------');
disp('                                                                  ');

% input image and ROI
image_fname = input('Enter the full filename of the input image: ','s');

I_or = imread(image_fname);

% display
im_disp = input('Display image? [y/n]: ','s');

if lower(im_disp)=='y'
    f1 = figure; imshow(I_or); title(image_fname, 'Interpreter','none');
end

% ROI
roi = input('Process the Image (I) or a Region Of Interest (ROI)? [I/R]: ','s');

if lower(roi)=='r'
    mask = input('Does the ROI binary mask already exist in a .mat file? [y/n]: ', 's');
    if lower(mask) == 'n'
        % invoke the ROI selection utility
        if ~exist('f1','var')
            f1 = figure; imshow(I_or); title(image_fname, 'Interpreter','none');
        else
            figure(f1); 
        end
        xlabel('Select interactively the Region Of Interest (ROI)');
        ROI = roipoly;
    end
    ROI_mask_fname = input('Enter the full filename for the ROI mask file: ','s');
    if lower(mask) =='n'
        save(ROI_mask_fname,'ROI');
    end
else
    ROI_mask_fname = [];
end

% saliency type
holes = 1; islands = 1; indentations = 1; protrusions = 1;

sal = input('Default saliency types [holes-Yes islands-Yes indent.-Yes protr.-Yes]? Y/N: ','s');

if (lower(sal)=='n')
     hol = input('Holes (Isolated dark on bright BG)? Y/N: ','s');
     if (lower(hol) == 'n')
         holes = 0;
     end
     isl = input('Islands (Isolated bright on dark BG)? Y/N: ','s');
     if (lower(isl) == 'n')
         islands = 0;
     end
     ind = input('Indentations (Border dark on bright BG)? Y/N: ','s');
     if (lower(ind) == 'n')
         indentations = 0;
     end
     pro = input('Protrusions (Border bright on dark BG)? Y/N: ','s');
     if (lower(pro) == 'n')
         protrusions = 0;
     end               
 end

saliency_type = [holes islands indentations protrusions];

% execusion flags
verb = input('Verbose mode? [y/n]: ','s');
if lower(verb)=='y'
    verbose = 1;
else
    verbose = 0;
end

vis_maj = input('Vusualise major detection steps? [y/n]: ','s');
if lower(vis_maj)=='y'
    visualise_major = 1;
else
    visualise_major = 0;
end

if visualise_major 
    vis_min = input('Vusualise minor detection steps? [y/n]: ','s');

    if lower(vis_min)=='y'
        visualise_minor = 1;
    else
        visualise_minor = 0;
    end
else
    visualise_minor = 0;
end

execution_flags = [verbose visualise_major visualise_minor];

disp('------------------------------------------------------------------');
disp('                                                                  ');

% Saliency detector
[num_regions, features, saliency_masks] = mssr(image_fname, ...
                            ROI_mask_fname, saliency_type, execution_flags);
      
disp('                                                                  ');
disp('------------------------------------------------------------------');

% saving the results
sav = input('Save the extracted regions (for viewing/ processing)? [y/n]: ','s');
if lower(sav)=='y'
    save_flag = 1;
else
    save_flag = 0;
    disp('--------------- The End ---------------------------------');
    return
end

if save_flag
    sav_fnames = input('Automatically generate results filenames? [y/n]: ','s');
    if lower(sav_fnames)=='y'
        i = find(image_fname =='.');
        j = i(end);
        if isempty(ROI_mask_fname)
            if isempty(j)
                features_fname = [image_fname '.mssr'];    
                regions_fname = [image_fname '_regions.mat'];    
            else
                features_fname = [image_fname(1:j-1) '.mssr'];
                regions_fname = [image_fname(1:j-1) '_regions.mat'];    
            end
        else
            if isempty(j)
                features_fname = [image_fname '_roi.mssr'];    
                regions_fname = [image_fname '_roi_regions.mat'];    
            else
                features_fname = [image_fname(1:j-1) '_roi.mssr'];
                regions_fname = [image_fname(1:j-1) '_roi_regions.mat'];    
            end
            
        end
    else
        features_fname = input('Enter the full filename for the features (ellipse representation): ','s');
        regions_fname = input('Enter the full filename for the features (regions masks): ','s');
    end
    
    mssr_save(features_fname, regions_fname, num_regions, features, saliency_masks);
end
    
% display the saved regions
vis = input('Visualise the extracted regions? [y/n]: ','s');
if lower(vis)=='y'
    vis_flag = 1;
else
    vis_flag = 0;
    disp('--------------- The End ---------------------------------');
    return
end

if vis_flag
    typ = input('Distinguish regions saliency type (hole/island/indentaion/protrusion)? [y/n]: ','s');
    if lower(typ)=='y'
        type = 1;
    else
        type = 0;
    end
    
    % open the saved regions
    [num_regions, features, saliency_masks] = mssr_open(features_fname, regions_fname, type);
    
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
    
    if ~type
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
    else 
           col_ellipse = [];
    end
   
    col_label = [];
    
    or = input('Show original region outlines? [y/n]: ','s');
    if lower(or)=='y'
        original = 1;
    else
        original = 0;
    end
    
    display_features(image_fname, features_fname, ROI_mask_fname, ...
                  regions_fname,...  
                  type, list_regions, scaling, labels, col_ellipse, ...
                  line_width, col_label, original);
  title('MSSR');
end

    disp('--------------- The End ---------------------------------');

