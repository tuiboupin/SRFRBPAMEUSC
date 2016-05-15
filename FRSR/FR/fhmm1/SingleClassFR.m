% clear all; close all; clc;

data_path = 'C:\Users\Dz\Google Drive\Master Thesis\Tonis work\Face Recognition Code\fhmm1\fhmm1\data\s1';
% files_dir = dir(fullfile(data_path,'*.jpg'));
% num_imgs = length(files_dir);
% 
% load 'DATABASE_Single.mat'
% 
% min_score = 100;
% for i = 1:num_imgs,
%     face = imread(strcat(data_path,'\',num2str(i),'.jpg'));
%     [id, score] = facerec_img(face,myDatabase,minmax)
%     if score < min_score,
%         min_score = score;
%     end
% end

% 
% data_path = 'C:\Users\Dz\Google Drive\Master Thesis\Tonis work\Face Recognition Code\fhmm1\fhmm1\Pejman database';
files_dir = dir(fullfile(data_path,'*.jpg'));
num_imgs = length(files_dir);

% for i=1:10,
%     SingleClassGenData( i );
% end
total_score = 0;
min_score = 100;
for i = 1:num_imgs,
    face = imread(strcat(data_path,'\',num2str(i),'.jpg'));
    load(strcat('DATABASE_',num2str(i),'.mat'));
    [id, score] = facerec_img(face,myDatabase,minmax);
    if score < min_score,
        min_score = score;
    end
    total_score = total_score + score;
end

avg_score = total_score/num_imgs;

save(strcat(data_path,'\avg_score'),'avg_score');
save(strcat(data_path,'\min_score'),'min_score');
%                     
%                     