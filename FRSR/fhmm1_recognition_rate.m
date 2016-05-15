function [ recognition_rate ] = fhmm1_recognition_rate( myDatabase, minmax, in_folder, file_type, fhmm1_path)
%UNTITLED6 Summary of this function goes here
%   Detailed explanation goes here

fprintf('START fhmm1_recognition_rate\n');

current_path = pwd;
cd(fhmm1_path);

ufft = [2 3 4 7 9];
total = 0;
recognition_rate = 0;
fprintf('Please Wait...\n');
data_folder_contents = dir (in_folder);
number_of_folders_in_data_folder = size(data_folder_contents,1);
person_index = 0;
for person=1:number_of_folders_in_data_folder
    if (strcmp(data_folder_contents(person,1).name,'.') || ...
        strcmp(data_folder_contents(person,1).name,'..') || ...
        (data_folder_contents(person,1).isdir == 0))
        continue;
    end
    person_index = person_index+1;
    person_name = data_folder_contents(person,1).name;
    fprintf([person_name,'\n']);
%     person_folder_contents = dir(['./data/',person_name,'/*.pgm']);    
    person_folder_contents = dir([in_folder,'\',person_name,'\',file_type]);    
    for face_index=1:size(ufft,2)
        total = total + 1;
        filename = [in_folder,'\',person_name,'\',person_folder_contents(ufft(face_index),1).name];        
        answer_person_index = facerec(filename,myDatabase,minmax);
        if (answer_person_index == person_index)
            recognition_rate = recognition_rate + 1;
        end        
    end
end
recognition_rate = recognition_rate/total*100;
fprintf(['\nRecognition Rate is ',num2str(recognition_rate),'%% for a total of ',num2str(total),' unseen faces.\n']);
cd(current_path);
end

