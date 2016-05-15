% Face Recognition System
% Version : 1.0
% Date : 28.5.2012
% Author : Omid Sakhi
% Website : http://www.facerecognitioncode.com
%   Please visit the website for complete program and guide

function I = getcam()
vid = videoinput('winvideo', 1, 'RGB24_320x240');
preview(vid);
choice=menu('Capture Frame',...
            '   Capture   ',...
            '     Exit    ');
I = [];        
if (choice == 1)
    I = getsnapshot(vid);
    try
        I = rgb2gray(I);
    end
    I = I(8:231,68:251);
    I = imresize(I,[112 92]);
end
closepreview(vid);