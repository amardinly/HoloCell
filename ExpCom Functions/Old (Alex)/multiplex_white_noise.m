function multiplex_white_noise

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




if isfield(ExpStruct,'noisecount') ==0

    ExpStruct.currentWGNrandomlightparams=str2num(get(h.custom_sequence,'String'));
    %load up front of buffer if first trial
    ExpStruct.currentseed=1;       
    ss = RandStream('mt19937ar','Seed',ExpStruct.currentseed);
    reset(ss,ExpStruct.currentseed) 
    for i = 1:400
        y = wgn(ExpStruct.currentWGNrandomlightparams(1),ExpStruct.currentWGNrandomlightparams(2),0,[],ss);
        y(y<ExpStruct.currentWGNrandomlightparams(3))=0;
        y(y>=ExpStruct.currentWGNrandomlightparams(3))=1;
        ExpStruct.currentStimtoLoad{i}=y;
    end
    
    ExpStruct.stimarchive{workingsweep-1}=ExpStruct.currentStimtoLoad;
    
    for i = 1:400
    frameToload=i;
    mask = resizem(ExpStruct.currentStimtoLoad{frameToload},[480 660]);
    finalmask = zeros(1024,768);
    finalmask(padleft+1:padleft+660,padtop+1:padtop+480)=(mask');
    x = bi2de(reshape(finalmask,8,98304)');
    calllib('DMD','DLP_Img_DownloadBitplanePatternToExtMem',x,98304,frameToload);
    waitbar(i/400)
    end
    
    ExpStruct.lastseed =ExpStruct.currentseed;
    ExpStruct.lastWGNrandomlightparams=ExpStruct.currentWGNrandomlightparams;
    ExpStruct.noisecount = 0;
    ExpStruct.noiseseed=[];
    ExpStruct.bufferstart = 0;
    ExpStruct.bufferloadcounter=16; 
    
end


ExpStruct.noisecount = ExpStruct.noisecount+1;

%check if buffer is full
if ExpStruct.bufferloadcounter==16;
    
    ExpStruct.lastseed =ExpStruct.currentseed;
    ExpStruct.lastWGNrandomlightparams=ExpStruct.currentWGNrandomlightparams;
    ExpStruct.currentWGNrandomlightparams=str2num(get(h.custom_sequence,'String'));
    ExpStruct.currentseed=randi(10000);       
    ss = RandStream('mt19937ar','Seed',ExpStruct.currentseed);
    reset(ss,ExpStruct.currentseed) 
        %generate new stimuli set
        for i = 1:400
            y = wgn(ExpStruct.currentWGNrandomlightparams(1),ExpStruct.currentWGNrandomlightparams(2),0,[],ss);
            y(y<ExpStruct.currentWGNrandomlightparams(3))=0;
            y(y>=ExpStruct.currentWGNrandomlightparams(3))=1;   
            ExpStruct.currentStimtoLoad{i}=y;
        end
        
        ExpStruct.stimarchive{workingsweep}=ExpStruct.currentStimtoLoad;
        
        if ExpStruct.bufferstart == 400;
            newbufferstart=0;
            ExpStruct.playstart=400;
        elseif ExpStruct.bufferstart == 0;
            newbufferstart=400;
            ExpStruct.playstart=0;
        end
        
        ExpStruct.bufferstart=newbufferstart;
        ExpStruct.bufferloadcounter=0;
end


%load current partition of buffer
% tic
    for i = 1:25
        frameToload=ExpStruct.bufferloadcounter*25+i;
        mask = resizem(ExpStruct.currentStimtoLoad{frameToload},[480 660]);
        finalmask = zeros(1024,768);
        finalmask(padleft+1:padleft+660,padtop+1:padtop+480)=(mask');
        x = bi2de(reshape(finalmask,8,98304)');
        calllib('DMD','DLP_Img_DownloadBitplanePatternToExtMem',x,98304,ExpStruct.bufferstart+frameToload);
    end
% toc

ExpStruct.trackloadcounter(workingsweep)=ExpStruct.bufferloadcounter;
ExpStruct.bufferloadcounter=ExpStruct.bufferloadcounter+1;
ExpStruct.noiseloadseed(workingsweep)=ExpStruct.currentseed;
ExpStruct.trackWGNrandomlightloadparams(:,workingsweep)=ExpStruct.currentWGNrandomlightparams;
    
%set up frame order for next sweep
ExpStruct.frameOrdermatrix{workingsweep} = randi(400,[4 50])+ExpStruct.playstart;
for i = 1:length(ExpStruct.frameOrdermatrix{workingsweep})
    ExpStruct.whitenoiseframeorder((1:16)+16*(i-1),workingsweep)=repmat(ExpStruct.frameOrdermatrix{workingsweep}(:,i),4,1);
end

calllib('DMD','DLP_RegIO_WriteImageOrderLut',1,ExpStruct.whitenoiseframeorder(:,workingsweep), length(ExpStruct.whitenoiseframeorder(:,workingsweep)));    
ExpStruct.trackplayseed(workingsweep)=ExpStruct.lastseed;
ExpStruct.trackWGNrandomlightplayparams(:,workingsweep)=ExpStruct.lastWGNrandomlightparams;

% make random light pattern
ExpStruct.LEDoutput1=zeros(size(ExpStruct.LEDoutput1));
trialStart = 1000;
j = randi([0 19],1,50);

for b = 1:length(j)
thisStart=(trialStart+(b-1)*20+j(b))*20;
thisEnd=thisStart+randi([0 20])*20; 
ExpStruct.LEDoutput1(thisStart:thisEnd)=1.4;
end



updateAOaxes