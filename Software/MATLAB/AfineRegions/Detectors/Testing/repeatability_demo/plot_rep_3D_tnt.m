% plot the results of the tnt repeatability experiments as 3D surface plots

%% parameters
results_matfile = 'results_2det_tnt_dataset.mat';

num_det = 2;
num_trans_deg = 5;

detectors={'mser', 'dmsr'};
%transformation = {'viewpoint'};
resolutions = {'1.5M' ,'3M','6M','8M'};
res_ind = 1:4;
% test_cases = {'colors',...
%               'grace',...
%               'posters',...
%               'there',...
%               'underground'};
% test_cases_ind = 1:5;
transf_ind = 1; 
test_cases = {'posters',...
              'underground'};
test_cases_ind = [3 5];
            
num_data = length(test_cases);
num_res = length(resolutions);        
transformations_axis = [20 30 40 50 60];           
color_black = [0 0 0];
color_red = [1 0 0];

%% initialize
repeat = zeros(num_det, num_data, num_res, num_trans_deg);
ncorr = zeros(num_det, num_data, num_res, num_trans_deg);

%% load the data
load(results_matfile);

% transfer data from results structure to the arrays

for ndt = 1:num_det
    i = 0; 
    for nd = test_cases_ind
        i = i+1;
        j = 0;
        for nr = res_ind       
            j = j+1;
            repeat(ndt,i,j,:) = results(ndt, nd, nr).repeatability;
            ncorr(ndt,i,j,:) = results(ndt, nd, nr).numcorr;
        end
    end
end

%% clear
clear results

%% make the plots per detector and per transformation 
Xaxis = transformations_axis;

xd=linspace(1,num_trans_deg,num_trans_deg);
yd=linspace(1, num_res,num_res);
[x,y]=meshgrid(xd,yd);
for nd = 1:num_data
    data = char(test_cases(nd));

    f1=figure; set(gcf, 'Position', get(0,'Screensize'));
    f2 = figure; set(gcf, 'Position', get(0,'Screensize'));
    for ndt = 1:num_det
        detector = char(detectors(ndt));
        rep = squeeze(repeat(ndt, nd,:,:));
        switch ndt
            case 1
                C = color_black;
                marker = 's';
            case 2
                C = color_red;
                marker = 'p';
        end
        figure(f1); mesh(x,y,rep, 'EdgeColor', C, 'Marker', marker);
        hold on;
        title(data);zlabel('Repeatability, [%]');
        xlabel(['transf. magnitude ']);
        ax = gca; set(ax,'XTick', [1:num_trans_deg], 'XTickLabel', Xaxis);
        %ylabel(['data sequence ']);
        ax = gca; set(ax,'YTick', [1:num_res], 'YTickLabel', char(resolutions));
        
        nc = squeeze(ncorr(ndt,nd,:,:));
        figure(f2);
        mesh(x,y,nc, 'EdgeColor', C, 'Marker', marker);
        hold on;
        title(data);
        xlabel(['transf. magnitude ']);
        ax = gca; set(ax,'XTick', [1:num_trans_deg], 'XTickLabel', Xaxis);
       % ylabel(['data sequence ']);
        ax = gca; set(ax,'YTick', [1:num_res], 'YTickLabel', char(resolutions));
        zlabel('Number correspondencies');
        
    end
    
    hold off;
    figure(f1);legend(detectors, 'Best');
    figure(f2);legend(detectors, 'Best');
end
