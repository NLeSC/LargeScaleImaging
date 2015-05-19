% mssr_detector_many.m- script for applying MSSR detector on many images
%**************************************************************************
%
% author: Elena Ranguelova, TNO
% date created: 12 Mar 08
% last modification date: 13 Mar 08
% modification details: can process specified list of indexes
%**************************************************************************
% NOTES: if masked image is to be processed use the mask from separate
% file!!
%**************************************************************************
% EXAMPLES USAGE:
% simply type
%
% mssr_detector_many
%
% and follow questions.
%
% example- process entire images- only holes and islands: 
%------------------------------------------------------------------
%    Morphology-based Stable Salient Regions (MSSR) Detection      
%------------------------------------------------------------------
%                                                                  
% Enter the full path to the input image directory: V:\WIR\Video_processing\projects\saliency\data\other\PNG\
% Process entire images (I) or a Regions Of Interest (ROI)? [I/R]: i
% Enter the full path to the output features directory: V:\WIR\Video_processing\projects\saliency\results\other\MSSR\
% Default saliency types [holes-Yes islands-Yes indent.-Yes protr.-Yes]? Y/N: n
% Holes (Isolated dark on bright BG)? Y/N: y
% Islands (Isolated bright on dark BG)? Y/N: y
% Indentations (Border dark on bright BG)? Y/N: n
% Protrusions (Border bright on dark BG)? Y/N: n
%..........................................................................
%
% example- process Regions Of Interest (preselected from the images): 

%**************************************************************************
clc; 
disp('------------------------------------------------------------------');
disp('    Morphology-based Stable Salient Regions (MSSR) Detection      ');
disp('------------------------------------------------------------------');
disp('                                                                  ');

% input image directory
input_dir = input('Enter the full path to the input image directory: ','s');

fnames_struct = dir([input_dir '*.png']);

if isempty(fnames_struct)
    fnames_struct = dir([input_dir '*.pgm']);    
end
if isempty(fnames_struct)
    fnames_struct = dir([input_dir '*.ppm']);    
end
if isempty(fnames_struct)
    disp('The input directory must contain images in one of these formats: PNG/PPM/PGM!');    
    return;
else
    num_images = length(fnames_struct);
end

for i = 1:num_images
    fnames{i} = fnames_struct(i).name; 
end

% ROI masks?
roi = input('Process entire images (I) or a Regions Of Interest (ROI)? [I/R]: ','s');

if lower(roi) =='r'
    roi_dir = input('Enter the full path to the input ROI directory: ','s');
    
    roi_fnames_struct = dir([roi_dir '*.mat']);
    if isempty(roi_fnames_struct)
        disp('The ROI directory must contain masks in MAT format!');    
        return;
    elseif num_images ~= length(roi_fnames_struct)
        disp('The number of masks should match the number of images!');    
        return;
    end

    for i = 1:num_images
        roi_fnames{i} = roi_fnames_struct(i).name;
    end
else
    roi_dir = [];
    for i = 1:num_images
        roi_fnames{i} = [];
    end
end

% all images?
all = input(['Process all ' num2str(num_images) ' input images [y/n]?: '],'s');
if strcmpi(all,'n')
    ind = input('Specify part (P) of images with beginning and end indicies or list (L) [P/L]?: ','s');
    if strcmpi(ind,'p')
        ind_beg = input('Enter the beginning image number: ');  
        ind_end = input('Enter the ending image number: ');
        indicies = ind_beg:ind_end;
    else
        indicies = input('Enter the list of image indicies: ');
    end
else
    indicies = 1:num_images;
end


% output (feature) directory
features_dir = input('Enter the full path to the output features directory: ','s');


%--------------------------------------------------------------------------
% parameters setting

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
execution_flags = [0 0 0];


% run for many images
for i = indicies
    base_fname = fnames{i};
        image_fname = [input_dir base_fname];
        ROI_mask_fname = [roi_dir roi_fnames{i}];
        k = find(base_fname =='.');
        l = k(end);
        if isempty(ROI_mask_fname)
            if isempty(l)
                features_fname = [features_dir base_fname '.mssr'];
                regions_fname = [features_dir base_fname '_regions.mat'];    
            else
                features_fname = [features_dir base_fname(1:l-1) '.mssr'];
                regions_fname = [features_dir base_fname(1:l-1) '_regions.mat'];    
            end
        else
            if isempty(l)
                features_fname = [features_dir base_fname '_roi.mssr'];
                regions_fname = [features_dir base_fname '_roi_regions.mat'];    
            else
                features_fname = [features_dir base_fname(1:l-1) '_roi.mssr'];
                regions_fname = [features_dir base_fname(1:l-1) '_roi_regions.mat'];    
            end
        end

            disp([' Processing image index # ' num2str(i) ' out of total ' num2str(length(indicies)) ' images...']);



        % Saliency detector
        [num_regions, features, saliency_masks] = mssr(image_fname, ...
                                    ROI_mask_fname, saliency_type, execution_flags);

    disp('------------------------------------------------------------------');


        mssr_save(features_fname, regions_fname, num_regions, features, saliency_masks);

        % clear up some memory
        clear num_regions features saliency_masks
        
end
    
    disp('--------------- The End ---------------------------------');


