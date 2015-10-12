function repeatability_demo

det_suffix={'mser';'mssr'; 'smssr';'dmsr'};

lisa = false;
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
test_case = input('Enter the test case : [bark|bikes|boat|graffiti|leuven|trees|ubc|wall]: ','s');

feature_filename = fullfile(results_path,test_case,test_case);
image_filename = fullfile(data_path,test_case,'img');
%% repeatabiliy figures
f1 = figure; f2 =  figure;
figure(f1);clf;
grid on;
ylabel('repeatebility %')
xlabel('transformation strength');
hold on;
figure(f2);clf;
grid on;
ylabel('nb of correspondences')
xlabel('transformation strength');
hold on;

mark=['-gs';'-bv';'-rp'];
for d=1:3
    seqrepeat=[];
    seqcorresp=[];
    for i=2:6
        file1=sprintf('%s1.%s',feature_filename,det_suffix{d});
        file2=sprintf( '%s%d.%s',feature_filename, i,det_suffix{d});
        Hom=fullfile(data_path, test_case, sprintf('H1to%dp',i));
        imf1=[image_filename '1.ppm'];
        imf2=sprintf('%s%d.ppm',image_filename,i);
        [erro,repeat,corresp, match_score,matches, twi]=repeatability(file1,file2,Hom,imf1,imf2, 1);
        seqrepeat=[seqrepeat repeat(4)];
        seqcorresp=[seqcorresp corresp(4)];
    end
    figure(f1);  plot([20 30 40 50 60],seqrepeat,mark(d,:));
    figure(f2);  plot([20 30 40 50 60],seqcorresp,mark(d,:));
end

figure(f1);legend(det_suffix{1},det_suffix{2},det_suffix{3});
axis([10 70 0 100]);
figure(f2);legend(det_suffix{1},det_suffix{2},det_suffix{3});

