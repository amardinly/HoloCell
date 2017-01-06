function DMDmap

global Exp_Defaults ExpStruct LED Ramp cell1 cell2 globalTimer s a sweeps window

if isfield(ExpStruct,'DMDmap') ==0
    ExpStruct.DMDmapcount = 0;
    ExpStruct.DMDmaporder = randperm(length(ExpStruct.masks));
    
    for i = 1:300
    
    temp = randperm(length(ExpStruct.masks));
    
    while temp(1) == ExpStruct.DMDmaporder(end)
        temp = randperm(length(ExpStruct.masks));       
    end
    
     ExpStruct.DMDmaporder = [ExpStruct.DMDmaporder temp];
    end   
end

maskno=ExpStruct.DMDmaporder(ExpStruct.sweep_counter);
load('DMDcalibration.mat');

xborder = 1024-660;
padleft = round(xborder/2+xoffset);
padright = xborder-padleft;
yborder = 768-480;
padtop = round(yborder/2+yoffset);
padbottom = yborder-padtop;
finalmask = zeros(1024,768);
finalmask(padleft+1:padleft+660,padtop+1:padtop+480)=(ExpStruct.masks{maskno}')/255;
x=reshape(finalmask,8,98304)';

final = bi2de(x);
calllib('DMD','DLP_Img_DownloadBitplanePatternToExtMem',final,98304,0);
% calllib('DMD','DLP_RegIO_WriteImageOrderLut',1, maskno, 1);
calllib('DMD','DLP_Display_DisplayPatternManualForceFirstPattern')

ExpStruct.DMDmap(ExpStruct.sweep_counter)=maskno;

ExpStruct.DMDmapcount =  ExpStruct.DMDmapcount+1;

