function flexwhitenoise_randomlight
global ExpStruct Exp_Defaults LED Ramp h window a


if isfield(ExpStruct,'noisecount') ==0
    ExpStruct.noisecount = 0;
    ExpStruct.noiseseed=[];
    ExpStruct.buffercounter = repmat([0 200],1,100000);
end

workingsweep = ExpStruct.sweep_counter+1        
ExpStruct.noisecount = ExpStruct.noisecount+1;
ExpStruct.noiseseed(workingsweep)=ExpStruct.noisecount;

bufferstart =ExpStruct.buffercounter(workingsweep)

dimensions = str2num(get(h.custom_sequence,'String'));

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
ss = RandStream('mt19937ar','Seed',ExpStruct.noisecount);
reset(ss,ExpStruct.noisecount) 
tic
for i = 1:200
% i = 1;
% y=randi(ss,25,48,64)-24;
y = wgn(32,44,1,1,ss);
% y=randi(ss,25,96,128)-24;
% y=randi(ss,6,192,256)-5;
% y=randi(ss,6,768,1024)-5;
y(y<2)=0;
y(y>=2)=1;
mask = resizem(y,[480 660]);
finalmask = zeros(1024,768);
finalmask(padleft+1:padleft+660,padtop+1:padtop+480)=(mask');
x = bi2de(reshape(finalmask,8,98304)');

calllib('DMD','DLP_Img_DownloadBitplanePatternToExtMem',x,98304,i+ExpStruct.buffercounter(workingsweep));


waitbar(i/200)
end
% toc

% ExpStruct.whitenoiseframeorder(:,workingsweep) = randi(200,[1 200])+ExpStruct.buffercounter(workingsweep);

ExpStruct.whitenoiseframeorder(:,workingsweep) = (1:200)+ExpStruct.buffercounter(workingsweep);

calllib('DMD','DLP_RegIO_WriteImageOrderLut',1,ExpStruct.whitenoiseframeorder(:,workingsweep), length(ExpStruct.whitenoiseframeorder(:,workingsweep)))

% tic
ExpStruct.LEDoutput1=zeros(size(ExpStruct.LEDoutput1));
for k = 1:4
trialStart = 10000*k;
j = randi([0 10],1,200);
j(j<7)=0;
j(j>=7)=1;
for b = 1:length(j)
thisStart=(trialStart+(b-1)*5)*20;
% temp =make_ramps(thisStart, 5, 1, 1, 5*j(b), 5*j(b), Exp_Defaults.Fs, Exp_Defaults.sweepduration);
% ExpStruct.LEDoutput1 = temp+ExpStruct.LEDoutput1;
ExpStruct.LEDoutput1(thisStart:thisStart+99)=j(b)*2;
end
end
% toc
updateAOaxes
toc