% test_evolving_thresholding.m- gray-level image thresholding evolution
%**************************************************************************
% author: Elena Ranguelova, NLeSc
% date created: 15-06-2015
% last modification date: 16-06-2015
% modification details: simplifying the threshodling in 1 step
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
if interactive 
    image_filename = input('Enter the test image filename: ','s');
else
    test_image = input('Enter test case: [boat|phantom|graffiti|leuven|thorax|bikes]: ','s');
    switch lower(test_image)
        case 'boat'
            image_filename{1} = fullfile(starting_path,'eStep','LargeScaleImaging',...
            'Data','AffineRegions','boat','boat1.png');    
            image_filename{2} = fullfile(starting_path,'eStep','LargeScaleImaging',...
            'Data','AffineRegions','boat','boat2.png');
            image_filename{3} = fullfile(starting_path,'eStep','LargeScaleImaging',...
                'Data','AffineRegions','boat','boat3.png');
            image_filename{4} = fullfile(starting_path,'eStep','LargeScaleImaging',...
                'Data','AffineRegions','boat','boat4.png');
            image_filename{5} = fullfile(starting_path,'eStep','LargeScaleImaging',...
                'Data','AffineRegions','boat','boat5.png');
            image_filename{6} = fullfile(starting_path,'eStep','LargeScaleImaging',...
                'Data','AffineRegions','boat','boat6.png');
        case 'phantom'
            image_filename{1} = fullfile(starting_path,'eStep','LargeScaleImaging',...
            'Data','AffineRegions','Phantom','phantom.png');
            image_filename{2} = fullfile(starting_path,'eStep','LargeScaleImaging',...
            'Data','AffineRegions','Phantom','phantom_affine.png');
        case 'graffiti'
            image_filename{1} = fullfile(starting_path,'eStep','LargeScaleImaging',...
            'Data','AffineRegions','graffiti','graffiti1.png');    
            image_filename{2} = fullfile(starting_path,'eStep','LargeScaleImaging',...
            'Data','AffineRegions','graffiti','graffiti2.png');
            image_filename{3} = fullfile(starting_path,'eStep','LargeScaleImaging',...
                'Data','AffineRegions','graffiti','graffiti3.png');
            image_filename{4} = fullfile(starting_path,'eStep','LargeScaleImaging',...
                'Data','AffineRegions','graffiti','graffiti4.png');
            image_filename{5} = fullfile(starting_path,'eStep','LargeScaleImaging',...
                'Data','AffineRegions','graffiti','graffiti5.png');
            image_filename{6} = fullfile(starting_path,'eStep','LargeScaleImaging',...
                'Data','AffineRegions','graffiti','graffiti6.png');
        case 'leuven'
            image_filename{1} = fullfile(starting_path,'eStep','LargeScaleImaging',...
            'Data','AffineRegions','leuven','leuven1.png');    
            image_filename{2} = fullfile(starting_path,'eStep','LargeScaleImaging',...
            'Data','AffineRegions','leuven','leuven2.png');
            image_filename{3} = fullfile(starting_path,'eStep','LargeScaleImaging',...
            'Data','AffineRegions','leuven','leuven3.png');    
            image_filename{4} = fullfile(starting_path,'eStep','LargeScaleImaging',...
            'Data','AffineRegions','leuven','leuven4.png');
            image_filename{5} = fullfile(starting_path,'eStep','LargeScaleImaging',...
            'Data','AffineRegions','leuven','leuven5.png');    
            image_filename{6} = fullfile(starting_path,'eStep','LargeScaleImaging',...
            'Data','AffineRegions','leuven','leuven6.png');
        case 'bikes'
            image_filename{1} = fullfile(starting_path,'eStep','LargeScaleImaging',...
            'Data','AffineRegions','bikes','bikes1.png');    
            image_filename{2} = fullfile(starting_path,'eStep','LargeScaleImaging',...
            'Data','AffineRegions','bikes','bikes2.png');
            image_filename{3} = fullfile(starting_path,'eStep','LargeScaleImaging',...
            'Data','AffineRegions','bikes','bikes3.png');    
            image_filename{4} = fullfile(starting_path,'eStep','LargeScaleImaging',...
            'Data','AffineRegions','bikes','bikes4.png');
            image_filename{5} = fullfile(starting_path,'eStep','LargeScaleImaging',...
            'Data','AffineRegions','bikes','bikes5.png');    
            image_filename{6} = fullfile(starting_path,'eStep','LargeScaleImaging',...
            'Data','AffineRegions','bikes','bikes6.png');
        case 'thorax'
            image_filename{1} = fullfile(starting_path,'eStep','LargeScaleImaging',...
            'Data','AffineRegions','CT','thorax1.jpg');
    end


end
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
len = length(image_filename);

%% loop over all test images
for i = 1:len
    if visualize_major
        f = figure;
    end
    %% load the image
    image_data = imread(image_filename{i});
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
