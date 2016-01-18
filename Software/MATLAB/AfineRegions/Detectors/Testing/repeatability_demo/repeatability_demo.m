function repeatability_demo

det_suffix=upper({'mser','mssr', 'mssra','dmsr', 'dmsra'});
num_detectors = length(det_suffix);
batch_structural = true;
lisa = false;

% figure parameters
small_dim_r = 4;
small_dim_c = 6;
off = 0.1; off_s = 0.05;
w = 0.4; h = 0.6;

% transformations_axis = [20 30 40 50 60];
% transformations_fig= {'scale: rotation + zoom','blur',...
%     'viewpoint','lighting'};

transformations_fig= {'viewpoint' , 'scale: rotation + zoom', 'blur', 'ligthing'};
transformations_axis = {[20 30 40 50 60], [1.1 1.3 1.9 2.3 2.8],...
    [2 3 4 5 6], [2 3 4 5 6]};

common_part = 1;
verbose = false;
oe =4; % overlap error x 10[%]
%% image filename
if ispc
    starting_path = fullfile('C:','Projects');
elseif lisa
    starting_path = fullfile(filesep, 'home','elenar');
else
    starting_path = fullfile(filesep,'home','elena');
end
project_path = fullfile(starting_path, 'eStep','LargeScaleImaging');
data_path = fullfile(project_path, 'Data', 'AffineRegions');
results_path = fullfile(project_path, 'Results', 'AffineRegions');
%test_case = input('Enter the test case : [bark|bikes|boat|graffiti|leuven|trees|ubc|wall]: ','s');
if batch_structural
    test_cases = {'graffiti','boat', 'bikes', 'leuven'};
else
    test_cases = {'graffiti'};
end

j = 0;
for test_case_cell = test_cases
    j = j+ 1;
    test_case = char(test_case_cell);
    disp(test_case);
    feature_filename = fullfile(results_path,test_case,test_case);
    image_filename = fullfile(data_path,test_case,'img');
    %% repeatabiliy figures
    
    mark=['-ks';'-bv'; '-gv';'-rp'; '-mp'];
    %mark=['-ks';'-bv'; '-rp'];
    % reference image filename
    imf1=[image_filename '1.ppm'];
    im1 = imread(imf1);
    trans_fig = char(transformations_fig{j});
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
    Xaxis = transformations_axis{j};
    
    %% for all detectors
    for d=1:num_detectors
        seqrepeat=[];
        seqcorresp=[];
        % reference feature filename
        file1=sprintf('%s1.%s',feature_filename,det_suffix{d});
        for i=2:6
            
            file2=sprintf( '%s%d.%s',feature_filename, i,det_suffix{d});
            Hom=fullfile(data_path, test_case, sprintf('H1to%dp',i));
            imf2=sprintf('%s%d.ppm',image_filename,i);
            im2 = imread(imf2);
            
            subplot(small_dim_r, small_dim_c, i);
            image(im2);
            if i==2
                title(trans_fig ,'Interpreter','none');
            end
            xlabel(['transf. magnitude: ' num2str(Xaxis(i-1))]);
            ax = gca; set(ax, 'Xtick', [], 'YTick',[]);
            [~,repeat,corresp, ~,~, ~]= ...
                repeatability(file1,file2,Hom,imf1,imf2, common_part, verbose);
            seqrepeat=[seqrepeat repeat(4)];
            seqcorresp=[seqcorresp corresp(4)];
        end
        subplot(s1); ax = gca; plot(Xaxis,seqrepeat,mark(d,:)); set(ax, 'XTick', Xaxis);
        subplot(s2); ax = gca; plot(Xaxis,seqcorresp,mark(d,:)); set(ax, 'XTick', Xaxis);
        
    end
    subplot(s1);legend(det_suffix, 'Best');
    subplot(s2);legend(det_suffix, 'Best');
    pause(2);
    
    
    disp('--------------------------------');
end
