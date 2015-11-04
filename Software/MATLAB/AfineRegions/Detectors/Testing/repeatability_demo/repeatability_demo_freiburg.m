function repeatability_demo_freiburg

base_name = '_original';
detectors={'mser','mssr', 'mssra','dmsr', 'dmsra'};
num_detectors = length(detectors);

batch_structural = true;
batch = 3;
lisa = false;
transformations = {'blur','lighting','rotation','zoom'};
transformations_axis = {[2 5 10 20], [0.9 0.8 0.7 0.6],...
    [5 15 45],[1.2 1.4 1.7 2.1 2.6 3]};
all_trans = true;
num_transformations = {4, 4, 3, 6};
total_transformations =length(num_transformations);

%% paths
if ispc
    starting_path = fullfile('C:','Projects');
elseif lisa
    starting_path = fullfile(filesep, 'home','elenar');
else
    starting_path = fullfile(filesep,'home','elena');
end
project_path = fullfile(starting_path, 'eStep','LargeScaleImaging');
data_path = fullfile(project_path, 'Data', 'Freiburg');
results_path = fullfile(project_path, 'Results', 'Freiburg');
transformations_path = fullfile(data_path, 'transformations');

if batch_structural
    switch batch
        case 1
            test_cases = {'01_graffiti',...
                '03_freiburg_center',...
                '04_freiburg_from_munster_crop'};
        case 2
            test_cases = {'05_freiburg_innenstadt',...
                '09_cool_car',...
                '17_freiburg_munster'};
        case 3
            test_cases = {'18_graffiti',...
                '20_hall2',...
                '22_small_palace'};
            
    end
else
    test_cases = {'05_freiburg_innenstadt'};
end

if not(all_trans)
    % transformations = {'lighting'};
    trans_index = 2;
end

%% for test case
for test_case_cell = test_cases
    test_case = char(test_case_cell);
    disp('Test case: ');disp(test_case);
    data_path_full = fullfile(data_path, test_case);
    results_path_full = fullfile(results_path, test_case);
    
    % reference image filename
    imf1 = fullfile(data_path_full, strcat(base_name, '.ppm'));
    
    
    %% for all transformations
    for trans_index = 1: total_transformations
        trans = transformations{trans_index};
        
        %% repeatability figures
        f1 = figure; f2 =  figure;
        figure(f1);clf;
        grid on;
        ylabel('repeatability %')
        xlabel('transformation magnitude');
        title(strcat(test_case, ': ', trans),'Interpreter','none');
        hold on;
        figure(f2);clf;
        grid on;
        ylabel('nb of correspondences')
        xlabel('transformation magnitude');
        title(strcat(test_case, ': ', trans),'Interpreter','none');
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
                Hom = fullfile(transformations_path,strcat('H',trans, num2str(i), '.mat'));
                imf2 = fullfile(data_path_full,  strcat(trans, num2str(i), '.ppm'));
                file2= fullfile(results_path_full, strcat(trans, num2str(i), '.', lower(detector)));
                [~,repeat,corresp, ~,~, ~]=repeatability(file1,file2,Hom,imf1,imf2, 1);
                seqrepeat=[seqrepeat repeat(6)]; %4
                seqcorresp=[seqcorresp corresp(6)]; %4
            end
            figure(f1);  plot(Xaxis,seqrepeat,mark(d,:));
            figure(f2);  plot(Xaxis,seqcorresp,mark(d,:));
        end
        figure(f1);legend(detectors);
        figure(f2);legend(detectors);
        pause(1);
    end
end

if batch_structural
    close all
end
disp('--------------------------------');

