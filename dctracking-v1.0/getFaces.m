function stateInfo=getFaces(stateInfo)

global detections

asscDet=stateInfo.asscDet;
[F,N]=size(asscDet);
stateInfo.recog_result = cell(1,N);
targetsExist=getTracksLifeSpans(asscDet);


for id=1:N
    sid=targetsExist(id,1);
    eid=targetsExist(id,2);
    frames=sid:eid;
    recog_results={};

    for t=frames
        if asscDet(t,id) ~= 0
            if strcmp(detections(t).recog_positive(asscDet(t,id)),'Yes')
                recog_results = [recog_results ...
                    detections(t).recog_result(asscDet(t,id))];
            end
        end
    end
    % Find most frequent recognition result for id and write it to
    % stateInfo
    if length(recog_results) > 0
        [unique_strings, ~, string_map]=unique(recog_results);
        most_common_string=unique_strings(mode(string_map));
        stateInfo.recog_result(id)=most_common_string;
    end
end