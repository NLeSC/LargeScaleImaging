% test_mser_LMwood- testing build-in MSER detector on LMwood data
%**************************************************************************
%
% author: Elena Ranguelova, NLeSc
% date created: 29 Sept 2015
% last modification date: 30 Sept 2015
% modification details: adapted to new dataset, displaying only elliptical
% regions

%% header message
disp('Testing MATLAB MSER detector on LMwood data');
%% paths and filenames
data_path = '/home/elena/eStep/LargeScaleImaging/Data/Scientific/WoodAnatomy/LM pictures wood/PNG';
results_path ='/home/elena/eStep/LargeScaleImaging/Results/Scientific/WoodAnatomy/LM pictures wood';

for test_case = {'Argania','Brazzeia_c', 'Brazzeia_s', 'Chrys', 'Citronella',...
        'Desmo', 'Gluema', 'Rhaptop', 'Stem'}
    disp(['Processing species: ' test_case]); 
    switch lower(char(test_case))
        case 'argania'            
            base_fname{1} = 'Argania spinosa1';
            base_fname{2} = 'Argan spinL01';
            base_fname{3} = 'Argan spinL02';
        case 'brazzeia_c'
            base_fname{1} = 'Brazzeia congo01';
            base_fname{2} = 'Brazzeia congo02';
        case 'brazzeia_s'
            base_fname{1} = 'Brazzeia soyaux01';
            base_fname{2} = 'Brazzeia soyaux02';
        case 'chrys'
            base_fname{1} = 'Chrys afrPL01';
            base_fname{2} = 'Chrys afrPL02';
        case 'citronella'
            base_fname{1} = 'Citronella silvatica 01';
            base_fname{2} = 'Citronella silvatica 02';
        case 'desmo'
            base_fname{1} = 'Desmostachys vogelii 01';
            base_fname{2} = 'Desmostachys vogelii 04';
        case 'gluema'
            base_fname{1} = 'Gluema ivor01';
            base_fname{2} = 'Gluema ivor02';
        case 'rhaptop' 
            base_fname{1} = 'Rhaptop beguei01';
            base_fname{2} = 'Rhaptop beguei02';            
        case 'stem'
            base_fname{1} = 'Stemonurus celebicus 01';
            base_fname{2} = 'Stemonurus celebicus 03';
    end
    
    num_images = length(base_fname);
    for i = 1:num_images
        base = char(base_fname{i});
        image_filename = [base '.png'];
        data_filename = fullfile(data_path, image_filename);
        result_filename = fullfile(results_path, [base '.mat']);
        
        %% load
        image_data_orig = imread(data_filename);
        
        if ~ismatrix(image_data_orig)
            image_data_2D = rgb2gray(image_data_orig);
        end
        
        %% extract
        tic
        MSERregions = detectMSERFeatures(image_data_2D);
        toc
        
        %% save
        save(result_filename,'MSERregions');
        
        %% visualize
        f = figure; imshow(image_data_2D); hold on;
        plot(MSERregions);
        title(['MSER elliptical regions for ' num2str(image_filename)]);
        hold off;
        
        %% cleanup
        close(f); clear MSERregions;
    end
    disp('---------------------------------------------------------------');
end