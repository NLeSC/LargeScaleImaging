function repeatability_demo_combined

%% parameters
base_name = '_original';
detectors={'mser','mssr', 'mssra','dmsr', 'dmsra'};
num_detectors = length(detectors);

batch_structural = true;
batch = 3;
lisa = false;
transformations = {'viewpoint' , 'scale', 'blur', 'ligthing'};
transformations_fig= {'viewpoint' , 'scale: rotation + zoom', 'blur', 'ligthing'};
transformations_axis = {[20 30 40 50 60], [1.1 1.3 1.9 2.3 2.8],...
    [2 3 4 5 6], [2 3 4 5 6]};
all_trans = true;
num_transformations = {5, 5, 5, 5};

% figure parameters
small_dim_r = 4;
small_dim_c = 6;
off = 0.1; off_s = 0.05;
w = 0.4; h = 0.6;


common_part = 1;
oe =4; % overlap error x 10[%]

%% paths
if ispc    
    starting_path = fullfile('C:','Projects');
elseif lisa
    starting_path = fullfile(filesep, 'home','elenar');
else
    starting_path = fullfile(filesep,'home','elena');
end
project_path = fullfile(starting_path, 'eStep','LargeScaleImaging');
data_path = fullfile(project_path, 'Data', 'CombinedGenerated');
results_path = fullfile(project_path, 'Results', 'CombinedGenerated');
transformations_path = fullfile(data_path, 'homographies');

if batch_structural
    switch batch
        case 1
            test_cases = {'01_graffiti',...
                '02_freiburg_center',...
                '03_freiburg_from_munster_crop'};
        case 2
            test_cases = {'04_freiburg_innenstadt',...
                '05_cool_car',...
                '06_freiburg_munster'};
        case 3
            test_cases = {'07_graffiti',...
                '08_hall',...
                '09_small_palace'};
            
    end
else
    test_cases = {'01_graffiti'};
end

if not(all_trans)
%      transformations = {'zoom'}   
%      num_transformations = {5};
%      transformations = {'rotation'};   
%      num_transformations = {5};
%      transformations = {'lighting'};   
%      num_transformations = {5};
     transformations = {'blur'};   
     num_transformations = {5};     
end

%% for test case
for test_case_cell = test_cases
    test_case = char(test_case_cell);
    disp('Test case: ');disp(test_case);
    data_path_full = fullfile(data_path, test_case);
    results_path_full = fullfile(results_path, test_case);
    
    % reference image filename
    imf1 = fullfile(data_path_full, strcat(base_name, '.ppm'));
    im1 = imread(imf1);
    
    
    %% for all transformations
    for trans_index = 1: length(transformations)
        trans = transformations{trans_index};
        trans_fig = transformations_fig{trans_index};
        
        %% repeatability figure
        f = figure; 
        figure(f);clf;
        set(gcf, 'Position', get(0,'Screensize'));
        subplot(small_dim_r, small_dim_c, 1);
        image(im1); title(test_case,'Interpreter','none');
        xlabel('Reference image');
        ax = gca; set(ax, 'Xtick', [], 'YTick',[]);
        hold on;
        
        s1 = subplot('Position',[off off w h]);
        grid on;
        title('Performance');
        ylabel('repeatability %')
        xlabel('transformation magnitude');
        
        hold on;
      
        s2 = subplot('Position',[off+off_s+w off w h]);
        grid on;
        title('Regions count');
        ylabel('nb of correspondencies')
        xlabel('transformation magnitude');
        
        hold on;
        
        mark=['-ks';'-bv'; '-gv';'-rp'; '-mp'];
       Xaxis = transformations_axis{trans_index};
        
        
        %% for all detectors
        for d=1:num_detectors
            seqrepeat=[];
            seqcorresp=[];
            detector = char(detectors(d));
            % reference feature filename
            file1 = fullfile(results_path_full, strcat(base_name, '.', lower(detector)));
            %% for all levels of the transformation
            for i = 1: num_transformations{trans_index}
                Hom = fullfile(transformations_path,strcat(trans, num2str(i), '.mat'));
                imf2 = fullfile(data_path_full,  strcat(trans, num2str(i), '.ppm'));
                im2 = imread(imf2);
                subplot(small_dim_r, small_dim_c, i+1);
                image(im2); 
                if i==1
                    title(trans_fig ,'Interpreter','none');
                end
                xlabel(['transf. magnitude: ' num2str(Xaxis(i))]);
                ax = gca; set(ax, 'Xtick', [], 'YTick',[]);
                file2= fullfile(results_path_full, strcat(trans, num2str(i), '.', lower(detector)));
                [~,repeat,corresp, ~,~, ~]=repeatability(file1,file2,Hom,imf1,imf2, common_part);
                seqrepeat=[seqrepeat repeat(oe)]; %4
                seqcorresp=[seqcorresp corresp(oe)]; %4
            end
            subplot(s1); ax = gca; plot(Xaxis,seqrepeat,mark(d,:)); set(ax, 'XTick', Xaxis);
            subplot(s2); ax = gca; plot(Xaxis,seqcorresp,mark(d,:)); set(ax, 'XTick', Xaxis);
        end
        subplot(s1);legend(detectors, 'Best'); 
        subplot(s2);legend(detectors, 'Best');
        pause(2);
    end
end

%% closing up
if batch_structural
    close all
end
disp('--------------------------------');

