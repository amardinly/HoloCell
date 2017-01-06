function SmartGridMap

global ExpStruct Exp_Defaults LED Ramp h window a dmd sweeps

calllib('DMD','DLP_Source_SetDataSource','SL_EXT3P3')

if isfield(ExpStruct,'JGM')
    if not(isfield(ExpStruct.JGM,'trialsPersite'))    
    ExpStruct.JGM.trialsPersite=zeros(1,size(ExpStruct.JGM.grid.maskbinary,2));
    ExpStruct.JGM.semPersite=zeros(1,size(ExpStruct.JGM.grid.maskbinary,2));
    end
else
    ExpStruct.JGM.trialsPersite=zeros(1,size(ExpStruct.JGM.grid.maskbinary,2));
    ExpStruct.JGM.semPersite=zeros(1,size(ExpStruct.JGM.grid.maskbinary,2));
end

ExpStruct.JGM.currentParams=str2num(get(h.custom_sequence,'String'));


ExpStruct.JGM.buffSize=450;
ExpStruct.JGM.loadsPertrial=50;
ExpStruct.JGM.stimsPertrial=100;
workingSweep = ExpStruct.sweep_counter+1;


%% Check if DMD needs to be loaded, load front if necessary

if isfield(ExpStruct.JGM,'loaded') ==0
   
%choose a random subset of frames to load into front of DMD

    ExpStruct.JGM.loadFrames=randperm(size(ExpStruct.JGM.grid.maskbinary,2),ExpStruct.JGM.buffSize); 
   
    for i = 1:ExpStruct.JGM.buffSize        
        thisframe=ExpStruct.JGM.loadFrames(i);
        calllib('DMD','DLP_Img_DownloadBitplanePatternToExtMem',ExpStruct.JGM.grid.maskbinary(:,thisframe),98304,i);
        waitbar(i/ExpStruct.JGM.buffSize)
        ExpStruct.JGM.currentBuffer(i)=thisframe;
    end

    
    
    ExpStruct.JGM.playFrames =ExpStruct.JGM.loadFrames;    
    % start loading 2nd half of buffer
    
    %this starts with play/loadStart switched from what you would expect.
    %this is so that the normal routine to choose frames to
    %load into the other half of the buffer will work
    ExpStruct.JGM.loadStart = 0;
    ExpStruct.JGM.playStart = 450;
    ExpStruct.JGM.bufferloadcounter=ExpStruct.JGM.buffSize/ExpStruct.JGM.loadsPertrial;     
end

%turn on this field so only regular loading happens from now on
ExpStruct.JGM.loaded=1;

%% 

% check if buffer is full, switch play/load side of buffer if so
if ExpStruct.JGM.bufferloadcounter>=(ExpStruct.JGM.buffSize/ExpStruct.JGM.loadsPertrial); 
    
    switch ExpStruct.JGM.loadStart
        case ExpStruct.JGM.buffSize
            NewloadStart=0;
            NewplayStart=ExpStruct.JGM.buffSize;
        case 0
            NewloadStart=ExpStruct.JGM.buffSize;
            NewplayStart=0;
    end
    ExpStruct.JGM.loadStart=NewloadStart;
    ExpStruct.JGM.playStart=NewplayStart;
    ExpStruct.JGM.bufferloadcounter=0;
    
    ExpStruct.JGM.playFrames=ExpStruct.JGM.loadFrames;
    
    %choose new frames to load, don't load things already in playable
    %buffer
    %for future- this is inefficient because will sometimes reload a frame
    %that is already there.
    thisPool=setdiff((1:size(ExpStruct.JGM.grid.maskbinary,2)),ExpStruct.JGM.playFrames);
    
    
    %grab anything that has been played less than the leader
    currentMax= max(ExpStruct.JGM.trialsPersite(thisPool));
    currentPool=find(ExpStruct.JGM.trialsPersite(thisPool)<currentMax);
    if length(currentPool)<ExpStruct.JGM.buffSize
        currentPool=[currentPool randsample(length(thisPool),ExpStruct.JGM.buffSize-length(currentPool))];
    end
    
    
    ExpStruct.JGM.loadFrames=thisPool(currentPool(randperm(length(currentPool),ExpStruct.JGM.buffSize))); 
        
end

%%
    
%load current partition of buffer
tic
for i = 1:ExpStruct.JGM.loadsPertrial
    frameToload=ExpStruct.JGM.bufferloadcounter*ExpStruct.JGM.loadsPertrial+i;
    thisframe=ExpStruct.JGM.loadFrames(frameToload);
    bufferSpot=frameToload+ExpStruct.JGM.loadStart;
    calllib('DMD','DLP_Img_DownloadBitplanePatternToExtMem',ExpStruct.JGM.grid.maskbinary(:,thisframe),98304,bufferSpot);
    ExpStruct.JGM.currentBuffer(bufferSpot)=thisframe;
    ExpStruct.JGM.trackLoad{workingSweep}(i)=thisframe;
end
toc

ExpStruct.JGM.bufferloadcounter=ExpStruct.JGM.bufferloadcounter+1;
ExpStruct.postSweepprogramChoice='SGMplaySelection';