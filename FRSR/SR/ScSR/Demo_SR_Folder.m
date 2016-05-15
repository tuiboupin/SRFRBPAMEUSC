clear all; clc;

img_path = 'C:\Users\Dz\Dropbox\Kool\Magister\Magistritöö\SR\Faces\FERET_VJ_05';
img_dir = dir(fullfile(img_path, '*.jpg'));

img_num = length(img_dir);

% for ii = 1:img_num,
for ii = 1:img_num,
    fprintf('Processing image %d out of %d\n', [ii,img_num]);
    % read test image
    im_l = imread(fullfile(img_path, img_dir(ii).name));
    
    % set parameters
    lambda = 0.2;                   % sparsity regularization
    overlap = 4;                    % the more overlap the better (patch size 5x5)
    up_scale = 2;                   % scaling factor, depending on the trained dictionary
    maxIter = 20;                   % if 0, do not use backprojection
    
    % load dictionary
    load('Dictionary/D_1024_0.15_5.mat');
    
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
    
    imwrite(im_h,['C:\Users\Dz\Dropbox\Kool\Magister\Magistritöö\SR\Faces\FERET_VJ_05_2x_ND\' img_dir(ii).name]);
    
end