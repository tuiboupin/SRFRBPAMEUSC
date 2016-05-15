clear all; close all; clc;

delta = 1; % Detection is done after each delta frames
use_all_UBs = 1; % if 1, then all upperBody detections are put into xml
                 % otherwise only those where there is at least 2
                 % detections (person + upper body, person + face or 
                 % upper body + face)
bg_frame = 50; % Frame to use as background image
save_vid_format = '.avi';
bw_level = 0.1; % The output image BW replaces all pixels in the input
                 % image with luminance greater than level with the 
                 % value 1 (white) and replaces all other pixels with 
                 % the value 0 (black)


% Set up for face recognition
facerec_path = '..\FRSR\FR\fhmm1\fhmm1';
addpath(genpath(fullfile(facerec_path)));
load 'DATABASE_Single.mat'
threshold_file = load('avg_scores.mat');
thresholds = threshold_file.avg_scores;

% Set up video to process
vidName = '00059';
filetype = '.mts';
rootFolder = '..\Vids\';
vidPath = strcat(rootFolder,vidName,filetype);

% Extract background
% [bg, bg2] = ExtractBG(vidPath);
% bg = uint8(bg);
% bg2 = uint8(bg2);
% imwrite(bg,strcat(vidName,'bg1.jpg'));
% imwrite(bg2,strcat(vidName,'bg2.jpg'));
% bg = imread(strcat(vidName,'bg.jpg'));

workingDir = pwd;
mkdir(workingDir,vidName);
exp_dir = strcat(workingDir,'\',vidName);
mkdir(exp_dir,'original');
mkdir(exp_dir,'no_bg');
mkdir(exp_dir,'yes_bg');

% Set up human detector
peopleDetector = vision.PeopleDetector;
peopleDetector.MinSize = [500 200];

% Set up upper body detector
upperBodyDetector = vision.CascadeObjectDetector('UpperBody');

% Set up face detector
faceDetector = vision.CascadeObjectDetector;
% faceDetector = vision.CascadeObjectDetector('FrontalFaceLBP');
faceDetector.MinSize = [30 30];
profileFaceDetector = vision.CascadeObjectDetector('ProfileFace');
profileFaceDetector.MinSize = [30 30];

video = vision.VideoFileReader(vidPath);

viewer = vision.VideoPlayer;
% viewer2 = vision.VideoPlayer;
% viewer3 = vision.VideoPlayer;

saveVidName = strcat(vidName,save_vid_format); % name to save video with
save_vid = fullfile(workingDir,vidName,saveVidName);
writer = vision.VideoFileWriter(save_vid, ...
    'FrameRate', video.info.VideoFrameRate);
writer.VideoCompressor = 'DV Video Encoder';

% XML
docNode = com.mathworks.xml.XMLUtils.createDocument...
    ('dataset');
docRootNode = docNode.getDocumentElement;
docRootNode.setAttribute('name',vidName);

% facePoints = [];
% upperBodyPoints = [];
% personPoints = [];

frame = 0; %frame to process
frame_counter = 0; % all frames

while ~isDone(video)
    % for frame = 1:500,
    image = step(video);
    orig_image = image;
    if frame_counter == bg_frame,
        bg = image;
        save_bg = fullfile(workingDir,vidName,strcat(vidName,'bg.jpg'));
        imwrite(bg,save_bg);
    elseif frame_counter > bg_frame && mod(frame_counter,delta) == 0,
%         I_dets = imcomplement(bg - image);
%         bw_abs = im2bw(abs(bg - image),bw_level);
        bw_abs = im2bw(bg - image,bw_level);
%         imshow(bw_abs);
%         step(viewer2,bw_abs);
        mask = cat(3,bw_abs,bw_abs,bw_abs);
        I_dets = mask.*image;
        blacks = I_dets == 0;
        I_dets(blacks) = 255;
%         step(viewer3,I_dets);
        
%         imshow(I_dets);
        
        %     imshow(~im2bw(I_dets))
        %      imshow(im2bw(abs(im2uint8(image)-bg),0.1));
        
        % xml frame and objectlist
        framesNodes = docNode.createElement('frame');
        framesNodes.setAttribute('number',num2str(frame));
        objectlist = docNode.createElement('objectlist');
        framesNodes.appendChild(objectlist);
        docRootNode.appendChild(framesNodes);     
               
        % Detect people and upper bodies
        [people, scores] = step(peopleDetector,I_dets);
        upperBodies = step(upperBodyDetector, I_dets);
        
        p = size(people);
        u = size(upperBodies); %count upperbodies
        
        % Draw detections
        I_dets = insertShape(I_dets, 'Rectangle', people, ...
            'Color', 'red', 'Opacity', 0.7);
        I_dets = insertShape(I_dets, 'Rectangle', upperBodies, ...
            'Color', 'blue', 'Opacity', 0.7);
        image = insertShape(image, 'Rectangle', people, ...
            'Color', 'red', 'Opacity', 0.7);
        image = insertShape(image, 'Rectangle', upperBodies, ...
            'Color', 'blue', 'Opacity', 0.7);
        for i = 1:u(1), % for each upper body
            
            confidence = 1;
            % find if inside person
            for ii = 1:p(1),
                isIn = YinsideX(people(ii,:),upperBodies(i,:));
                if isIn == 2,
                    confidence = confidence + 1;
                    break
                end
            end
            
            % crop upper body
            upperBody = imcrop(I_dets,upperBodies(i,:));  %without bg
            upperBody_bg = imcrop(image,upperBodies(i,:));  %with bg
            
            % find if has face
            faces = step(faceDetector, upperBody_bg);
            f = size(faces);
            if f(1) == 0, % find profile faces if face not found
                profilefaces = step(profileFaceDetector, upperBody_bg);
                heads = [faces;profilefaces];
            else
                heads = faces;
            end
            h = size(heads);
            
            max_score = 0;
            threshold = 100;
            for iii = 1:h(1),
                % find head bos from whole frame
                headPos(1) = upperBodies(i,1) + heads(iii,1);
                headPos(2) = upperBodies(i,2) + heads(iii,2);
                headPos(3) = heads(iii,3);
                headPos(4) = heads(iii,4);
                
                % draw all heads
                I_dets = insertShape(I_dets, 'Rectangle', headPos, ...
                    'Color', 'yellow', 'Opacity', 0.7);
                
                if YinsideX(upperBodies(i,:),headPos) > 2,
                    confidence = confidence + 1;
                    % crop face
                    face = imcrop(upperBody,heads(iii,:)); %without bg
                    face_bg = imcrop(upperBody_bg,heads(iii,:)); %with bg
%                     imshow(face_bg); % testing
                    % run face recognition
                    [id, score] = facerec_img(im2uint8(face_bg), ...
                        myDatabase,minmax);
                    % Draw face
                    threshold = thresholds(1,id);
                    if score > threshold,
                        I_dets = insertObjectAnnotation(I_dets, ...
                            'Rectangle', headPos, ...
                            strcat(myDatabase{1,id},', ',num2str(score)), ...
                            'Color', 'green');
                        image = insertObjectAnnotation(image, ...
                            'Rectangle', headPos, ...
                            strcat(myDatabase{1,id},', ',num2str(score)), ...
                            'Color', 'green');
                    else
                        I_dets = insertObjectAnnotation(I_dets, ...
                            'Rectangle', headPos, ...
                            strcat(myDatabase{1,id},', ',num2str(score)), ...
                            'Color', 'red');
                        image = insertObjectAnnotation(image, ...
                            'Rectangle', headPos, ...
                            strcat(myDatabase{1,id},', ',num2str(score)), ...
                            'Color', 'red');
                    end
                    if score > max_score, % bigger score = bigger confidence
                        max_score = score;
                        max_id = id;
                    end
                end
            end
            
            % write detection into XML
            if confidence > 1 || use_all_UBs == 1,
                objectsNode = docNode.createElement('object');
                
                if max_score > 0,
                    objectsNode.setAttribute('recog_result', ...
                        myDatabase{1,max_id});
                    objectsNode.setAttribute('recog_score', ...
                        num2str(max_score));
                end
                if max_score >= threshold,
                    objectsNode.setAttribute('recog_over_threshold', ...
                        'Yes');
                else
                    objectsNode.setAttribute('recog_over_threshold', ...
                        'No');
                end
                objectsNode.setAttribute('confidence', ...
                    num2str(confidence/3));
                
                box = docNode.createElement('box');
                box.setAttribute('h',num2str(upperBodies(i,4)));
                box.setAttribute('w',num2str(upperBodies(i,3)));
                box.setAttribute('xc',num2str(upperBodies(i,1)+ ...
                    (upperBodies(i,3)/2)));
                box.setAttribute('yc',num2str(upperBodies(i,2)+ ...
                    (upperBodies(i,4)/2)));
                objectsNode.appendChild(box);
                objectlist.appendChild(objectsNode);
            end
        end
%         step(viewer,uint8(double(I_dets)-double(bg))); % show video
        step(viewer,image); % show video
        step(writer,image); % save video
        
        % save frame
        filename = [sprintf('frame_%03d',frame) '.jpg'];
        fullname_no_bg = fullfile(exp_dir,'no_bg',filename);
        fullname_yes_bg = fullfile(exp_dir,'yes_bg',filename);
        imwrite(I_dets,fullname_no_bg);
        imwrite(image,fullname_yes_bg);
        
        frame = frame+1;
    end
%     filename = [sprintf('frame_%03d',frame_counter) '.jpg'];
%     fullname_original = fullfile(exp_dir,'original',filename);
%     imwrite(orig_image,fullname_original);
    frame_counter = frame_counter + 1;
end
release(viewer);
release(writer);

% save XML
xmlFileName = [vidName '.xml'];
xmlFullName = fullfile(exp_dir,xmlFileName);
xmlwrite(xmlFullName,docNode);

