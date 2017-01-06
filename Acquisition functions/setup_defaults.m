function setup_defaults (~)
global Exp_Defaults ExpStruct LED Ramp cell1 cell2 globalTimer s 


%% --set Rig Defaults Values here---- %%
% these are most of the values you might want to change to fit your
% experiment
locations = SatsumaRigFile();
% set default path for saving files here
SavePath=locations.savePath;

%Don't change these
IndexPath=[SavePath,'ExpIndex'];
SavePath=[SavePath,datestr(date,'yymmdd'),'\'];

% config settings
% loadConfigs = 0; %set to select new config folder
% if loadConfigs
%         [ExpStruct.configName configPath] = uigetfile('*.mat','Select Configuration File...');
%     if ischar(configName)    
%         load(fullfile(configPath, ExpStruct.configName));
%     else
%         disp('No config loaded...');
%     end
% else
configPath = '';% 'C:\Users\User\Documents\MATLAB\QuarterCell_IAO\DAQ Configuration Files\whitenoise_default.rpt.mat';
ConfigName = ''; %set this to auto name configs
try
    load(configPath);
catch
    disp('No config loaded...');
end

% end
if ~exist('output_patterns','var')
    ConfigName = 'Default';
end


% set default inter-stimulus-interval; this is the total time between
% successive trigers from the timer fcn, not the time between trials
ISI = 3;

% set default sweep duration (in seconds)
sweepduration = 1;

% set initial values for the LED1 output here
rampstart_voltage1=0; % in volts
rampend_voltage1=0; % in volts
ramp_duration1=0; % in milliseconds
ramp_frequency1=1; % in Hz
ramp_number1=1;     
rampstart_time1=500;  % in milleseconds

% set initial values for the LED2 output here
rampstart_voltage2=0; % in volts
rampend_voltage2=0; % in volts
ramp_duration2=0; % in milliseconds
ramp_frequency2=1; % in Hz
ramp_number2=1;     
rampstart_time2=500;  % in milleseconds

% setup current injection params for cell1
ccpulseamp1=0;
ccpulse_dur1=0;
ccnumpulses1=1;
ccpulsefreq1=0.1;
ccpulsestarttime1=500;
deltacurrentpulseamp1=100;

% setup current injection params for cell2
ccpulseamp2=0;
ccpulse_dur2=1000;
ccnumpulses2=1;
ccpulsefreq2=0.1;
ccpulsestarttime2=500;
deltacurrentpulseamp2=100;

% initialize analysis limits values
ExpStruct.analysis_limits.cell1= [0.01 0 0.02 0];
ExpStruct.analysis_limits.cell2= [0.01 0 0.02 0];

% user gains
user_gain1 = 2; % set gains according to Multiclamp. 1V/nA default setting for voltage clamp
user_gain2 = 2;

highpass_freq1=500;
highpass_freq2=500;

% set default state of external triggering, 0 for internal, 1 for external triggering
ExternalTrigger = 0; 

% set default state for saving after each trial, 0 for no saving, 1 for saving after each trial
% may want no saving if will hang up computer on long experiments with long
% trial durations
ifsave=0; 

%% setup default structures
% don't fuck with unless you know what
% you're doing


% if directory for SavePath does not exist, create a folder for it
if exist(SavePath,'dir') == 0
    mkdir(SavePath);
end

% set amplifier info
amplifier = 'Multiclamp'; %or 'axopatch200B';

% set sampling frequency in Hz
Fs = 20000;  

% set total sweeps (usehigh number so timer function doensn't stop)
total_sweeps=100000; 

% set default voltage clamp external command sensititivty (fixed for Axon
% amplifiers at 20 mV/mV)
VCexternalcommandsensitivity = 20; 

% set default type of output for each analog output channel
AO0='wholecell'; 
AO1='wholecell'; 
AO2='EOM';
AO3='LED1';


% set whether using analog input lines 33,34, and 35 for reading digital
% input
DIO_on = 0; % set to 1 for using digital input, otherwise set to 0

% get info about DAQ device 
device=daq.getDevices;
daqModel = device.Model;
NIDAQ_type = strcmp(daqModel,'PCI-6036E');


%set output gains
if strcmp(amplifier,'axopatch200B')==1
    CCexternalcommandsensitivity = 2000; % for axopatch
else
    CCexternalcommandsensitivity = 400;  % for multiclamp
end

if (NIDAQ_type==1)
    Fs = 5000; % sampling frequency in kHz, must use 5K or less for older National Insturments card
end

if (NIDAQ_type==1)
    s.addAnalogOutputChannel('dev1',0:1,'Voltage'); % for PCI-6036 which only has two analog outputs
else
    s.addAnalogOutputChannel('dev1',0:3,'Voltage'); % other cards have 4 AOs
end

if (ExternalTrigger == 1)
  s.addTriggerConnection('External','dev1/PFI1','StartTrigger');
end


%initialize sweep counter to 1
sweep_counter = 1; 


% setup fields for Experiment structs
CCoutput1=[]; CCoutput2=[]; ExperimentName=''; LEDoutput1=[]; SaveName='';
SetSweepNumber=1; cell1sweep=[]; cell2sweep=[]; 
stims=[]; sweeps={}; testpulse=[]; thissweep=[]; timebase=[]; tag = zeros(1,10000);
stim_tag = zeros(1,10000); currentStimpattern = 0; StimLaserGate =[]; StimLaserEOM=[]; triggerSI5=[];
triggerPuffer=[]; nextholoTrigger=[];nextsequenceTrigger=[];motorTrigger=[];



%setup fields for cell structs
series_r1=[];
holding_i1=[];
input_r1=[];
spikerate1=[];

series_r2=[];
holding_i2=[];
input_r2=[];

% create time vector for plotting across trials
trialtime=[];


% create global structs


Exp_Defaults = struct('Fs', Fs,'sweepduration', sweepduration,'ISI', ISI, 'daqModel', device.Model, ...
    'total_sweeps', total_sweeps, 'NIDAQ_type', NIDAQ_type, 'ExternalTrigger', ExternalTrigger, 'amplifier', amplifier, ...
    'VCexternalcommandsensitivity', VCexternalcommandsensitivity, 'CCexternalcommandsensitivity', ...
    CCexternalcommandsensitivity, 'ifsave', ifsave, ...
    'AO0', AO0, 'AO1', AO1, 'AO2', AO2, 'AO3', AO3, 'DIO_on', DIO_on);

ExpStruct = struct('CCoutput1', CCoutput1, 'CCoutput2', CCoutput2, 'ExperimentName', ExperimentName, 'LEDoutput1', LEDoutput1, ...
    'SaveName', SaveName, 'SavePath', SavePath, 'SetSweepNumber', SetSweepNumber, 'cell1sweep', cell1sweep, 'cell2sweep', cell2sweep, ... 
    'stims', stims, 'sweep_counter', sweep_counter, 'testpulse', testpulse, ...
    'thissweep', thissweep, 'timebase', timebase, ...
    'trialtime',trialtime,'tag',tag,'stim_tag',stim_tag,'currentStimpattern',currentStimpattern,'IndexPath',IndexPath, ...
    'StimLaserGate',StimLaserGate,'StimLaserEOM',StimLaserEOM,'triggerSI5',triggerSI5,'triggerPuffer',triggerPuffer, ...
    'nextholoTrigger',nextholoTrigger,'nextsequenceTrigger',nextsequenceTrigger,'motorTrigger',motorTrigger);

cell1 = struct('series_r', series_r1, 'holding_i', holding_i1, 'input_r', input_r1, 'pulseamp', ...
    ccpulseamp1, 'pulseduration', ccpulse_dur1, 'pulsenumber', ccnumpulses1, 'pulsefrequency', ccpulsefreq1, ...
    'pulse_starttime', ccpulsestarttime1, 'deltacurrentpulseamp', deltacurrentpulseamp1, 'user_gain', user_gain1, ...
    'highpass_freq', highpass_freq1, 'spikerate1', spikerate1);

cell2 = struct('series_r', series_r2, 'holding_i', holding_i2, 'input_r', input_r2, 'pulseamp', ...
    ccpulseamp2, 'pulseduration', ccpulse_dur2, 'pulsenumber', ccnumpulses2, 'pulsefrequency', ccpulsefreq2, ...
    'pulse_starttime', ccpulsestarttime2, 'deltacurrentpulseamp', deltacurrentpulseamp2,'user_gain', user_gain2, ...
    'highpass_freq', highpass_freq2);

Ramp = struct('rampend_voltage', rampend_voltage1, 'rampstart_time', rampstart_time1, 'rampstart_voltage', rampstart_voltage1, ...
                'ramp_duration', ramp_duration1, 'ramp_frequency', ramp_frequency1, 'ramp_number', ramp_number1);


% initalize Exp trial time
ExpStruct.trialtime = 0;
ExpStruct.exp_start_time = clock;

    %% stores absolute time when first sweep is taken


%set up default timebase
ExpStruct.timebase=linspace(0,Exp_Defaults.sweepduration,(Exp_Defaults.Fs*Exp_Defaults.sweepduration));

% setup testpulse for votlage clamp
ExpStruct.testpulse = makepulseoutputs(50,1, 50, -0.2, 1, Exp_Defaults.Fs, Exp_Defaults.sweepduration);

% setup default analog outputs
ExpStruct.LEDoutput1= make_ramps(rampstart_time1, ramp_duration1,ramp_frequency1,ramp_number1,rampstart_voltage1,rampend_voltage1, Exp_Defaults.Fs, Exp_Defaults.sweepduration);
ExpStruct.CCoutput1=makepulseoutputs(ccpulsestarttime1,ccnumpulses1, ccpulse_dur1, ccpulseamp1, ccpulsefreq1, Exp_Defaults.Fs, Exp_Defaults.sweepduration);
ExpStruct.CCoutput1=ExpStruct.CCoutput1/400; % scale by externalcommand sensitivity under Current clamp
ExpStruct.CCoutput2=makepulseoutputs(ccpulsestarttime2,ccnumpulses2, ccpulse_dur2, ccpulseamp2, ccpulsefreq2, Exp_Defaults.Fs, Exp_Defaults.sweepduration);
ExpStruct.CCoutput2=ExpStruct.CCoutput2/400; % scale by externalcommand sensitivity under Current clamp
ExpStruct.StimLaserGate=zeros(size(ExpStruct.LEDoutput1));
ExpStruct.StimLaserEOM=zeros(size(ExpStruct.LEDoutput1));
ExpStruct.triggerSI5=zeros(size(ExpStruct.LEDoutput1));
ExpStruct.triggerPuffer=zeros(size(ExpStruct.LEDoutput1));
ExpStruct.nextholoTrigger=zeros(size(ExpStruct.LEDoutput1));
ExpStruct.nextsequenceTrigger=zeros(size(ExpStruct.LEDoutput1));
ExpStruct.motorTrigger=zeros(size(ExpStruct.LEDoutput1));



% Set 1st saved pattern to default analog output settings ( I think this is
% being overwritten by loading default configs??)
ExpStruct.outputchoice=1;
ExpStruct.output_names = {'Default'};
ExpStruct.output_patterns{1}(:,1) = ExpStruct.CCoutput1;
ExpStruct.output_patterns{1}(:,2) = ExpStruct.CCoutput2;
ExpStruct.output_patterns{1}(:,3) = ExpStruct.LEDoutput1;
ExpStruct.output_patterns{1}(:,4) = ExpStruct.StimLaserGate;
ExpStruct.output_patterns{1}(:,5) = ExpStruct.StimLaserEOM;
ExpStruct.output_patterns{1}(:,6) = ExpStruct.triggerSI5;
ExpStruct.output_patterns{1}(:,7) = ExpStruct.triggerPuffer;
ExpStruct.output_patterns{1}(:,8) = ExpStruct.nextholoTrigger;
ExpStruct.output_patterns{1}(:,9) = ExpStruct.nextsequenceTrigger;
ExpStruct.output_patterns{1}(:,10) = ExpStruct.motorTrigger;

%the number of output channels plugged in. 
%future editions can be more versitile by using this to make an arbitrary
%number of outputs
ExpStruct.NUMBER_OF_OUTPUTS = 10;
%mark digital outputs
ExpStruct.isdigit=zeros(ExpStruct.NUMBER_OF_OUTPUTS,1);
ExpStruct.isdigit([4,6:end])=1; %known digital lines

%setup current blank output pattern
for i = 1:ExpStruct.NUMBER_OF_OUTPUTS %hardwired for 10 possible output channels
ExpStruct.CurrentRamp{i}=Ramp;
end
ExpStruct.RampList{1}=ExpStruct.CurrentRamp;

%setup config name
ExpStruct.configName=ConfigName;
ExpStruct.Expt_Params.ConfigSettings=ConfigName;

%setup Epoch
ExpStruct.Epoch = 1;
ExpStruct.EpochEnterTime{1} = clock;
ExpStruct.EpochText1{1}='';
ExpStruct.EpochText2{1}='';
ExpStruct.EpochEnterSweep{1}=1;



ExpStruct.Holo.holoRequestNumber = 0;
ExpStruct.TF=0;
ExpStruct.PowerCorrect=0;



% 
% 
% openLumencor

% initizalize Lumencor vectors
% ExpStruct.Lumencor.color = 1;
% ExpStruct.LCintensity = ones(6,1)*100; % initialize Lumencor output intensity to 10% if using
% ExpStruct.Lumencor_output = zeros(Exp_Defaults.Fs*Exp_Defaults.sweepduration,6);
% ExpStruct.Lumencor_disp_output = zeros(Exp_Defaults.Fs*Exp_Defaults.sweepduration,6);
% ExpStruct.Lumencor_output = Digital_outputgen(ExpStruct.Lumencor.color, 1, 1, 1, 1);

% 
% 
% for i = 1:6
% set_lumencor_intensity(ExpStruct.LCintensity(i),i);
% end

%ExpStruct.LCcolorChoice(1:6)=0;
ExpStruct.checkStimpattern=1;
ExpStruct.dynamicPowerCorrection=0;



s.Rate=Exp_Defaults.Fs;

