function repeatability_demo

base_name = '_original';
detectors={'mser','mssr', 'mssra','dmsr', 'dmsra'};
batch_structural = false;
batch = 1;
lisa = false;
transformations = {'blur','lighting','rotation','zoom'};
all_trans = false;
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
    trans = {'lighting'};
end

for test_case_cell = test_cases
    test_case = char(test_case_cell);
    disp('Test case: ');disp(test_case);
    data_path_full = fullfile(data_path, test_case,'PNG');
    results_path_full = fullfile(results_path, test_case);
    for detector_cell = detectors
        detector = char(detector_cell)
        [~, features_filenames, ~] = ...
            get_filenames_path(detector, data_path_full, results_path_full)
        
        
        for tran = trans
            disp(tran)
            
            
            %         %% repeatability figures
            %         f1 = figure; f2 =  figure;
            %         figure(f1);clf;
            %         grid on;
            %         ylabel('repeatability %')
            %         xlabel('transformation magnitude');
            %         title(test_case);
            %         hold on;
            %         figure(f2);clf;
            %         grid on;
            %         ylabel('nb of correspondences')
            %         xlabel('transformation magnitude');
            %         title(test_case);
            %         hold on;
            %
            %         mark=['-ks';'-bv'; '-gv';'-rp'; '-mp'];
            %         for d=1:num_transfromations + 1
            %             seqrepeat=[];
            %             seqcorresp=[];
            %             for i=2:num_transformations
            %                 file1=sprintf('%s1.%s',feature_filename,det_suffix{d});
            %                 file2=sprintf( '%s%d.%s',feature_filename, i,det_suffix{d});
            %                 Hom=fullfile(data_path, test_case, sprintf('H1to%dp',i));
            %                 imf1=[image_filename '1.ppm'];
            %                 imf2=sprintf('%s%d.ppm',image_filename,i);
            %                 [erro,repeat,corresp, match_score,matches, twi]=repeatability(file1,file2,Hom,imf1,imf2, 1);
            %                 seqrepeat=[seqrepeat repeat(4)];
            %                 seqcorresp=[seqcorresp corresp(4)];
            %             end
            %             figure(f1);  plot([20 30 40 50 60],seqrepeat,mark(d,:));
            %             figure(f2);  plot([20 30 40 50 60],seqcorresp,mark(d,:));
            %         end
        end
        %     figure(f1);legend(det_suffix{1},det_suffix{2},det_suffix{3}, det_suffix{4}, det_suffix{5});
        %     axis([10 70 0 100]);
        %     figure(f2);legend(det_suffix{1},det_suffix{2},det_suffix{3}, det_suffix{4}, det_suffix{5});
        %     pause(1);
    end
    disp('--------------------------------');
end
