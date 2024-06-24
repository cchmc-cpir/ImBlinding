function [results] = ImBlinding(inputFolder,outputFolder)
%% A Function written to take a folder of images and deidentify them to 
% blind subsequent imaging scoring/analysis
% 
% inputFolder - string, required: path to folder containing 
%
% outputFolder - string, optional: path to save blinded images and key
%
% results - struct: results from blinding process
%           success:

%% Determine files to process
imFolders = dir(inputFolder);
imFolders = imFolders(~ismember({imFolders.name},{'.','..','.DS_Store'}));

%% Set up
numImgs = length(imFolders);
idxs = randperm(numImgs, numImgs)';
folderName = strings(numImgs,1);
fileName = strings(numImgs,1);
studyDate = strings(numImgs,1);
stationName = strings(numImgs,1);
studyDescription = strings(numImgs,1);
seriesDescription = strings(numImgs,1);
patientID = strings(numImgs,1);

mkdir(outputFolder);

%% Process each image
for i=1:numImgs
    idx = idxs(i);

    % determine img type
    subdir = dir(fullfile(inputFolder,imFolders(idx).name));
    subdir = subdir(~ismember({subdir.name},{'.','..'}));
    [path, name, ext] = fileparts(subdir(1).name);
    file = fullfile(subdir(1).folder,subdir(1).name);
    
    % read
    switch ext
        case '.dcm'
            info = dicominfo(file);
            if length(subdir) == 1
                v = squeeze(dicomreadVolume(file));
            else
                v = squeeze(dicomreadVolume(subdir(1).folder));
            end
            folderName(i) = imFolders(idx).name;
            fileName(i) = info.Filename;
            studyDate(i) = info.StudyDate;
            stationName(i) = info.StationName;
            studyDescription(i) = info.StudyDescription;
            seriesDescription(i) = info.SeriesDescription;
            patientID(i) = info.PatientID;
        case '.nii'
            info = niftiinfo(file);
            v = squeeze(niftiread(file));
            folderName(i) = imFolders(idx).name;
            fileName(i) = info.Filename;
    end
    
    % save w/ new name
    niftiwrite(v, fullfile(outputFolder, strcat(num2str(i), ".nii")))
end

%% Save
results = table(idxs,patientID,studyDate,folderName,fileName,stationName,studyDescription,seriesDescription);
writetable(results,fullfile(inputFolder,"key.xls"));

end