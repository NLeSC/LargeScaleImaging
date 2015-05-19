% roi_selection_many.m- script for Region Of Interest selection on many images
%**************************************************************************
%
% author: Elena Ranguelova, TNO
% date created: 14 Mar 08
% last modification date: 
% modification details: 
%**************************************************************************
% NOTES: ROI selection for 1 image is part of mssr_detection_one
%        See roipoly for help- WARNING- tends to be slow!!!
%**************************************************************************
% EXAMPLES USAGE:
% simply type
%
% roi_selection_many
%
% and follow questions.
%

%**************************************************************************
clc; 
disp('------------------------------------------------------------------');
disp('    Region Of Interest (ROI) Selection      ');
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

% ROI directories

    roi_dir = input('Enter the full path to the ROI directory: ','s');
    roi_only_dir = input('Enter the full path to the image ROI only directory: ','s');
    
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


% run for many images
for i = indicies
    base_fname = fnames{i};
        image_fname = [input_dir base_fname];
        k = find(base_fname =='.');
        l = k(end);
        if isempty(l)
            ROI_mask_fname = [roi_dir base_fname '.mat'];
            image_roi_fname = [];
        else
            ROI_mask_fname = [roi_dir base_fname(1:l-1) '.mat'];
            image_roi_fname = [roi_only_dir base_fname(1:l-1) '_roi' base_fname(l:end)];
        end


            disp([' Processing image index # ' num2str(i) ' out of total ' num2str(length(indicies)) ' images...']);

        % ROI selection
        I_or = imread(image_fname);
        figure; imshow(I_or); title(image_fname, 'Interpreter','none');
        xlabel('Select interactively the Region Of Interest (ROI)');
        ROI = roipoly;
        save(ROI_mask_fname,'ROI');
        if ~isempty(image_roi_fname)
            if ndims(I_or)==2
                I_roi = I_or;
                I_roi(ROI==0)=0;
            else
                R_roi = I_or(:,:,1);
                G_roi = I_or(:,:,2);
                B_roi = I_or(:,:,3);
                R_roi(ROI==0)=0;
                G_roi(ROI==0)=0;
                B_roi(ROI==0)=0;
                I_roi(:,:,1) = R_roi;
                I_roi(:,:,2) = G_roi;                
                I_roi(:,:,3) = B_roi;                              
            end
            
            figure;imshow(I_roi); title('The image ROI only');pause(0.5);
%            disp('Pause- press any key to continue...');pause;
            imwrite(I_roi,image_roi_fname);
            disp('The ROI binary mask and the image ROI were saved!');
        else
            disp('Only the ROI binary mask was saved!');
        end


    disp('------------------------------------------------------------------');


        % clear up some memory
        clear I_or ROI I_roi
        close all
        
end
    
    disp('--------------- The End ---------------------------------');


