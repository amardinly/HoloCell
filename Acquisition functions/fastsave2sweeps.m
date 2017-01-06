function fastsave2sweeps(src,event)
 
global s sweeps ExpStruct Exp_Defaults cell1 cell2 countdown h
tic 
    %store channels 1 and 2 in thissweep for further processing
    thissweep=event.Data(:,1:2);

    % scale from nA to pA or Volts to mV
    thissweep=thissweep*1000; 

    % scale by user gain for each channel
    thissweep(:,1)=thissweep(:,1)/cell1.user_gain; 
    thissweep(:,2)=thissweep(:,2)/cell2.user_gain;

    ExpStruct.sweepfraction=ExpStruct.sweepfraction+1;
    % store the data in cell array 'sweeps'
    sweeps{ExpStruct.sweep_counter}=[sweeps{ExpStruct.sweep_counter}; thissweep];
    ExpStruct.cell1sweep=sweeps{ExpStruct.sweep_counter}(:,1);
    ExpStruct.cell2sweep=sweeps{ExpStruct.sweep_counter}(:,2);
    
%     plot(h.Whole_cell1_axes,(1:length(ExpStruct.cell1sweep))/20000,ExpStruct.cell1sweep);
    set(ExpStruct.linehan, 'YData', ExpStruct.cell1sweep, 'XData', (1:length(ExpStruct.cell1sweep))/20000);
    xlim(h.Whole_cell1_axes,[0 length(ExpStruct.LEDoutput1)/20000])
toc
    if ExpStruct.sweepfraction==length(ExpStruct.LEDoutput1)/s.NotifyWhenDataAvailableExceeds;
    start(countdown);
    updateGUI;
    end
end