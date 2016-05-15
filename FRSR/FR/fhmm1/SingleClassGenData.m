function [ myDatabase, minmax ] = SingleClassGenData( excludeFaceId )
% SingleClassGenData Generates database of face images from folder
% excluding 1 face
%   

img_dir = dir(fullfile('./data/s1','*.jpg'));
imgsPerPerson = length(img_dir);

pers_dir = dir(fullfile('./data'));
numOfPers = sum([pers_dir.isdir])-2;


eps=.000001;
% ufft = [1 5 6 8 10];
ufft = 1:imgsPerPerson;
% ufft = 1:10;
ufft = ufft(ufft~=excludeFaceId); % exclude 1 face
imgsPerPerson = length(ufft); % revalue imgsPerPerson
% ufft = ufft(ufft~=1);
fprintf ('Loading Faces ...\n');
data_folder_contents = dir ('./data');
myDatabase = cell(0,0);
person_index = 0;
max_coeffs = [-Inf -Inf -Inf];
min_coeffs = [ Inf  0  0];

I = imread('./data/s1/1.jpg');
[r c] = size(I);
        
for person=1:size(data_folder_contents,1);
    if (strcmp(data_folder_contents(person,1).name,'.') || ...
        strcmp(data_folder_contents(person,1).name,'..') || ...
        (data_folder_contents(person,1).isdir == 0))
        continue;
    end
    person_index = person_index+1;
    person_name = data_folder_contents(person,1).name;
    myDatabase{1,person_index} = person_name;
    fprintf([person_name,' ']);
%     person_folder_contents = dir(['./data/',person_name,'/*.pgm']);    
    person_folder_contents = dir(['./data/',person_name,'/*.jpg']);    
    blk_cell = cell(0,0);
    for face_index=1:imgsPerPerson
        I = imread(['./data/',person_name,'/', ...
            person_folder_contents(ufft(face_index),1).name]);
%         I = imresize(I,[56 46]);
        I = ordfilt2(I,1,true(3));        
        blk_index = 0;
        for blk_begin=1:r-4
            blk_index=blk_index+1;
            blk = I(blk_begin:blk_begin+4,:);            
            [U,S,V] = svd(double(blk));
            blk_coeffs = [U(1,1) S(1,1) S(2,2)];
            max_coeffs = max([max_coeffs;blk_coeffs]);
            min_coeffs = min([min_coeffs;blk_coeffs]);
            blk_cell{blk_index,face_index} = blk_coeffs;
        end
    end
    myDatabase{2,person_index} = blk_cell;
    if (mod(person_index,10)==0)
        fprintf('\n');
    end
end
delta = (max_coeffs-min_coeffs)./([18 10 7]-eps);
minmax = [min_coeffs;max_coeffs;delta];
for person_index=1:numOfPers
    for image_index=1:imgsPerPerson
        for block_index=1:r-4
            blk_coeffs = myDatabase{2,person_index}{block_index,image_index};
            min_coeffs = minmax(1,:);
            delta_coeffs = minmax(3,:);
            qt = floor((blk_coeffs-min_coeffs)./delta_coeffs);
            myDatabase{3,person_index}{block_index,image_index} = qt;
            label = qt(1)*10*7+qt(2)*7+qt(3)+1;            
            myDatabase{4,person_index}{block_index,image_index} = label;
        end
        myDatabase{5,person_index}{1,image_index} = cell2mat(myDatabase{4,person_index}(:,image_index));
    end
end

TRGUESS = ones(7,7) * eps;
TRGUESS(7,7) = 1;
for r=1:6
        TRGUESS(r,r) = 0.6;
        TRGUESS(r,r+1) = 0.4;    
end

EMITGUESS = (1/1260)*ones(7,1260);

fprintf('\nTraining ...\n');
for person_index=1:numOfPers
    fprintf([myDatabase{1,person_index},' ']);
    seqmat = cell2mat(myDatabase{5,person_index})';
    [ESTTR,ESTEMIT]=hmmtrain(seqmat,TRGUESS,EMITGUESS,'Tolerance',.01,'Maxiterations',10,'Algorithm', 'BaumWelch');
    ESTTR = max(ESTTR,eps);
    ESTEMIT = max(ESTEMIT,eps);
    myDatabase{6,person_index}{1,1} = ESTTR;
    myDatabase{6,person_index}{1,2} = ESTEMIT;
    if (mod(person_index,10)==0)
        fprintf('\n');
    end
end
fprintf('done.\n');
save(strcat('DATABASE_',num2str(excludeFaceId)),'myDatabase','minmax');

