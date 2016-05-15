function [ img_num ] = ScSR_Folder( in_folder, file_type, scale, ScSR_path, dictionary_path, out_folder)
% This function super-resolves images from given folder of given file type
% using ScSR method and given dictionary and saves super-resolved imges to
% given output folder
%   
% Inputs:
%   in_folder: path from where to super-resolve images
%   file_type: type of images to super resolve (i.e. '*.jpg')
%   scale: scale to which to super-resolve
%   ScSR_path: path to ScSR code
%   dictionary: path to dictionary file from ScSR path
%   out_folder: folder to save super-resolved images
% 
% Output:
%   img_num: number of images super-resolved
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fprintf('START ScSR_Folder\n');

img_dir = dir(fullfile(in_folder, file_type));
mkdir(out_folder);

current_folder = pwd;
cd(ScSR_path);

img_num = length(img_dir);

for ii = 1:img_num,
    fprintf('Processing image %d out of %d\n', [ii,img_num]);
    % read test image
    im_l = imread(fullfile(in_folder, img_dir(ii).name));
    
    % set parameters
    lambda = 0.2;                   % sparsity regularization
    overlap = 4;                    % the more overlap the better (patch size 5x5)
    up_scale = scale;               % scaling factor, depending on the trained dictionary
    maxIter = 20;                   % if 0, do not use backprojection
    
    % load dictionary
    load(dictionary_path);
    
    % change color space, work on illuminance only
    im_l_ycbcr = rgb2ycbcr(im_l);
    im_l_y = im_l_ycbcr(:, :, 1);
    im_l_cb = im_l_ycbcr(:, :, 2);
    im_l_cr = im_l_ycbcr(:, :, 3);
    
    % image super-resolution based on sparse representation
    [im_h_y] = ScSR(im_l_y, up_scale, Dh, Dl, lambda, overlap);
    [im_h_y] = backprojection(im_h_y, im_l_y, maxIter);
    
    % upscale the chrominance simply by "bicubic"
    [nrow, ncol] = size(im_h_y);
    im_h_cb = imresize(im_l_cb, [nrow, ncol], 'bicubic');
    im_h_cr = imresize(im_l_cr, [nrow, ncol], 'bicubic');
    
    im_h_ycbcr = zeros([nrow, ncol, 3]);
    im_h_ycbcr(:, :, 1) = im_h_y;
    im_h_ycbcr(:, :, 2) = im_h_cb;
    im_h_ycbcr(:, :, 3) = im_h_cr;
    im_h = ycbcr2rgb(uint8(im_h_ycbcr));
    
    imwrite(im_h,[out_folder '\' img_dir(ii).name]);
    
end
cd(current_folder);
end

