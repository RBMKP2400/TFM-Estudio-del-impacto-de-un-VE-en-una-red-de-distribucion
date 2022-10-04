function Function_MATLAB_OPENDSS(Main_dss)

DSSObj = actxserver('OpenDSSEngine.DSS');

if ~DSSObj.Start(0)
    disp('Unable to start the OpenDSS Engine');
    return
end

DSSText = DSSObj.Text;

% Define la ubicación exacta del Circuito

if Main_dss == 1
    DSSText.Command = 'Compile (F:\0. CARLETES\MÁSTER\Masters\TFM\Tema definitivo\0. Código Matlab\IEEE13Main.dss)';
else
    DSSText.Command = 'Compile (F:\0. CARLETES\MÁSTER\Masters\TFM\Tema definitivo\0. Código Matlab\IEEE13Main_2.dss)';
end

DSSText.Command = 'Export voltages';

end