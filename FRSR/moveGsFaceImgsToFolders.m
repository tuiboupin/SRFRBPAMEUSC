function [num_of_imgs_moved] = moveGsFaceImgsToFolders( in_path, file_type, out_path, images_in_folder )
% This function moves copies images of file_type from in_path to separate 
% folders in out_path, images_in_folder of images in each subfolder. Sub-
% folder names are s1, ..., sn. Image names in each folder will be
% 1.file_type, ..., images_in_folder.file_type.
% 
% Inputs:
%   in_path: path from where the images are taken
%   file_type: file type of images
%   out_path: path to where subfolders will be created
%   images_in_folder: number of images in each subfolder
% 
% Output:
%   num_of_imgs_moved: number of images moved from in_path to subfolders in
%   out_path
%%%%%%%%%%%%%%%%%%%%

fprintf('START moveGsFaceImgsToFolders\n');

current_folder = pwd;
files_dir = dir(fullfile(in_path, file_type));
num_of_imgs_moved = length(files_dir);
ii = 1;

mkdir(out_path);
cd(out_path);
% mkdir('temp');

while ii < num_of_imgs_moved,
    % folder to move the file to
    folder = ['s' num2str((ii+9)/10)];
    mkdir(folder);
    
    for i = 1:images_in_folder,
        fprintf('Moving file %d out of %d\n', [ii,num_of_imgs_moved]);
        % image to move
        file = [in_path '\face' num2str(ii) '.jpg'];
        RGB = imread(file);
        % convert image to grayscale
        GS = rgb2gray(RGB);
        imwrite(GS,[num2str(i) '.jpg']);
        
        % move file to folder
        if (~exist([folder '\' num2str(i) '.jpg'], 'file'))
            movefile([num2str(i) '.jpg'],folder);
        end
        
        % take next image
        ii = ii + 1;
    end
    
end
% delete 'temp';
cd(current_folder);
end

