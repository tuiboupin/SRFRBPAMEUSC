function [ img_num ] = downsampleFolder( folder_path, file_type, scale, method, out_path )
% This function downsamples given folder of given type of files by given 
% scale using given method and saves output images to given output folder.
% This method returns number of images downsampled.
% 
% Inputs:
%   folder_path: folder from where the images are downsampled
%   file_type: type of images to downsample (i.e. '*.jpg')
%   scale: scale to which images will be downsampled
%   method: method used for downsampling (i.e. 'nearest')
%   out_path: destination folder
% 
% Output:
%   img_num: number of images downsampled
%%%%%%%%%%%%%%%%

fprintf('START downsampleFolder\n');

img_dir = dir(fullfile(folder_path, file_type));
mkdir(out_path);

img_num = length(img_dir);

for ii = 1:img_num,
    fprintf('Processing image %d out of %d\n', [ii,img_num]);
    % read test image
    im_h = imread(fullfile(folder_path, img_dir(ii).name));
    
    % downsample
    im_l = imresize(im_h,scale,method);
    
    % save downsampled image
    imwrite(im_l,[out_path '\' img_dir(ii).name]);
    
end
end

