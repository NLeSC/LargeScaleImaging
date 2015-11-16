%applyTransforms- apply series of transformations to an image

batch = true;
transforms = {'rotation'}; %, 'zoom', 'blur', 'lighting'};
lighting_params = [0.9 0.8 0.7 0.6 0.5];
blur_params = [2 5 10 15 20];
num_transforms = 5;
transforms_path = '/home/elena/eStep/LargeScaleImaging/Data/FreiburgRegenerated/transformations/';
all_data_path = '/home/elena/eStep/LargeScaleImaging/Data/FreiburgRegenerated/';
if batch
    test_cases = {'01_graffiti',...
        '03_freiburg_center',...
        '04_freiburg_from_munster_crop',...
        '05_freiburg_innenstadt',...
        '09_cool_car',...
        '17_freiburg_munster',...
        '18_graffiti',...
        '20_hall2',...
        '22_small_palace'};
else
    test_cases = {'18_graffiti'};
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
            homography_file = fullfile(transforms_path, [trans num2str(i) 'M.mat']);
            load(homography_file);
            %transform
            switch trans
                case 'blur'
                    trans_image = applyAffineTransform(reference_image, H, 1);
                    trans_image = transNongeoBlur(trans_image, blur_params(i));
                case 'lighting'
                    trans_image = applyAffineTransform(reference_image, H, 1);
                    trans_image = transNongeoLighting(trans_image, 0, lighting_params(i));
                case 'rotation'
                    %trans_image = applyAffineTransform(reference_image, H, 0);
                    trans_image = applyAffineTransform(reference_image, H, 1);
                otherwise
                    trans_image = applyAffineTransform(reference_image, H, 1);
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