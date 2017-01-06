
global dmd ExpStruct
dmd = guihandles(DMDcontrol9000);

%% 

gridstuff=ExpStruct.grid;
ExpStruct.JGM.grid=ExpStruct.grid;
ExpStruct.JGM.gridmask=ExpStruct.gridmask;
ExpStruct.JGM.maskbinary=ExpStruct.grid.maskbinary;
JGM=ExpStruct.JGM;
gridmask = ExpStruct.gridmask;



save('DMD_preload.mat','gridstuff','JGM','gridmask')


%% 

load('DMD_preload.mat');
ExpStruct.grid=gridstuff;
ExpStruct.JGM=JGM;
ExpStruct.gridmask=gridmask;

% ExpStruct.JGM.trialsPersite=zeros(1,size(ExpStruct.grid.maskbinary,2)); 