function stim1pIO

delay=500;
pulselength = 500;
int = 25;%3;
color = 'c';%'g';

pause(delay/1000)
lumen(int,color)
pause(pulselength/1000)
lumen(0,color)

