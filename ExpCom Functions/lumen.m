function lumen(percentlight,color)
global L

% first control strings
fprintf(L,'%s',char([hex2dec('57'), hex2dec('02'), hex2dec('FF'), hex2dec('50')]));
fprintf(L,'%s',char([hex2dec('57'), hex2dec('03'), hex2dec('AB'), hex2dec('50')]));

intensity = percentlight;

decint = 255-round(255*(intensity./100));
if decint == 0, decint = 1; end % 00 doesn't work for some reason so 0.4% less bright than max?
hexint = dec2hex(decint,2);

switch color
    case 'uv'
        intensitystring = [hex2dec('53'), hex2dec('18'), hex2dec('03'),...
            hex2dec('01'), hex2dec(['f', hexint(1)]), hex2dec([hexint(2), '0']), hex2dec('50')];
    case 'b'
        intensitystring = [hex2dec('53'), hex2dec('1a'), hex2dec('03'),...
            hex2dec('01'), hex2dec(['f', hexint(1)]), hex2dec([hexint(2), '0']), hex2dec('50')];
    case 'r'
        intensitystring = [hex2dec('53'), hex2dec('18'), hex2dec('03'),...
            hex2dec('08'), hex2dec(['f', hexint(1)]), hex2dec([hexint(2), '0']), hex2dec('50')];
    case 'g'
        intensitystring = [hex2dec('53'), hex2dec('18'), hex2dec('03'),...
            hex2dec('04'), hex2dec(['f', hexint(1)]), hex2dec([hexint(2), '0']), hex2dec('50')];
    case 't'
        intensitystring = [hex2dec('53'), hex2dec('1a'), hex2dec('03'),...
            hex2dec('02'), hex2dec(['f', hexint(1)]), hex2dec([hexint(2), '0']), hex2dec('50')];
    case 'c'
        intensitystring = [hex2dec('53'), hex2dec('18'), hex2dec('03'),...
            hex2dec('02'), hex2dec(['f', hexint(1)]), hex2dec([hexint(2), '0']), hex2dec('50')];
end






fprintf(L,'%s',char(intensitystring));

%init cyan
switch color
    case 'c'
        fprintf(L,'%s',char([hex2dec('4F'), hex2dec('7B'),hex2dec('50')]))
        
    case 'g'
        fprintf(L,'%s',char([hex2dec('4F'), hex2dec('7D'),hex2dec('50')]))    
end




