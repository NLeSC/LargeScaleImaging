function repeatability_demo_tnt

%% parameters
detectors={'mser','dmsr'};
base_name = 'img';
num_detectors = length(detectors);
batch_structural = false;

% figure parameters
small_dim_r = 4;
small_dim_c = 6;
off = 0.1; off_s = 0.05;
w = 0.4; h = 0.6;

transformations_fig= {'viewpoint + illumination' , ...
    'viewpoint + zoom', 'viewpoint', ...
    'viewpoint + zoom','viewpoint + zoom'};
resolutions = {'1536x1024' ,'2048x1365','3072x2048','3456x2304'};
transformations_axis = [20 30 40 50 60];

common_part = 1;
oe =4; % overlap error x 10[%]
%% paths and filenames
if ispc
    starting_path = fullfile('C:','Projects');
else
    starting_path = fullfile(filesep,'home','elena');
end
project_path = fullfile(starting_path, 'eStep','LargeScaleImaging');
data_path = fullfile(project_path, 'Data', 'TNT');
results_path = fullfile(project_path, 'Results', 'TNT');

if batch_structural
    test_cases = {'colors','grace','posters', 'there','underground'};
else
    test_cases = {'colors'};
end

%% for the test case
case_index = 0;
for test_case_cell = test_cases
    
    case_index = case_index + 1;
    test_case = char(test_case_cell);
    disp('Test case: ');disp(test_case);
    

    % for the resolution
    for res_cell = resolutions
        res  = char(res_cell);
        disp('Resolution: ');disp(res);          
        
        data_path_full = fullfile(data_path, test_case, ...
            strcat(test_case,'_',res));
        results_path_full = fullfile(results_path, test_case, ...
            strcat(test_case,'_',res));
        
        image_filename = fullfile(data_path_full, base_name);
        % reference image filename
        imf1=[image_filename '1.ppm'];      
        im1 = imread(imf1);
        %% repeatabiliy figure
        
        f = figure;
        figure(f);clf;
        set(gcf, 'Position', get(0,'Screensize'));
        subplot(small_dim_r, small_dim_c, 1);
        title_string = strcat(test_case, ': ', res);        
        image(im1); title(title_string, 'Interpreter','none');
        xlabel('Reference image');
        ax = gca; set(ax, 'Xtick', [], 'YTick',[]);
        hold on;
        
        s1 = subplot('Position',[off off w h]);
        grid on;
        title('Performance');
        ylabel('repeatability %')
        xlabel('viewpoint angle');
        
        hold on;
        
        s2 = subplot('Position',[off+off_s+w off w h]);
        grid on;
        title('Regions count');
        ylabel('nb of correspondencies')
        xlabel('viewpoint angle');
        
        hold on;
        
        mark=['-ks';'-rp'];
        Xaxis = transformations_axis;
        
        trans_fig = char(transformations_fig{case_index});
        
        %% for all detectors
        for d=1:num_detectors
            seqrepeat=[];
            seqcorresp=[];
            detector = char(detectors(d));
            % reference feature filename
            file1=fullfile(results_path_full, ...
                strcat(base_name, '1.', lower(detector)));
            for i=2:6
                Hom=fullfile(data_path_full, sprintf('H1to%dp',i));
                imf2 = fullfile(data_path_full,  ...
                    strcat(base_name, num2str(i), '.ppm'));
                im2 = imread(imf2);
                subplot(small_dim_r, small_dim_c, i);
                image(im2);
                if i==2
                    title(trans_fig ,'Interpreter','none');
                end
                xlabel(['transf. magnitude: ' num2str(Xaxis(i-1))]);
                ax = gca; set(ax, 'Xtick', [], 'YTick',[]);
                file2= fullfile(results_path_full, ...
                    strcat(base_name, num2str(i), '.', lower(detector)));
                [~,repeat,corresp, ~,~, ~] =  ...
                    repeatability(file1,file2,Hom,imf1,imf2, common_part);
                seqrepeat=[seqrepeat repeat(oe)];
                seqcorresp=[seqcorresp corresp(oe)];
            end
            subplot(s1); ax = gca; plot(Xaxis,seqrepeat,mark(d,:)); 
            set(ax, 'XTick', Xaxis);
            subplot(s2); ax = gca; plot(Xaxis,seqcorresp,mark(d,:));
            set(ax, 'XTick', Xaxis);
            
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

