clear all;
close all;
clc;

db_base_path = '..\Faces\';
db = 'OUR_60';
file_type = '*.jpg';
downsample_method = 'nearest';
ScSR_path = '.\SR\ScSR';
natural_dictionary_path_2 = 'Dictionary/D_1024_0.15_5.mat';
natural_dictionary_path_4 = 'Dictionary/D_Natural_1024_4x.mat';
no_of_img_in_class = 10;
fhmm1_path = '.\FR\fhmm1';

% select face dictionaries
if strcmp(db,'FERET'),
    face_dictionary_path_2 = 'Dictionary/D_faces_EssexHp_1024_2x_2.mat';
    face_dictionary_path_4 = 'Dictionary/D_faces_EssexHp_1024_4x.mat';
else
    if strcmp(db,'HP_60'),
        face_dictionary_path_2 = 'Dictionary/D_faces_EssexFeret_1024_2x_2.mat';
        face_dictionary_path_4 = 'Dictionary/D_faces_EssexFeret_1024_4x.mat';
    else
        if strcmp(db,'ESSEX'),
            face_dictionary_path_2 = 'Dictionary/D_faces_HpFeret_1024_2x_2.mat';
            face_dictionary_path_4 = 'Dictionary/D_faces_HpFeret_1024_4x.mat';
        else
            face_dictionary_path_2 = 'Dictionary/D_faces_HpFeretEssex_1024_2x_2.mat';
            face_dictionary_path_4 = 'Dictionary/D_faces_HpFeretEssex_1024_4x.mat';
        end
    end
end

db_vj_path = [db_base_path db '_VJ'];

% downsample by factor 2 and 4
ds_dest_2 = [db_vj_path '2nd_run_05'];
ds_dest_4 = [db_vj_path '2nd_run_025'];

img_num = downsampleFolder(db_vj_path, file_type, 0.5, downsample_method, ds_dest_2);
img_num = downsampleFolder(db_vj_path, file_type, 0.25, downsample_method, ds_dest_4);

% Super-resolve 
SR_2_ND_out = [ds_dest_2 '_ND'];
SR_2_FD_out = [ds_dest_2 '_FD'];
SR_4_ND_out = [ds_dest_4 '_ND'];
SR_4_FD_out = [ds_dest_4 '_FD'];
SR_vj_ND_out = [db_vj_path '_FD'];
SR_vj_FD_out = [db_vj_path '_ND'];

ScSR_Folder(ds_dest_2, file_type, 2, ScSR_path, natural_dictionary_path_2, SR_2_ND_out);
ScSR_Folder(ds_dest_2, file_type, 2, ScSR_path, face_dictionary_path_2, SR_2_FD_out);
ScSR_Folder(ds_dest_4, file_type, 4, ScSR_path, natural_dictionary_path_4, SR_4_ND_out);
ScSR_Folder(ds_dest_4, file_type, 4, ScSR_path, face_dictionary_path_4, SR_4_FD_out);
ScSR_Folder(db_vj_path, file_type, 2, ScSR_path, natural_dictionary_path_2, SR_vj_ND_out);
ScSR_Folder(db_vj_path, file_type, 2, ScSR_path, face_dictionary_path_2, SR_vj_FD_out);

% move images to subfolders for fhmm1 face recognition
vj_sf = [fhmm1_path '\used data\data_' db '_VJ'];
ds_2_sf = [fhmm1_path '\used data\data_' db '_VJ_05_LR'];
ds_4_sf = [fhmm1_path '\used data\data_' db '_VJ_025_LR'];
sr_2_nd_sf = [fhmm1_path '\used data\data_' db '_VJ_05_SR_ND'];
sr_2_fd_sf = [fhmm1_path '\used data\data_' db '_VJ_05_SR_FD'];
sr_4_nd_sf = [fhmm1_path '\used data\data_' db '_2nd_run_VJ_025_SR_ND'];
sr_4_fd_sf = [fhmm1_path '\used data\data_' db '_2nd_run_VJ_025_SR_FD'];
vj_sr_2_nd_sf = [fhmm1_path '\used data\data_' db '_VJ_SR_ND'];
vj_sr_2_fd_sf = [fhmm1_path '\used data\data_' db '_VJ_SR_FD'];

moveGsFaceImgsToFolders(db_vj_path, file_type, vj_sf, no_of_img_in_class);
moveGsFaceImgsToFolders(ds_dest_2, file_type, ds_2_sf, no_of_img_in_class);
moveGsFaceImgsToFolders(ds_dest_4, file_type, ds_4_sf, no_of_img_in_class);
moveGsFaceImgsToFolders(SR_2_ND_out, file_type, sr_2_nd_sf, no_of_img_in_class);
moveGsFaceImgsToFolders(SR_2_FD_out, file_type, sr_2_fd_sf, no_of_img_in_class);
moveGsFaceImgsToFolders(SR_4_ND_out, file_type, sr_4_nd_sf, no_of_img_in_class);
moveGsFaceImgsToFolders(SR_4_FD_out, file_type, sr_4_fd_sf, no_of_img_in_class);
moveGsFaceImgsToFolders(SR_vj_ND_out, file_type, vj_sr_2_nd_sf, no_of_img_in_class);
moveGsFaceImgsToFolders(SR_vj_FD_out, file_type, vj_sr_2_fd_sf, no_of_img_in_class);

% generate database for fhmm1 face recognition

DB_file_vj = [fhmm1_path '\used DATABASE\DATABASE_' db '_VJ.mat'];
DB_file_ds_2 = [fhmm1_path '\used DATABASE\DATABASE_' db '_VJ_05_LR.mat'];
DB_file_ds_4 = [fhmm1_path '\used DATABASE\DATABASE_' db '_VJ_025_LR.mat'];
DB_file_sr_2_nd = [fhmm1_path '\used DATABASE\DATABASE_' db '_VJ_05_SR_ND.mat'];
DB_file_sr_2_fd = [fhmm1_path '\used DATABASE\DATABASE_' db '_VJ_05_SR_FD.mat'];
DB_file_sr_4_nd = [fhmm1_path '\used DATABASE\DATABASE_' db '_2nd_run_VJ_025_SR_ND.mat'];
DB_file_sr_4_fd = [fhmm1_path '\used DATABASE\DATABASE_' db '_2nd_run_VJ_025_SR_FD.mat'];
DB_file_vj_sr_2_nd = [fhmm1_path '\used DATABASE\DATABASE_' db '_VJ_SR_ND.mat'];
DB_file_vj_sr_2_fd = [fhmm1_path '\used DATABASE\DATABASE_' db '_VJ_SR_FD.mat'];

[ vj_Db,vj_minmax ] = fhmm1_gendata(vj_sf, file_type, img_num/no_of_img_in_class, fhmm1_path, DB_file_vj);
[ ds_2_Db,ds_2_minmax ] = fhmm1_gendata(ds_2_sf, file_type, img_num/no_of_img_in_class, fhmm1_path, DB_file_ds_2);
[ ds_4_Db,ds_4_minmax ] = fhmm1_gendata(ds_4_sf, file_type, img_num/no_of_img_in_class, fhmm1_path, DB_file_ds_4);
[ sr_2_nd_Db,sr_2_nd_minmax ] = fhmm1_gendata(sr_2_nd_sf, file_type, img_num/no_of_img_in_class, fhmm1_path, DB_file_sr_2_nd);
[ sr_2_fd_Db,sr_2_fd_minmax ] = fhmm1_gendata(sr_2_fd_sf, file_type, img_num/no_of_img_in_class, fhmm1_path, DB_file_sr_2_fd);
[ sr_4_nd_Db,sr_4_nd_minmax ] = fhmm1_gendata(sr_4_nd_sf, file_type, img_num/no_of_img_in_class, fhmm1_path, DB_file_sr_4_nd);
[ sr_4_fd_Db,sr_4_fd_minmax ] = fhmm1_gendata(sr_4_fd_sf, file_type, img_num/no_of_img_in_class, fhmm1_path, DB_file_sr_4_fd);
[ vj_sr_2_nd_Db,vj_sr_2_nd_minmax ] = fhmm1_gendata(vj_sr_2_nd_sf, file_type, img_num/no_of_img_in_class, fhmm1_path, DB_file_vj_sr_2_nd);
[ vj_sr_2_fd_Db,vj_sr_2_fd_minmax ] = fhmm1_gendata(vj_sr_2_fd_sf, file_type, img_num/no_of_img_in_class, fhmm1_path, DB_file_vj_sr_2_fd);

% calculate recognition rate
vj_rate = fhmm1_recognition_rate(vj_Db, vj_minmax, vj_sf, file_type, fhmm1_path);
ds_2_rate = fhmm1_recognition_rate(ds_2_Db, ds_2_minmax, ds_2_sf, file_type, fhmm1_path);
ds_4_rate = fhmm1_recognition_rate(ds_4_Db, ds_4_minmax, ds_4_sf, file_type, fhmm1_path);
sr_2_nd_rate = fhmm1_recognition_rate(sr_2_nd_Db, sr_2_nd_minmax, sr_2_nd_sf, file_type, fhmm1_path);
sr_2_fd_rate = fhmm1_recognition_rate(sr_2_fd_Db, sr_2_fd_minmax, sr_2_fd_sf, file_type, fhmm1_path);
sr_4_nd_rate = fhmm1_recognition_rate(sr_4_nd_Db, sr_4_nd_minmax, sr_4_nd_sf, file_type, fhmm1_path);
sr_4_fd_rate = fhmm1_recognition_rate(sr_4_fd_Db, sr_4_fd_minmax, sr_4_fd_sf, file_type, fhmm1_path);
vj_sr_2_nd_rate = fhmm1_recognition_rate(vj_sr_2_nd_Db, vj_sr_2_nd_minmax, vj_sr_2_nd_sf, file_type, fhmm1_path);
vj_sr_2_fd_rate = fhmm1_recognition_rate(vj_sr_2_fd_Db, vj_sr_2_fd_minmax, vj_sr_2_fd_sf, file_type, fhmm1_path);

% final results
fprintf(['\n',db,' vj_rate is ',num2str(vj_rate),'%%.\n']);
fprintf(['\n',db,' ds_2_rate is ',num2str(ds_2_rate),'%%.\n']);
fprintf(['\n',db,' ds_4_rate is ',num2str(ds_4_rate),'%%.\n']);
fprintf(['\n',db,' sr_2_nd_rate is ',num2str(sr_2_nd_rate),'%%.\n']);
fprintf(['\n',db,' sr_2_fd_rate is ',num2str(sr_2_fd_rate),'%%.\n']);
fprintf(['\n',db,' sr_4_nd_rate is ',num2str(sr_4_nd_rate),'%%.\n']);
fprintf(['\n',db,' sr_4_fd_rate is ',num2str(sr_4_fd_rate),'%%.\n']);
fprintf(['\n',db,' sr_2_nd_rate is ',num2str(vj_sr_2_nd_rate),'%%.\n']);
fprintf(['\n',db,' sr_2_fd_rate is ',num2str(vj_sr_2_fd_rate),'%%.\n']);
