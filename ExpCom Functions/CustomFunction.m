function CustomFunction(~)
    global h
    
    s = get(h.custom_sequence,'String');
    
    if isempty(s)||strcmp(s,'input');
        errordlg('No Function...')
    end
    
    try
        eval(s)
    catch
        error('error in eval')
    end
end
