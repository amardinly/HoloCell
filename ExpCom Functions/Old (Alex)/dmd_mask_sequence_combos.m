function dmd_mask_sequence_combos()


global ExpStruct Exp_Defaults LED Ramp h window a s

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
    %Add one mask for all columns
    mask = ExpStruct.masks{1}+ExpStruct.masks{2}+ExpStruct.masks{3}+ExpStruct.masks{4}+ExpStruct.masks{5};
    finalmask = zeros(1024,768);
    finalmask(padleft+1:padleft+660,padtop+1:padtop+480)=(mask')/255;
    x = bi2de(reshape(finalmask,8,98304)');
    calllib('DMD','DLP_Img_DownloadBitplanePatternToExtMem',x,98304,940+maskno+1);   
    %Add one mask for 3 columns
    mask = ExpStruct.masks{2}+ExpStruct.masks{3}+ExpStruct.masks{4}
    finalmask = zeros(1024,768);
    finalmask(padleft+1:padleft+660,padtop+1:padtop+480)=(mask')/255;
    x = bi2de(reshape(finalmask,8,98304)');
    calllib('DMD','DLP_Img_DownloadBitplanePatternToExtMem',x,98304,940+maskno+2);   
    %Add one mask for surround only
    mask = ExpStruct.masks{1}+ExpStruct.masks{2}+ExpStruct.masks{4}+ExpStruct.masks{5};
    finalmask = zeros(1024,768);
    finalmask(padleft+1:padleft+660,padtop+1:padtop+480)=(mask')/255;
    x = bi2de(reshape(finalmask,8,98304)');
    calllib('DMD','DLP_Img_DownloadBitplanePatternToExtMem',x,98304,940+maskno+3);   
    
    %1 pattern for each single mask, 3 for stimultaneous combos, 3 for
    %sequences = 11 if using 5 masks
    ExpStruct.sweeppattern=randi(maskno+6,1,20000); 
    ExpStruct.barrelSweepcount=0;
end


% generate play sequence for upcoming trial 
s.wait
if ExpStruct.sweeppattern(workingsweep)<=8
    ExpStruct.mask_sequence_order{workingsweep}=ExpStruct.sweeppattern(workingsweep);
    calllib('DMD','DLP_RegIO_WriteImageOrderLut',1, (ExpStruct.mask_sequence_order{workingsweep})+940, 1);
elseif ExpStruct.sweeppattern(workingsweep)==9
    ExpStruct.mask_sequence_order{workingsweep}=ExpStruct.mask_sequence;
    calllib('DMD','DLP_RegIO_WriteImageOrderLut',1, (ExpStruct.mask_sequence_order{workingsweep})+940, maskno);
elseif ExpStruct.sweeppattern(workingsweep)==10
    ExpStruct.mask_sequence_order{workingsweep}=fliplr(ExpStruct.mask_sequence);
    calllib('DMD','DLP_RegIO_WriteImageOrderLut',1, (ExpStruct.mask_sequence_order{workingsweep})+940, maskno);
elseif ExpStruct.sweeppattern(workingsweep)==11
     ExpStruct.mask_sequence_order{workingsweep}=ExpStruct.mask_sequence(randperm(maskno));
    calllib('DMD','DLP_RegIO_WriteImageOrderLut',1, (ExpStruct.mask_sequence_order{workingsweep})+940, maskno)
end
ExpStruct.barrelSweepcount=ExpStruct.barrelSweepcount+1;