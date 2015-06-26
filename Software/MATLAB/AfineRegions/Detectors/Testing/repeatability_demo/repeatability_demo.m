function repeatability_demo

fprintf(1,'It may take a while, i.e. 30min \n');
%mex c_eoverlap.cxx;

det_suffix=['haraff';'hesaff';'mseraf';'ibraff';'ebraff'];
det_nb=3;


for i=1:6
%detectFeatures(sprintf('./h_affine.ln -haraff -sift -i img%d.ppm -o img%d.%s -thres 1000',i,i,det_suffix(1,:)));

%detectFeatures(sprintf('./h_affine.ln -hesaff -sift -i img%d.ppm  -o img%d.%s -thres 500',i,i,det_suffix(2,:)));

detectFeatures(sprintf('./mser.ln   -t 2 -es 2 -i img%d.ppm -o img%d.%s',i,i,det_suffix(3,:)));

detectFeatures(sprintf('./ibr.ln   img%d.ppm img%d.%s -scalefactor 1.0',i,i,det_suffix(4,:)));

detectFeatures(sprintf('./ebr.ln   img%d.ppm img%d.%s',i,i,det_suffix(5,:)));

end

figure(1);clf;
grid on;
ylabel('repeatebility %')
xlabel('viewpoint angle');
hold on;
figure(2);clf;
grid on;
ylabel('nb of correspondences')
xlabel('viewpoint angle');
hold on;

mark=['-kx';'-rv';'-gs';'-m+';'-bp'];
for d=1:5
seqrepeat=[];
seqcorresp=[];
for i=2:6
  file1=sprintf('img1.%s',det_suffix(d,:));
file2=sprintf('img%d.%s',i,det_suffix(d,:));
Hom=sprintf('H1to%dp',i);
imf1='img1.ppm';
imf2=sprintf('img%d.ppm',i);
[erro,repeat,corresp, match_score,matches, twi]=repeatability(file1,file2,Hom,imf1,imf2, 1);
seqrepeat=[seqrepeat repeat(4)];
seqcorresp=[seqcorresp corresp(4)];
end
figure(1);  plot([20 30 40 50 60],seqrepeat,mark(d,:));
figure(2);  plot([20 30 40 50 60],seqcorresp,mark(d,:));
end

figure(1);legend(det_suffix(1,:),det_suffix(2,:),det_suffix(3,:),det_suffix(4,:),det_suffix(5,:));
axis([10 70 0 100]);
figure(2);legend(det_suffix(1,:),det_suffix(2,:),det_suffix(3,:),det_suffix(4,:),det_suffix(5,:));

function detectFeatures(command)
fprintf(1,'Detecting features: %s\n',command);
[status,result] = system(command);
