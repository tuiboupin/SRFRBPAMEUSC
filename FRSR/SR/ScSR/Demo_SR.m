% =========================================================================
% Simple demo codes for image super-resolution via sparse representation
%
% Reference
%   J. Yang et al. Image super-resolution as sparse representation of raw
%   image patches. CVPR 2008.
%   J. Yang et al. Image super-resolution via sparse representation. IEEE 
%   Transactions on Image Processing, Vol 19, Issue 11, pp2861-2873, 2010
%
% Jianchao Yang
% ECE Department, University of Illinois at Urbana-Champaign
% For any questions, send email to jyang29@uiuc.edu
% =========================================================================

clear all; clc;

% read test image
im_l = imread('Data/Testing/croppedface.jpg');
im_l_bc = imread('Data/Testing/croppedface.jpg');


% set parameters
lambda = 0.2;                   % sparsity regularization
overlap = 4;                    % the more overlap the better (patch size 5x5)
up_scale = 4;                   % scaling factor, depending on the trained dictionary
maxIter = 20;                   % if 0, do not use backprojection

% load dictionary
% load('Dictionary/D_1024_0.15_5.mat');
% load('Dictionary/D_faces_HpFeretEssex_1024_2x_2.mat');
load('Dictionary/D_faces_HpFeretEssex_1024_4x.mat');
% load('Dictionary/D_faces_1024_2x_2.mat');
tic
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

toc

% bicubic interpolation for reference
im_b = imresize(im_l_bc, [nrow, ncol], 'bicubic');

% read ground truth image
% im = imread('Data/Testing/cropped.jpg');

% compute PSNR for the illuminance channel
% bb_rmse = compute_rmse(im, im_b);
% sp_rmse = compute_rmse(im, im_h);

% bb_psnr = 20*log10(255/bb_rmse);
% sp_psnr = 20*log10(255/sp_rmse);

% fprintf('PSNR for Bicubic Interpolation: %f dB\n', bb_psnr);
% fprintf('PSNR for Sparse Representation Recovery: %f dB\n', sp_psnr);

% show the images
figure, imshow(im_h);
title('Sparse Recovery');
figure, imshow(im_b);
title('Bicubic Interpolation');

% save resulting images
imwrite(im_h,['Data/Testing/croppedface_FD_4x_SR_' TimeStamp '.jpg']);
% imwrite(im_b,['Data/Testing/face1_2x_BC_' TimeStamp '.jpg']);

% compute and save SIMM data
% [bb_ssim, bb_ssim_map] = ssim(rgb2gray(im), rgb2gray(im_b));
% fprintf('SIMM for Bicubic Interpolation: %f\n', bb_ssim);
% imwrite(max(0, bb_ssim_map).^4,['Data/Test/face2_2x_bb_ssim_map_' TimeStamp '.jpg']);

% [sp_ssim, sp_ssim_map] = ssim(rgb2gray(im), rgb2gray(im_h));
% fprintf('SIMM for Sparse Representation Recovery: %f\n ', sp_ssim);
% imwrite(max(0, sp_ssim_map).^4,['Data/Test/face2_2x_sp_ssim_map_' TimeStamp '.jpg']);
