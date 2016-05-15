fileID = fopen('test\Results\FR.txt','w');
for i=1:13
%     face = stateInfo.recog_result(i);
%     str = strcat('Person ', int2str(i),' face recognition result: ', stateInfo.recog_result(i),'\n');
    fprintf(fileID,'Person %i face recognition result: %s\n',i,stateInfo.recog_result{i});
%     fprintf(fileID,'s%',[face]);
%     fprintf(fileID,'\n');
end
fclose(fileID);