function [metrics2d metrics3d]=printDCUpdate(stateInfo,splines,used,nNew,nRemoved,itcnt,D,S,L)
% print energy and performance information
% 
% (C) Anton Andriyenko, 2012
%
% The code may be used free of charge for non-commercial and
% educational purposes, the only requirement is that this text is
% preserved within the derivative work. For any other purpose you
% must contact the authors for permission. This code may not be
% redistributed without written permission from the authors.


global opt gtInfo dcStartTime sceneInfo

gtheader='';
metheader='';
metrics2d=zeros(1,14);
metrics3d=zeros(1,14);

if sceneInfo.gtAvailable && opt.verbosity>=3 
    gtheader=''; metheader='';
    
    if opt.track3d
        gtheader='  ----------- M E T R I C S (3D)---------- |||';
        metheader=' MOTA  MOTP| GT  MT  ML|  FP   FN IDs  FM  |||';
        if opt.met2d
            gtheader=[gtheader '  ----------- M E T R I C S (2D)--------- '];
            metheader=[metheader ' MOTA  MOTP| GT  MT  ML|  FP   FN IDs  FM|'];
        end
    else
        if opt.met2d
            gtheader='  ----------- M E T R I C S (2D)---------- |||';
            metheader=' MOTA  MOTP| GT  MT  ML|  FP   FN IDs  FM |';
        end        
    end
    
end

if ~mod(itcnt,10)
    printMessage(2,'\n ------------- INFO  -------------|| -------- ENERGY  VALUES --------|||%s',gtheader);
    printMessage(2,'\n  it| time| models| used| add| rem|| Energy |  Data | Smooth| Label| |||%s\n',metheader);
end

printMessage(2,'%4i|%5.1f|%7i|%5i|%4i|%4i||%8i|%7i|%7i|%6i| |||', ...
    itcnt, toc(dcStartTime)/60,length(splines),length(used),nNew, nRemoved,int32(D)+int32(S)+int32(L),D,S,L); %%% iter output

if opt.verbosity>=3
    if sceneInfo.gtAvailable
        stateInfo=getStateFromSplines(splines(used), stateInfo);
        

        if opt.track3d
            [metrics3d metrNames3d]=CLEAR_MOT(gtInfo,stateInfo,struct('eval3d','1'));
            printMetrics(metrics3d,metrNames3d,0,[12 13 4 5 7 8 9 10 11]);
            printMessage(3,'|||');
        end    

        if opt.met2d
            if opt.track3d
                [stateInfo.Xi stateInfo.Yi]=projectToImage(stateInfo.X, stateInfo.Y,sceneInfo);
            else
                stateInfo.Xi=stateInfo.X; stateInfo.Yi=stateInfo.Y;
            end
            stateInfo=getBBoxesFromState(stateInfo);
            evopt.eval3d=0;
            [metrics2d metricsInfo2d]=CLEAR_MOT(gtInfo,stateInfo,evopt);
            printMetrics(metrics2d,metricsInfo2d,0,[12 13 4 5 7 8 9 10 11]);    
        end

    end
end
printMessage(2,'\n');

end
