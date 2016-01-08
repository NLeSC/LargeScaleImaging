% plot the results of the combined repeatability experiments as 3D surface plots

%% parameters
results_matfile = 'results_3det_combined_dataset.mat';

num_det = 3;
num_trans_deg = 5;

detectors={'mser','mssr', 'dmsr'};
%transformations = {'viewpoint' , 'scale: rotation + zoom', 'blur', 'ligthing'};
%transf_ind = 1:5;
transformations = {'viewpoint' , 'blur', 'ligthing'};
% test_cases = {'01 graffiti',...
%                 %'02 freiburg center',...
%                 '03 freiburg from munster crop',...
%                 %'04 freiburg innenstadt',...
%                 %'05 cool car',...
%                 %'06 freiburg munster',...
%                 '07 graffiti',...
%                 '08 hall',...
%                 '09 small palace'};
% test_cases_ind = 1:9;
transf_ind = [1 3 4]; 
test_cases = {'01 graffiti',...
                '03 freiburg from munster crop',...
                '07 graffiti',...
                '08 hall',...
                '09 small palace'};
test_cases_ind = [1 3 7 8 9];

            
num_data = length(test_cases);
num_trans = length(transformations);        
transformations_axis = {[20 30 40 50 60], [1.1 1.3 1.9 2.3 2.8],...
    [2 3 4 5 6], [2 3 4 5 6]};           
color_black = [0 0 0];
color_blue = [0 0 1];
color_red = [1 0 0];

%% initialize
repeat = zeros(num_det, num_data, num_trans, num_trans_deg);
ncorr = zeros(num_det, num_data, num_trans, num_trans_deg);

%% load the data
load(results_matfile);

% transfer data from results structure to the arrays

for ndt = 1:num_det
    i = 0; 
    for nd = test_cases_ind
        i = i+1;
        j = 0;
        for nt = transf_ind       
            j = j+1;
            repeat(ndt,i,j,:) = results(ndt, nd, nt).repeatability;
            ncorr(ndt,i,j,:) = results(ndt, nd, nt).numcorr;
        end
    end
end

%% clear
clear results

%% make the plots per detector and per transformation 

xd=linspace(1,num_trans_deg,num_trans_deg);
yd=linspace(1, num_data,num_data);
[x,y]=meshgrid(xd,yd);
for nt = 1:num_trans
    trans = char(transformations(nt));
    Xaxis = transformations_axis{nt};
    f1=figure; set(gcf, 'Position', get(0,'Screensize'));
    f2 = figure; set(gcf, 'Position', get(0,'Screensize'));
    for ndt = 1:num_det
        detector = char(detectors(ndt));
        rep = squeeze(repeat(ndt, :, nt,:));
        switch ndt
            case 1
                C = color_black;
                marker = 's';
            case 2
                C = color_blue;
                marker = 'v';
            case 3
                C = color_red;
                marker = 'p';
        end
        figure(f1); mesh(x,y,rep, 'EdgeColor', C, 'Marker', marker);
        hold on;
        title(trans);zlabel('Repeatability, [%]');
        xlabel(['transf. magnitude ']);
        ax = gca; set(ax,'XTick', [1:num_trans_deg], 'XTickLabel', Xaxis);
        %ylabel(['data sequence ']);
        ax = gca; set(ax,'YTick', [1:num_data], 'YTickLabel', char(test_cases));
        
        nc = squeeze(ncorr(ndt,:,nt,:));
        figure(f2);
        mesh(x,y,nc, 'EdgeColor', C, 'Marker', marker);
        hold on;
        title(trans);
        xlabel(['transf. magnitude ']);
        ax = gca; set(ax,'XTick', [1:num_trans_deg], 'XTickLabel', Xaxis);
       % ylabel(['data sequence ']);
        ax = gca; set(ax,'YTick', [1:num_data], 'YTickLabel', char(test_cases));
        zlabel('Number correspondencies');
        
    end
    
    hold off;
    figure(f1);legend(detectors, 'Best');
    figure(f2);legend(detectors, 'Best');
end
