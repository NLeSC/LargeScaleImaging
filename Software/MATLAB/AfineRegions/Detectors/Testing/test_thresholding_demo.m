% test_thresholding_demo.m- gray-level image thresholding for demo images
%**************************************************************************
% author: Elena Ranguelova, NLeSc
% date created: 16-06-2015
% last modification date: 
% modification details: 
%**************************************************************************
%% paramaters
interactive = false;
visualize_major = true;
visualize_minor = false;
lisa = true; 

if visualize_major
  load('MyColormaps','mycmap'); 
end

%% image filename
if ispc 
    starting_path = fullfile('C:','Projects');
elseif lisa
     starting_path = fullfile(filesep, 'home','elenar');
else
    starting_path = fullfile(filesep,'home','elena');
end
project_path = fullfile(starting_path, 'eStep','LargeScaleImaging');
data_path = fullfile(project_path, 'Data', 'Scientific');
results_path = fullfile(project_path, 'Results', 'Scientific');

test_domain = input('Enter test domain: [AnimalBiometrics|Medical|Forestry]: ','s');

switch lower(test_domain)
  case 'animalbiometrics'
    domain_path = fullfile(data_path,'AnimalBiometrics');
    domain_results_path = fullfile(results_path,'AnimalBiometrics');
    test_case = input('Enter test case: [turtle|whale|newt]: ','s');
    switch lower(test_case)
      case 'turtle'
	test_case_name = 'leatherback'
      case 'whale'
	test_case_name = 'tails'
      case 'newt'
	test_case_name = 'newt'
    end
  case 'medical'
    domain_path = fullfile(data_path,'Medical');
    domain_results_path = fullfile(results_path,'Medical');
    test_case_name = input('Enter test case: [MRI|CT|retina]: ','s');
  case 'forestry'
    domain_path = fullfile(data_path,'Forestry');
    domain_results_path = fullfile(results_path,'Forestry');
    test_case_name = '';
end

data_test_path = fullfile(domain_path, test_case_name);
images_list = dir(data_test_path);

disp('Test case: ');disp(test_case_name);
 %% input parameters
if interactive
    min_level = input('Enter minimum gray level: ');
    max_level = input('Enter maximum gray level: ');
    num_levels = input('Enter number of gray-levels: ');
    thresh = input('Enter thresold vector: ');
else
   min_level =  0; max_level = 255; 
   num_levels = 255;
   thresh = [0.5];
end

%% derived parameters
step = fix((max_level - min_level)/num_levels);
if step == 0
    step = 1;
end
    
%% find out the number of test files
len = length(images_list);

%% loop over all test images
for i = 1:len
    if visualize_major
        f = figure;
    end
    if not(images_list(i).isdir)
      image_filename = fullfile(data_test_path, images_list(i).name);
        %% load the image
        image_data = imread(image_filename);
        if ndims(image_data) > 2
            if visualize_major
                % visualize original image
                 figure(f); subplot(221); imshow(image_data);
                 axis on; grid on; title('Color image '); freezeColors;
            end
            image_data = rgb2gray(image_data);
        end
        if visualize_major
            % visualize gray image
            figure(f); subplot(222); imshow(image_data); 
            axis on; grid on; title('Gray-scale image '); 
            colormap(gray(256));
            freezeColors;
        end    
        
        %% init binary and accumulation image
        bw = zeros(size(image_data));
        bw_o = zeros(size(image_data));
    %    bw_acc = zeros(size(image_data));
        bw_thresh = zeros(size(image_data));
     %   bw_thresh1 = zeros(size(image_data));
        %% standart thresholding
        level = graythresh(image_data);
        bw_o =im2bw(image_data, level);

        if visualize_major
            % visualize thresholded image
            figure(f); subplot(223); imshow(bw_o); 
            axis on; grid on; title(['Otsu thresholded image at level: ' num2str(level)]); 
            freezeColors;
        end       


       %% threshold in 1 step
       i=0;
       for t = thresh
           i =i+1;
           %bw_thresh_old =  bw_thresh;
           %bw_thresh = xor(bw_thresh_old, thresh_cumsum(double(image_data/step), t, 0));   
           bw_thresh = thresh_cumsum(double(image_data/step), t, 0);   
           if visualize_major
                    figure(f); subplot(2,2,3+i);imshow(bw_thresh);
                    axis on; grid on; title(['Cumsum thresholded gray image at threshold: ' num2str(t)]);    
                    freezeColors;
           end
       end

       disp('Paused for next image');
       pause;
    end
end