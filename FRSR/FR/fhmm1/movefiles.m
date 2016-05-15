clear all; clc;

img_path = 'C:\Users\Dz\Google Drive\Master Thesis\Tonis work\Face Recognition Code\fhmm1\fhmm1\data';
img_per_person = 10;

img_dir = dir(fullfile(img_path, '*.jpg'));
img_num = length(img_dir);
ii = 1;
cd(img_path);

% for ii = 1:img_num,
while ii < img_num,
    % folder to move the file to
    folder = ['s' num2str((ii+9)/10)];
    mkdir(folder);
    
    for i = 1:img_per_person,
        fprintf('Moving file %d out of %d\n', [ii,img_num]);
        % file to move
        file = [img_path '\face' num2str(ii) '.jpg'];
        RGB = imread(file);
%         RGB = imread(fullfile(img_path,img_dir(ii).name));
        GS = rgb2gray(RGB);
        %         imwrite(GS,file);
        imwrite(GS,[img_path '\' num2str(i) '.jpg']);
        
        % rename file
%         new_name = [img_path '\' num2str(i) '.jpg'];
%         if strcmp(file,new_name) ~= 1,
%             movefile(file,new_name);
%         end
                
        % move file to folder
        movefile([img_path '\' num2str(i) '.jpg'],folder);
        
        % take next image
        ii = ii + 1;
    end
    
end