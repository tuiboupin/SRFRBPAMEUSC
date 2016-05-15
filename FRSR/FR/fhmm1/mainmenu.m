% Face Recognition System
% Version : 1.0
% Date : 28.5.2012
% Author : Omid Sakhi
% Website : http://www.facerecognitioncode.com
%   Please visit the website for complete program and guide
% Original Paper : 
%   H. Miar-Naimi and P. Davari A New Fast and Efficient HMM-Based 
%   Face Recognition System Using a 7-State HMM Along With SVD Coefficients

clear all;
close all;
clc;

if (exist('DATABASE.mat','file'))
    load DATABASE.mat;
end
while (1==1)
    choice=menu('Face Recognition',...
                'Generate Database',...
                'Calculate Recognition Rate',...
                'Recognize from Image',...
                'Recognize from Webcam',...
                'Exit');
    if (choice ==1)
        if (~exist('DATABASE.mat','file'))
            [myDatabase,minmax] = gendata();        
        else
            pause(0.1);    
            choice2 = questdlg('Generating a new database will remove any previous trained database. Are you sure?', ...
                               'Warning...',...
                               'Yes', ...
                               'No','No');            
            switch choice2
                case 'Yes'
                    pause(0.1);
                    [myDatabase minmax] = gendata();        
                case 'No'
            end
        end        
    end
    if (choice == 2)
        if (~exist('myDatabase','var'))
            fprintf('Please generate database first!\n');
        else
            recognition_rate = testsys(myDatabase,minmax);                
        end                        
    end    
    if (choice == 3)
        if (~exist('myDatabase','var'))
            fprintf('Please generate database first!\n');
        else            
            pause(0.1);            
            [file_name file_path] = uigetfile ({'*.pgm';'*.jpg';'*.png'});
            if file_path ~= 0
                filename = [file_path,file_name];                
                facerec (filename,myDatabase,minmax);                        
            end
        end
    end
    if (choice == 4)
        I = getcam();
        if (~isempty(I))           
            filename = ['./',num2str(floor(rand()*10)+1),'.pgm'];
            imwrite(I,filename);
            if (exist('myDatabase','var'))
                facerec (filename,myDatabase,minmax);
            end
        end
    end
    if (choice == 5)
        clear choice choice2
        return;
    end    
end