function DMDsave

global ExpStruct Exp_Defaults LED Ramp h window a sweeps


currentrate=ExpStruct.currentrate;
currentsparseness=ExpStruct.currentsparseness;
numSpar=ExpStruct.numSpar;
numRate=ExpStruct.numRate;
framesPerspar=ExpStruct.framesPerspar;
totalBufferlength=ExpStruct.totalBufferlength;
currentseed=ExpStruct.currentseed;                
bufferstart= 0;
bufferloadcounter=floor(ExpStruct.totalBufferlength/20);   
condcount=ExpStruct.condcount;
wgngrid=ExpStruct.wgngrid;
wgngridmask=ExpStruct.wgngridmask;
noisecount=1;

save('DMDsaveFile.mat','currentrate','currentsparseness','numSpar','numRate','framesPerspar',...
    'totalBufferlength','currentseed','bufferstart','bufferloadcounter','condcount','wgngrid','noisecount','wgngridmask')

end
