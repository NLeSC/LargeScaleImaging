% test_dilate_components_LMwood.m- testing sucessive dilation of filtered DMSR regions on LMwood data
%**************************************************************************
%
% author: Elena Ranguelova, NLeSc
% date created: 8 April 2016
% last modification date: 11 April 2016
% modification details: the features are normalized by the max number of
% CCs (that is the original number before the successive dilations);
% added; saving of all features added
%% header message
disp('Testing successive dilation and counting number of connected componentson filtered DMSR regions of LMwood data');

%% execution parameters
verbose = 1;
visualize = 1;
visualize_dil = 1;
saving = 1;
batch = true;

%% algorithm parameters
if visualize
    figure_string{1} ='large and roundish';
    figure_string{2} ='small';
    figure_string{3} ='small elliptical - vertical';
    figure_string{4} ='small roundish - horizontal';
end

filtering_cond_string{1} = 'AREA in_0.2_1_AND_S in_0.85_1'; % large and roundish
filtering_cond_string{2} = 'AREA in_0_0.199_AND_S in_0.85_1'; % small
filtering_cond_string{3} = 'ORI in_-90_-55_Or_ORI in_55_90_AND_ECC in_0.75_1_AND_AREA in_0_0.2';% small elliptical- vertical
filtering_cond_string{4} = 'ECC in_0_0.85_AND_SOL in_0.85_1_AND_AREA in_0_0.199'; %  small roundish - horizontal
num_iter = 9;
SE_size_base = 5;

%% paths
data_path = '/home/elena/eStep/LargeScaleImaging/Data/Scientific/WoodAnatomy/LM pictures wood/PNG';
results_path ='/home/elena/eStep/LargeScaleImaging/Results/Scientific/WoodAnatomy/LM pictures wood';
detector  = 'DMSR';

%% test cases
if batch
    test_cases = {'Argania' ,'Brazzeia_c', 'Brazzeia_s', 'Chrys', 'Citronella',...
        'Desmo', 'Gluema', 'Rhaptop', 'Stem'};
else
    test_cases = {'Desmo'};
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

    %% process the images
    for i = 1: num_images
        
        %% initializations
        features = zeros(4, num_iter + 1);
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
        
       
        %% visualize
        if visualize
            ff = figure('units','normalized','outerposition',[0 0 1 1]);
        end
        %% filenames
        image_filename = char(image_filenames{i});
        regions_props_filename = char(regions_props_filenames{i});
        filtered_regions_filename_base = char(filtered_regions_filenames_base{i});
        [filt_pathstr,filt_base_name,filt_ext] = fileparts(filtered_regions_filename_base);
                
        %% process each subset of filtered regions
        for j = 1:4
            filt_name = [filt_base_name '_' char(filtering_cond_string{j}) filt_ext];
            filtered_regions_filename = fullfile(filt_pathstr,filt_name);
            %% loading regions
            load(filtered_regions_filename);
            bw = bw_filt;
            clear bw_filt
            cc = bwconncomp(bw);
            
            %% algorithm parameters depending ont he regions
            if j > 1
                %% algorithm parameters
                res = 100/micro_res;
                SE_size = round(SE_size_base * res);
            else
                props = regionprops(cc,'EquivDiameter');
                allED = [props.EquivDiameter];
                meanED = mean(allED);
                SE_size = fix(meanED/4);
            end
            features(j,1) = cc.NumObjects;
            
            %% visualize
            if visualize_dil
                f = figure;imshow(bw);title([test_case]);
                xlabel(['original filtered binary image']);
                pause(0.1);
            end
            %% successive dilations
            for k = 1: num_iter
                [num_cc, bw_dil] = dilate_components(bw, SE_size);
                %% visualize
                if visualize_dil
                    figure(f);imshow(bw_dil);title([test_case]);
                    xlabel(['dilated binary image at iteration ' num2str(k)]);
                    pause(0.1);
                end
                %% features
                features(j,k+1) = num_cc;
                bw= bw_dil;
                clear bw_dil
            end
            
            %% normalization
            features(j,:) = features(j,:) ./ features(j,1);
            
            %% visualization
            if visualize
                figure(ff);
                plot(features(j,:), '-*','LineWidth', 1);
                hold on; grid on;
            end
            
            if verbose
                disp('----------------------------------------------------------');
            end
            if verbose
                
                disp('***************************************************************');
            end
            
        end
        
        if visualize
            figure(ff);
            title([test_case num2str(i)], 'Interpreter', 'none');
            xlabel('# successive dilations');
            ylabel(' Normalised # CC ');
            legend(char(figure_string));
        end
        %% saving
        if saving
            if verbose
                disp('Saving computed features...');
            end
            save(regions_props_filename, 'features', '-append');
        end
    end
end
if verbose
    disp('DONE.');
end