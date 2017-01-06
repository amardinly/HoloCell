function [output] = freqModramps(rampstart_time, ramp_duration, ramp_frequency, ramp_number, rampstart_voltage, rampend_voltage, Fs, sweepduration)

timebase=linspace(0,sweepduration,(Fs*sweepduration));
output=linspace(0,0,Fs*sweepduration); 
starttime = (rampstart_time*Fs/1000); % convert from milliseconds to points

 for j=1:ramp_number
        thisStart=round(rampstart_time*Fs/1000);
        thisEnd=round(rampstart_time*Fs/1000+ramp_duration*Fs/1000)-1;
        
        if rampstart_voltage~=rampend_voltage
            
        analogRamp=linspace(rampstart_voltage,rampend_voltage,Fs/1000*ramp_duration);
        
        %crazy ass frequency modulation
        x=cumtrapz(analogRamp);
%         x=[x 0];
        pulseOutput=zeros(1,length(analogRamp));
        i=1;
        thispd=1;
        pdlog=[];
        pdmult=1;
        
        while i <length(x)
            if x(i)>=4
                if pdmult>=50
                    pulseOutput(i-4*pdmult+1:i)=1;
                    x=x-4;
                    pdlog=[pdlog thispd];
                    thispd=1;
                    pdmult=1;
                elseif thispd>8+4*(pdmult-1)
                    pulseOutput(i-4*pdmult:i-1)=1;
                    x=x-4;
                    pdlog=[pdlog thispd];
                    thispd=1;
                    pdmult=1;
                elseif thispd<=8+4*(pdmult-1)
                    x=x-4;
                    pdmult=pdmult+1;
                end
            end
            i = i+1;
            thispd=thispd+1;
        end

      output(thisStart:thisEnd)=pulseOutput(1,1:length(analogRamp));  
      
        else
            output(thisStart:thisEnd)=1;           
        end
      rampstart_time=rampstart_time+(1/ramp_frequency*1000);
      
      
 end
 
    output=output';


end