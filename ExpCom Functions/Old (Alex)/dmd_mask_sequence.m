function dmd_mask_sequence()


global ExpStruct Exp_Defaults LED Ramp h window a

workingsweep = ExpStruct.sweep_counter+1
load('DMDcalibration.mat');
handles.xoffset=xoffset;
handles.yoffset=yoffset;
xborder = 1024-660;
padleft = floor((xborder)/2+handles.xoffset);
padright = xborder-padleft;
yborder = 768-480;
padtop = round((yborder)/2+handles.yoffset);
padbottom = yborder-padtop;

calllib('DMD','DLP_Source_SetDataSource','SL_EXT3P3');
ExpStruct.mask_sequence=str2num(get(h.custom_sequence,'String'));
maskno = length(ExpStruct.mask_sequence);

if isfield(ExpStruct,'barrelSweepcount') ==0  
    for i = 1:length(ExpStruct.mask_sequence);
    thismask=ExpStruct.mask_sequence(i);
    mask = ExpStruct.masks{thismask};
    finalmask = zeros(1024,768);
    finalmask(padleft+1:padleft+660,padtop+1:padtop+480)=(mask')/255;
    x = bi2de(reshape(finalmask,8,98304)');
    calllib('DMD','DLP_Img_DownloadBitplanePatternToExtMem',x,98304,i+940);
    end
    ExpStruct.sweeppattern=randi(3,1,20000); 
    ExpStruct.barrelSweepcount=0;
end

% generate play sequence for upcoming trial 
if ExpStruct.sweeppattern(workingsweep)==1
    ExpStruct.mask_sequence_order{workingsweep}=ExpStruct.mask_sequence;
    calllib('DMD','DLP_RegIO_WriteImageOrderLut',1, (ExpStruct.mask_sequence_order{workingsweep})+940, maskno);
elseif ExpStruct.sweeppattern(workingsweep)==2
    ExpStruct.mask_sequence_order{workingsweep}=fliplr(ExpStruct.mask_sequence);
    calllib('DMD','DLP_RegIO_WriteImageOrderLut',1, (ExpStruct.mask_sequence_order{workingsweep})+940, maskno);
elseif ExpStruct.sweeppattern(workingsweep)==3
     ExpStruct.mask_sequence_order{workingsweep}=ExpStruct.mask_sequence(randperm(maskno));
    calllib('DMD','DLP_RegIO_WriteImageOrderLut',1, (ExpStruct.mask_sequence_order{workingsweep})+940, maskno)
end
ExpStruct.barrelSweepcount=ExpStruct.barrelSweepcount+1;