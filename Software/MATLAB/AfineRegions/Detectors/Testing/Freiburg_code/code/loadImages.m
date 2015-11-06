function imgstruct = loadImages(folder)

if ~exist('folder','var') || isempty(folder)
    folder = '/home/elena/eStep/LargeScaleImaging/Data/FreiburgRegenerated/01_graffiti/';
end

folderinfo = dir(fullfile(folder, '*.jpg'));

imgstruct = struct([]);

for i = 1:length(folderinfo)
    imgstruct(i).name = folderinfo(i).name;
    imgstruct(i).fullFilename = fullfile(folder, folderinfo(i).name);
    
    imgstruct(i).origImage = imread(fullfile(folder, folderinfo(i).name));
end

end
