function stim1pChronos
global L

delay=300;
pulselength = 5;%1
int = 20;
color = 'c';

pause(delay/1000)
lumen(int,color)
pause(pulselength/1000)
lumen(0,color)

