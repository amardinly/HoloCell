function dynamicPowerAdjustment
global ExpStruct h Ramp;
locations = SatsumaRigFile();

persistent LaserPower XYZ_Points xyPowerInterp TFPowerMap;
if isempty(LaserPower);
    disp('Currently only supports 20x laser power conversion');
    %load('\\128.32.173.33\Imaging\STIM\Calibration Parameters\20X_Objective_Calibration_LaserPower.mat','LaserPower');
    load(locations.PowerCalib,'LaserPower');
end
    wattRequest = str2double(ExpStruct.reqWatts);


   % if we dont have the I variable, load the data and create it
    if  isempty(xyPowerInterp)  
        load([locations.CalibrationParams 'xyPowerInterp.mat']);
    end
    
    if  isempty(TFPowerMap)  
        load([locations.CalibrationParams 'TFPowerMap.mat']);
    end
    
    
    if isempty(XYZ_Points)
    
        load([locations.CalibrationParams '20X_Objective_Zoom_2_XYZ_Calibration_Points.mat']);
    end
        
   
    if ExpStruct.TF
       ScaleFactor=correctPower(LaserPower,TFPowerMap,XYZ_Points);

    else
        ScaleFactor=correctPower(LaserPower,xyPowerInterp,XYZ_Points);
    end
    disp(['Scalefactor = ' num2str(ScaleFactor)]);
    wattRequest=wattRequest/ScaleFactor;
        





        
k=ExpStruct.StimLaserEOM;  %grab current voltage
if max(k)==0;
    errordlg('no output to adjust')
    return;
end

indx=find(k>0);  %find where K is high

 
        


if  ExpStruct.TF
    Volt = function_EOMVoltage(LaserPower.EOMVoltage,LaserPower.PowerOutputTF,wattRequest);
else
    Volt = function_EOMVoltage(LaserPower.EOMVoltage,LaserPower.PowerOutput,wattRequest);
end

if isnan(Volt)
    disp('Error cannot deliver power');
    Volt=0;
end



%Ramp.rampstart_voltage = Volt;
%Ramp.rampend_voltage = Volt;

%set(h.rampstart_voltage,'string',num2str(Ramp.rampstart_voltage));
%set(h.rampend_voltage,'string',num2str(Ramp.rampend_voltage));



disp(['Power output dynamically adjusted based on ROI location, now shooting ' num2str(Volt) ' Volts'])
k(indx)=Volt;
ExpStruct.StimLaserEOM = k;
updateAOaxes  