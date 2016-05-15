function [background_frame, background_frame2] = ExtractBG (input_video) 
%Time-average the movement regions in a video as the first stage of a
%trajectory-learning algorithm
%Alexander Farley
%alexander.farley at utoronto.ca
%September 16 2011 
%Written and tested in Matlab R2011a
%------------------------------------------------------------------------------
%The purpose of this script is to average a video across all frames as a
%first stage of a trajectory-learning algorithm

bk_downsample = 3; %The downsample factor for frame averaging
disp('Opening video...')
vob = VideoReader(input_video); %A warning about being unable to read the number of frames is due to variable frame rate (normal)
% vob = vision.VideoFileReader(input_video); 
frame = vob.read(inf); %Reads to end, takes a while, but now vob knows the number of frames
vidHeight = vob.Height;
vidWidth = vob.Width;
nFrames = vob.NumberOfFrames;

%% First-iteration background frame
background_frame = double(frame*0);
disp('Calculating background...')
for k = 1:bk_downsample:nFrames
    background_frame = background_frame + double(read(vob, k));
    disp(k/(nFrames)*100)
end

%background_frame = uint8(bk_downsample*background_frame/(nFrames));
background_frame = bk_downsample*background_frame/(nFrames);

imshow(background_frame)

%% Second-iteration background frame
%This section re-calculates the background frame while attempting to
%minimize the effect of moving objects in the calculation
% 
background_frame2 = double(frame*0);
pixel_sample_density = im2bw(double(frame*0));
diff_frame = double(frame*0);
stream_frame = diff_frame(:,:,1);
bk_downsample = 50;

figure
hold on
for k = 1:bk_downsample:nFrames
    diff_frame = imabsdiff(double(read(vob, k)), background_frame);
    diff_frame = 1-im2bw(uint8(diff_frame),.25);
    pixel_sample_density = pixel_sample_density + diff_frame;
    stream_frame = stream_frame + (1-diff_frame)/(nFrames/bk_downsample);
    nonmoving = double(read(vob, k));
    nonmoving(:,:,1) = nonmoving(:,:,1).*diff_frame;
    nonmoving(:,:,2) = nonmoving(:,:,2).*diff_frame;
    nonmoving(:,:,3) = nonmoving(:,:,3).*diff_frame;
    background_frame2 = background_frame2 + nonmoving;
    %pause
    disp(k/(nFrames)*100)
end

background_frame2(:,:,1) = background_frame2(:,:,1)./pixel_sample_density;
background_frame2(:,:,2) = background_frame2(:,:,2)./pixel_sample_density;
background_frame2(:,:,3) = background_frame2(:,:,3)./pixel_sample_density;


imshow(uint8(background_frame2))
imshow(uint8(background_frame))
%imshow(stream_frame)
