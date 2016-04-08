% test_dilate_components_LMwood.m- testing sucessive dilation of filtered DMSR regions on LMwood data
%**************************************************************************
%
% author: Elena Ranguelova, NLeSc
% date created: 8 April 2016
% last modification date: 
% modification details: 
%% header message
disp('Testing successive dilation and counting number of connected componentson filtered DMSR regions of LMwood data');

%% execution parameters
verbose = 1;
visualize = 1;
saving = 0;
batch = true;

%% algorithm parameters
filtering_cond_string = 'AREA in_0.2_1_AND_S in_0.85_1';
num_iter = 9;
SE_size_base = 10;

%% paths
data_path = '/home/elena/eStep/LargeScaleImaging/Data/Scientific/WoodAnatomy/LM pictures wood/PNG';
results_path ='/home/elena/eStep/LargeScaleImaging/Results/Scientific/WoodAnatomy/LM pictures wood';
detector  = 'DMSR';

%% test cases
if batch
    test_cases = {'Argania' ,'Brazzeia_c', 'Brazzeia_s', 'Chrys', 'Citronella',...
        'Desmo', 'Gluema', 'Rhaptop', 'Stem'};
else
    test_cases = {'Citronella'};
end

%% processing all test cases
for test_case = test_cases
    %% set up resolution and species names
    if verbose
        disp(['Processing species: ' test_case]);
    end
    switch char(test_case) % read it by hand from the image
        case {'Argania','Chrys', 'Gluema'}
            micro_res = 200;
        case {'Brazzeia_c', 'Brazzeia_s', 'Rhaptop','Stem' }
            micro_res = 500;
    end
    [image_filenames, ~, ~, ...
        regions_props_filenames, filtered_regions_filenames_base] = ...
        get_wood_test_filenames(test_case, detector, data_path, results_path);
    
    num_images = length(image_filenames);
    
    %% visualize
    if visualize
        ff = figure('units','normalized','outerposition',[0 0 1 1]);
    end
    %% process the images
    for i = 1: num_images       
        %% specify microscopy resolution (can be 200 or 500 micrometers)
        % for now hard-coded...
        switch char(test_case) % read it by hand from the image
            case {'Citronella', 'Desmo'}
                switch i
                    case 1
                        micro_res = 500;
                    case 2
                        micro_res = 200;
                end
        end
        
       %% filenames
        image_filename = char(image_filenames{i});
      %  regions_props_filename = char(regions_props_filenames{i});        
        filtered_regions_filename_base = char(filtered_regions_filenames_base{i});        
        [filt_pathstr,filt_name,filt_ext] = fileparts(filtered_regions_filename_base);
        filt_name = [filt_name '_' filtering_cond_string filt_ext];
        filtered_regions_filename = fullfile(filt_pathstr,filt_name); 
%         if verbose
%   %          disp('image_filename: '); disp(image_filename);
%   %          disp('regions_props_filename: '); disp(regions_props_filename);
%             disp('filt_name: '); disp(filt_name);
%             disp('filtered_regions_filename: '); disp(filtered_regions_filename);
%         end
%   
        
        %% algorithm parameters
        res = 100/micro_res;
        SE_size = round(SE_size_base * res)
        
        % initializations
        features = zeros(1, num_iter + 1);
        
        % read the file 
        load(filtered_regions_filename);
        bw = bw_filt;
        clear bw_filt
        cc = bwconncomp(bw);
        features(1) = cc.NumObjects;
        
        if visualize
            f = figure;imshow(bw);title('original filtered binary image');
            pause(0.5);
        end
        %% successive dilations
        for j = 1: num_iter    
            [num_cc, bw_dil] = dilate_components(bw, SE_size);
            if visualize
                figure(f);imshow(bw_dil);title(['dilated binary image at iteration ' num2str(j)]);
                pause(0.5);
            end
            features(j+1) = num_cc;
            bw= bw_dil;
            clear bw_dil
        end
            % visualization
            if visualize                
                figure(ff);
                plot(features, '-*','LineWidth', 1);                
                hold on; grid on;
            end
            
            if verbose
                disp('----------------------------------------------------------');
            end
 
        if verbose
            
           disp('***************************************************************');
        end
        if visualize
            figure(ff);
            title(test_case, 'Interpreter', 'none');
            xlabel('# successive dilations');
            ylabel('# CC ');
        end
    end
end
if verbose
   disp('DONE.');
end