%applyHomographies- apply homographies to test images -> test sequences

batch = true;
transforms = {'viewpoint' , 'scale', 'blur', 'lighting'};
%transforms ={'blur'};
lighting_params = [0.95 0.9 0.8 0.7 0.6];
blur_params = [2 3 5 8 10];
num_transforms = 5;
% change this paths accordingly
transforms_path = '/home/elena/eStep/LargeScaleImaging/Data/OxFrei dataset/homographies/';
all_data_path = '/home/elena/eStep/LargeScaleImaging/Data/OxFrei dataset/';
if batch
    test_cases = {'01_graffiti',...
        '02_freiburg_center',...
        '03_freiburg_from_munster_crop',...
        '04_freiburg_innenstadt',...
        '05_cool_car',...
        '06_freiburg_munster',...
        '07_graffiti',...
        '08_hall',...
        '09_small_palace'};
else
    test_cases = {'01_graffiti'};
end

for tc = test_cases
    test_case = char(tc)
    
    data_path = fullfile(all_data_path, test_case);
    reference_file = '_original.ppm';
    
    reference_image = imread(fullfile(data_path, reference_file));
    
    
    for tr = transforms
        trans = char(tr)
        
        for i= 1:num_transforms
            
            % homography
            homography_file = fullfile(transforms_path, [trans num2str(i) '.mat']);
            H = load(homography_file, '-ascii');
            %transform
            switch trans
                case 'blur'
                    trans_image = applyProjectiveTransform(reference_image, H);
                    trans_image = transNongeoBlur(trans_image, blur_params(i));
                case 'ligthing'
                    trans_image = applyProjectiveTransform(reference_image, H);
                    trans_image = transNongeoLighting(trans_image, 0, lighting_params(i));
                case 'rotation'
                    %trans_image = applyProjectiveTransform(reference_image, H, 0);
                    trans_image = applyProjectiveTransform(reference_image, H);
                otherwise
                    trans_image = applyProjectiveTransform(reference_image, H);
            end
                      
            
            % save
            trans_file_ppm = fullfile(data_path, [trans num2str(i) '.ppm']);
            trans_file_jpg = fullfile(data_path, [trans num2str(i) '.jpg']);
            imwrite(trans_image, trans_file_ppm);
            imwrite(trans_image, trans_file_jpg);
        end
        disp('--------------------------------------------------------------');
    end
     disp('*****************************************************************');
end