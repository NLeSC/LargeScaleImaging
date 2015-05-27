% test_thresholding.m- script to test gray-level image thresholding evolution
%**************************************************************************
% author: Elena Ranguelova, NLeSc
% date created: 26-05-2015
% last modification date: 27-05-2015
% modification details: adaptation  to  workon Lisa
%**************************************************************************
%% paramaters
interactive = false;
visualize_major = true;
visualize_minor = false;
lisa = true; 

% if visualize_major
%   load('MyColormaps','mycmap'); 
% end

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
  %  min_level = input('Enter minimum gray level: ');
  %  max_level = input('Enter maximum gray level');
    num_levels = input('Enter number of gray-levels');
else
   % min_level =  0; max_level = 255; 
   num_levels = 25;
end

% smoothing with morphology
se = strel('disk',2);

%% find out the number of test files
len = length(image_filename);

%% loop over all test images
for i = 1:len
    %% load the image
    image_data = imread(image_filename{i});
    if ndims(image_data) > 2
        image_data = rgb2gray(image_data);
    end

   % length(unique(image_data))
    if visualize_minor
        % visualize original image
        f = figure; subplot(221); imshow(image_data); title('Original image ');
    end
    
    %% smooth the image
    image_data = imclose(image_data, se);
    %% threshold the original image
    level = graythresh(image_data);
    
    if visualize_minor
        result = im2bw(image_data, level);
        figure(f); subplot(223);imshow(result);
            title('Thresholded original image');    
    end
   
    %% histogram equilization
    image_data = histeq(image_data);
    
    if visualize_minor
        % visualize original image
        figure(f); subplot(222); imshow(image_data); title('Adjusted image');
    end

    %% threshold the adjusted data
    level = graythresh(image_data);
    
    if visualize_minor
        result = im2bw(image_data, level);
        figure(f); subplot(224);imshow(result);
            title('Thresholded adjusted image');
    end


    num_levels_counter = 0;
    
    if visualize_major
        f1=figure; 
    end
    for n = num_levels
        num_levels_counter = num_levels_counter + 1;
        
        %% convert to inxeded image using num_levels
        ind_image = grayslice(image_data,n);
%          thresholds = multithresh(image_data,n) 
%         [ind_image, map] = gray2ind(image_data, n); 
        %% visualize
        if visualize_major
            % visualize quantized image
            figure(f1);
            %subplot(2,3,num_levels_counter);
            rgb = label2rgb(ind_image);
            imshow(rgb); title(['Index image with number of levels: ' num2str(n)]);
            freezeColors;
            %imshow(ind_image,map); title(['Index image with number of levels: ' num2str(n)]);

%             figure(f); subplot(2,4,num_levels_counter+5);
%             %imhist(quantized_data);
%             imshow(quantized_data >= otsu_thr);
%             title('Thresholded his.eq. quantized image');
        end
    %     clear thresh_data;%  acc_thresh_data;
    end
   % clear image_data;
end