function varSparrateMod
global ExpStruct Exp_Defaults LED Ramp h window a sweeps

tic
workingsweep = ExpStruct.sweep_counter+1 

xborder = 1024-660;
padleft = floor((xborder)/2+ExpStruct.xoffset);
padright = xborder-padleft;
yborder = 768-480;
padtop = round((yborder)/2+ExpStruct.yoffset);
padbottom = yborder-padtop;

    
calllib('DMD','DLP_Source_SetDataSource','SL_EXT3P3');
% ExpStruct.currentsparseness=[0.1 0.2 0.5:0.5:10 11:20 22:2:40 60 100];

ExpStruct.currentsparseness=str2num(get(h.custom_sequence,'String'));
numSpar=length(ExpStruct.currentsparseness);
framesPerspar=20;
totalBufferlength=numSpar*framesPerspar;
pulsesPerstim=10;


if isfield(ExpStruct,'noisecount') ==0

   
%load up front of buffer if first trial
    ExpStruct.currentseed=1;       
    ss = RandStream('mt19937ar','Seed',ExpStruct.currentseed);
    reset(ss,ExpStruct.currentseed) 
    
     
  
    for j=1:length(ExpStruct.currentsparseness)        
        for i = 1:framesPerspar
        y = randi(ss,1000,ExpStruct.wgngrid.numrow,ExpStruct.wgngrid.numcol);
        y=y/10;
        y = (y<=ExpStruct.currentsparseness(j));    
        ExpStruct.currentStimtoLoad{i+(j-1)*framesPerspar}=y;
        end
    end
    
    ExpStruct.stimarchive{workingsweep-1}=ExpStruct.currentStimtoLoad;
    
    for i = 1:totalBufferlength
    frameToload=i;
    mask = zeros(size(ExpStruct.wgngridmask));
    noise = resizem(ExpStruct.currentStimtoLoad{frameToload},[ExpStruct.wgngrid.totalheight ExpStruct.wgngrid.totalwidth]);
    mask(ceil(ExpStruct.wgngrid.top:ExpStruct.wgngrid.bottom-1),ceil(ExpStruct.wgngrid.left:ExpStruct.wgngrid.right-1))=noise;
    finalmask = zeros(1024,768);
    finalmask(padleft+1:padleft+660,padtop+1:padtop+480)=(mask'); 
%     if max(finalmask)==0
%         finalmask(1024,768)=1;
%     end
    DMDload(frameToload,finalmask);
    waitbar(i/440)
    end
    
    %add dead frame at end of buffer
    finalmask = zeros(1024,768);   
    DMDload(900,finalmask);
    
       
    ExpStruct.lastseed =ExpStruct.currentseed;
    ExpStruct.lastsparseness=ExpStruct.currentsparseness;
    ExpStruct.noisecount = 0;
    ExpStruct.noiseseed=[];
    ExpStruct.bufferstart = 0;
    ExpStruct.bufferloadcounter=totalBufferlength/20; 
    
    ExpStruct.condcount=zeros(numSpar*3,1);
    
end


ExpStruct.noisecount = ExpStruct.noisecount+1;

%check if buffer is full
if ExpStruct.bufferloadcounter==totalBufferlength/20;
    
    ExpStruct.lastseed =ExpStruct.currentseed;
    ExpStruct.lastsparseness=ExpStruct.currentsparseness;
    ExpStruct.currentseed=randi(10000);       
    ss = RandStream('mt19937ar','Seed',ExpStruct.currentseed);
    reset(ss,ExpStruct.currentseed) 
        %generate new stimuli set
        
        for j=1:length(ExpStruct.currentsparseness)
            for i = 1:framesPerspar
            y = randi(ss,1000,ExpStruct.wgngrid.numrow,ExpStruct.wgngrid.numcol);
            y=y/10;
            y = (y<=ExpStruct.currentsparseness(j));          
            ExpStruct.currentStimtoLoad{i+(j-1)*framesPerspar}=y;
            end
        end        
        ExpStruct.stimarchive{workingsweep}=ExpStruct.currentStimtoLoad;
        
        
        if ExpStruct.bufferstart == totalBufferlength;
        newbufferstart=0;
        ExpStruct.playstart=totalBufferlength;
        elseif ExpStruct.bufferstart == 0;
        newbufferstart=totalBufferlength;
        ExpStruct.playstart=0;
        end
        
        ExpStruct.bufferstart=newbufferstart;
        ExpStruct.bufferloadcounter=0;
end


thisFrameorder=[];
for j = 1:20

    %pick a stimulus condition
    trialsTouse=find(ExpStruct.condcount==min(ExpStruct.condcount));
    thisSpchoose=trialsTouse(randi(length(trialsTouse)));
    ExpStruct.condcount(thisSpchoose)=ExpStruct.condcount(thisSpchoose)+1;

    % decide firing rate
    ExpStruct.rateMod{ExpStruct.sweep_counter}(j)=ceil(thisSpchoose/numSpar)-1;

    ExpStruct.spchoose{ExpStruct.sweep_counter}(j)=thisSpchoose-ExpStruct.rateMod{ExpStruct.sweep_counter}(j)*numSpar;

    %track sparseness        
    ExpStruct.sparseness{ExpStruct.sweep_counter}(j)=ExpStruct.lastsparseness(ExpStruct.spchoose{ExpStruct.sweep_counter}(j));



    %%set up frame order for next sweep

    %designate which part of the buffer to draw from based on sparseness for
    %this stimulus
    thisOffset=ExpStruct.playstart+(ExpStruct.spchoose{ExpStruct.sweep_counter}(j)-1)*framesPerspar;


    %pick number of pulses to apply for that stim

    
        if ExpStruct.rateMod{ExpStruct.sweep_counter}(j)==0        
        thisFrameorder= [thisFrameorder 900 900 900 900 900 randi(framesPerspar,1)+thisOffset 900 900 900 900];

        elseif ExpStruct.rateMod{ExpStruct.sweep_counter}(j)==1  
        tempFrame=ones(1,pulsesPerstim)*randi(framesPerspar,1)+thisOffset;
        tempFrame(2:2:10)=900;
        thisFrameorder= [thisFrameorder tempFrame]; 
        elseif ExpStruct.rateMod{ExpStruct.sweep_counter}(j)==2  
        tempFrame=ones(1,pulsesPerstim)*randi(framesPerspar,1)+thisOffset;
        thisFrameorder= [thisFrameorder tempFrame]; 
        end
        
end






ExpStruct.whitenoiseframeorder{ExpStruct.sweep_counter} = thisFrameorder;
calllib('DMD','DLP_RegIO_WriteImageOrderLut',1,ExpStruct.whitenoiseframeorder{ExpStruct.sweep_counter}, length(ExpStruct.whitenoiseframeorder{ExpStruct.sweep_counter}));  
ExpStruct.trackplayseed(ExpStruct.sweep_counter)=ExpStruct.lastseed;
toc



%load current partition of buffer
% tic
    for i = 1:20
    frameToload=ExpStruct.bufferloadcounter*20+i;
    mask = zeros(size(ExpStruct.wgngridmask));
    noise = resizem(ExpStruct.currentStimtoLoad{frameToload},[ExpStruct.wgngrid.totalheight ExpStruct.wgngrid.totalwidth]);
    mask(ceil(ExpStruct.wgngrid.top:ExpStruct.wgngrid.bottom-1),ceil(ExpStruct.wgngrid.left:ExpStruct.wgngrid.right-1))=noise;
    finalmask = zeros(1024,768);
    finalmask(padleft+1:padleft+660,padtop+1:padtop+480)=(mask');
%     if max(finalmask)==0
%         finalmask(1024,768)=1;
%     end
    
    DMDload(frameToload+ExpStruct.bufferstart,finalmask);
    end
toc

ExpStruct.trackloadcounter(workingsweep)=ExpStruct.bufferloadcounter;
ExpStruct.bufferloadcounter=ExpStruct.bufferloadcounter+1;
ExpStruct.noiseloadseed(workingsweep)=ExpStruct.currentseed;
% 
% if ExpStruct.onlineAnalysis==1
%     for i = 1:2
%     ExpStruct.hz(i,ExpStruct.sweep_counter-1)= get_spike_times(sweeps{ExpStruct.sweep_counter-1}(i,1));
%     end
%     if ~ishold(h.analysis1_axes)
%         hold(h.analysis1_axes)
%     end
%     
%     plot(h.analysis1_axes,ExpStruct.sparseness{ExpStruct.sweep_counter-1},...
%         ExpStruct.hz(1,ExpStruct.sweep_counter-1),'o','Color',[ExpStruct.shuffle(ExpStruct.sweep_counter-1) 0 0]);
%     plot(h.analysis1_axes,ExpStruct.sparseness{ExpStruct.sweep_counter-1},...
%         ExpStruct.hz(2,ExpStruct.sweep_counter-1),'x','Color',[ExpStruct.shuffle(ExpStruct.sweep_counter-1) 0 0]);
% end


updateAOaxes