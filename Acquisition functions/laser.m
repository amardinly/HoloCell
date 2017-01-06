function laser()

global laser_struct laserTimer hlaser

laser_struct.duration = 0.500;
laser_struct.voltage = 0.6; 
laser_struct.Fs = 20000;


hlaser=guihandles(manual_laser_control);
assignin('base', 'hlaser', hlaser);