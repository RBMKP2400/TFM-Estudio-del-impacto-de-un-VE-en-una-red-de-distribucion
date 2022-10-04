clc % borrar datos command widow
clear all % borrar datos Workspace
close all % cerrar figuras abiertas

%-------------------------------------------------------------
% PARÁMETROS DE SIMULACIÓN (USUARIO)
%-------------------------------------------------------------

Nom_case = 'B.4.2_';

t_inicio = 0; %h
t_fin = 23.8; %h
DeltaT = 600; %s

Main_dss = 1; %1 (B - con regulador tomas) o 2 (A - sin regulador tomas)

%-------------------------------------------------------------
% DEFINIR VALORES NOMINALES DE VOLTAJE
%-------------------------------------------------------------

if Main_dss == 1

V_nominal = {'SOURCEBUS' 115 3 ; 650 4.16 3 ; 'RG60' 4.16 3 ; 633 4.16 3 ; 634 0.48 3 ; 671 4.16 3 ; 645 4.16 2 ; 646 4.16 2 ; 692 4.16 3 ; 675 4.16 3 ; 611 4.16 1 ; 652 4.16 1 ; 670 4.16 3 ; 632 4.16 3 ; 680 4.16 3 ; 684 4.16 2};
V_nominal = string(V_nominal);

else

V_nominal = {'SOURCEBUS' 115 3 ; 650 4.16 3 ; 633 4.16 3 ; 634 0.48 3 ; 671 4.16 3 ; 645 4.16 2 ; 646 4.16 2 ; 692 4.16 3 ; 675 4.16 3 ; 611 4.16 1 ; 652 4.16 1 ; 670 4.16 3 ; 632 4.16 3 ; 680 4.16 3 ; 684 4.16 2};
V_nominal = string(V_nominal);

end


%-------------------------------------------------------------
% DEFINIR PUNTOS DE CARGA VE (VE_13BusTestFeeder.txt)
%-------------------------------------------------------------
% Cada fila del .txt corresponde a una fuente de corriente
% Las columnas representan las siguientes variables:
% | hora_c | tipo_c | n_coches | bus_conn | fases | fdp


file_VE = fopen('VE_13BusTestFeeder.txt');
C_format = textscan(file_VE, '%f %f %f %s %f %f');
fclose(file_VE);

% Lectura de las variables del .txt

VE_hora_c = C_format{1};
VE_tipo_c = C_format{2};
VE_n_coches = C_format{3};
VE_bus_conn = string(C_format{4});
VE_fases = C_format{5};
VE_fdp = C_format{6};


%-------------------------------------------------------------
% DEFINIR CARGAS (Cargas_13BusTestFeeder.txt)
%-------------------------------------------------------------
% Cada fila del .txt corresponde a una fuente de corriente
% Las columnas representan las siguientes variables:
% | modelo | bus_conn | fases | conn | V | P | Q


file_Carga = fopen('Cargas_13BusTestFeeder.txt');
C_format = textscan(file_Carga, '%f %s %s %s %f %f');
fclose(file_Carga);

% Lectura de las variables del .txt

Carga_modelo = C_format{1};
Carga_bus_conn = string(C_format{2});
Carga_fases = string(C_format{3});
Carga_conn = string(C_format{4});
Carga_P = C_format{5};
Carga_Q = C_format{6};



%-------------------------------------------------------------
% DEFINIR TIEMPO DEL SIMULADOR EN SEGUNDOS
%-------------------------------------------------------------

    t_inicio = t_inicio * 3600;
    t_fin = t_fin * 3600;

    nbr_DeltaT = (t_fin-t_inicio)/DeltaT;

%-------------------------------------------------------------
% ESTUDIO EN EL TIEMPO
%-------------------------------------------------------------
t_0 = 0;

for t = t_inicio:DeltaT:t_fin 

t_0 = t_0 + 1;

% CREACCIÓN DEL ARCHIVO IEEE13Cargas.dss

[Cargas_P] = Function_CargasDSS(Carga_bus_conn, Carga_fases, Carga_conn, Carga_P, Carga_Q, Carga_modelo, V_nominal, t);

% CREACCIÓN DEL ARCHIVO IEEE13VE.dss

[VE_P] = Function_VE_DSS(VE_bus_conn, VE_fases, VE_fdp, VE_hora_c, VE_n_coches, VE_tipo_c, V_nominal, t);


% LLAMAMIENTO A OPENDSS PARA EXTRAER RESULTADOS

Function_MATLAB_OPENDSS(Main_dss)

% EXPORTAMOS LOS RESULTADOS DEL .CSV A MATLAB

Table_Voltage_data = readtable('IEEE13Nodeckt_EXP_VOLTAGES.CSV', 'Format','%s %s %s %s %s %s %s %s %s %s %s %s %s %s');
Voltage_data = table2array(Table_Voltage_data);
Voltage_data = string(Voltage_data);


Dim_Voltage_data = size(Voltage_data);

for i = 1:Dim_Voltage_data(1)

    if Voltage_data(i,7) == '3'

        % Movemos los valores de cada fase a su columna correspondiente
        Voltage_data(i,14) = Voltage_data(i,10);
        Voltage_data(i,13) = Voltage_data(i,9);
        Voltage_data(i,12) = Voltage_data(i,8);
        Voltage_data(i,11) = Voltage_data(i,7);

        % Evitamos que se dupliquen los valores de las tensiones

        Voltage_data(i,10) = '0';
        Voltage_data(i,9) = '0';
        Voltage_data(i,8) = '0';
        Voltage_data(i,7) = '0';
    else
    end
end

% DAMOS FORMATO A LOS RESULTADOS

for i = 1:Dim_Voltage_data(1)

    if Voltage_data(i,3) == '3'

        % Movemos los valores de cada fase a su columna correspondiente
        Voltage_data(i,14) = Voltage_data(i,6);
        Voltage_data(i,13) = Voltage_data(i,5);
        Voltage_data(i,12) = Voltage_data(i,4);
        Voltage_data(i,11) = Voltage_data(i,3);

        % Evitamos que se dupliquen los valores de las tensiones

        Voltage_data(i,6) = '0';
        Voltage_data(i,5) = '0';
        Voltage_data(i,4) = '0';
        Voltage_data(i,3) = '0';

    elseif Voltage_data(i,3) == '2'

        % Movemos los valores de cada fase a su columna correspondiente
        Voltage_data(i,10) = Voltage_data(i,6);
        Voltage_data(i,9) = Voltage_data(i,5);
        Voltage_data(i,8) = Voltage_data(i,4);
        Voltage_data(i,7) = Voltage_data(i,3);

        % Evitamos que se dupliquen los valores de las tensiones

        Voltage_data(i,6) = '0';
        Voltage_data(i,5) = '0';
        Voltage_data(i,4) = '0';
        Voltage_data(i,3) = '0';

    else
    end

end


% FUNCIÓN RESUMEN\_RESULTADOS (Muestra valor y el nodo fuera de límites predefinidos; y
% almacena los cálculos en una variable)


if t_0 <= 1

    Resumen_Resultados = [];
    [RESUMEN_RESULTADOS] = Function_Resumen_Resultados(V_nominal, Voltage_data,Carga_P, VE_P, Cargas_P, t_0, t, Resumen_Resultados);
    Resumen_Resultados = RESUMEN_RESULTADOS;   

else

    [RESUMEN_RESULTADOS] = Function_Resumen_Resultados(V_nominal, Voltage_data,Carga_P, VE_P, Cargas_P, t_0, t, Resumen_Resultados);
    Resumen_Resultados = RESUMEN_RESULTADOS;   
end



% ALMACENAMOS LOS VALORES DE TENSIÓN EN UNA VARIABLE TRIDIEMENSIONAL. ALMACENAMOS ADICIONALMENTE LOS
% VALORES DE t EN LA VARIABLE T

if t_0 <= 1

    Voltage_data_3D = Voltage_data;
    T = t;
else
    Voltage_data_3D(:,:,t_0) = Voltage_data;
    T = [T;t];
end

end


%-------------------------------------------------------------
% PLOTTER 
%-------------------------------------------------------------

% GRAFICAR TENSIÓN A LO LARGO DEL TIEMPO

num_buses = size(Voltage_data,1);
nom_buses = strrep(Voltage_data(:,1),"""","");


figure_1 = figure('Name','Perfiles de tensión de los buses','NumberTitle','off');
set(figure_1, 'units', 'normalized', 'position', [0 0 1 0.9]);

for i = 1:num_buses

    nom_legend_1 = strcat(nom_buses(i),'.',Voltage_data_3D(i,3,1));
    aux = split(nom_legend_1,'.');

    if aux(2) == '0'
        nom_legend_1 = '';
    else
    end

    nom_legend_2 = strcat(nom_buses(i),'.',Voltage_data_3D(i,7,1));
    aux = split(nom_legend_2,'.');

    if aux(2) == '0'
        nom_legend_2 = '';
    else
    end

    nom_legend_3 = strcat(nom_buses(i),'.',Voltage_data_3D(i,11,1));
    aux = split(nom_legend_3,'.');

    if aux(2) == '0'
        nom_legend_3 = '';
    else
    end

    Y = [squeeze(Voltage_data_3D(i,6,:)) squeeze(Voltage_data_3D(i,10,:)) squeeze(Voltage_data_3D(i,14,:))];
    Y = str2double(Y);

    subplot(round(num_buses/4,0),4,i);


    plot(T/3600,Y(:,1));
    hold on
    plot(T/3600,Y(:,2));
    hold on
    plot(T/3600,Y(:,3));
    ylim([0.85 1.15])
    ylabel('Voltaje (pu)')
    xlabel('Tiempo (h)')
    grid on;

    title(strcat('Voltaje bus',{' '}, nom_buses(i)));
    legend({nom_legend_1, nom_legend_2, nom_legend_3},'Location','northeast');
    
end


% Graficamos los valores de la tensión en pu

figure_2 = figure('Name','Rango del voltaje durante la simulación','NumberTitle','off');
set(figure_2, 'units', 'normalized', 'position', [0 0 1 0.9]);

newcolors = {'#FFFFFF', '#D95319'}; % Blanco y  Naranja
colororder(newcolors)

Y_plot = zeros(length(T),2);

for z = 1:t_0

    Y = [squeeze(Voltage_data_3D(:,6,z)) squeeze(Voltage_data_3D(:,10,z)) squeeze(Voltage_data_3D(:,14,z))];
    Y = str2double(Y);

    Y_max = max(Y,[],"all");
    Y_min = min(Y(Y>0),[],"all");


    Y_plot(z,1) = Y_min;
    Y_plot(z,2) = Y_max-Y_min;

end

area([T./3600 T./3600], Y_plot)
set(gca,'fontsize',22)
ylabel('Voltaje (pu)')
xlabel('Tiempo (h)')
ylim([0.85 1.15])

% EXPORTAMOS LAS GRÁFICAS EN FORMATO .PNG

path = 'F:\0. CARLETES\MÁSTER\Masters\TFM\Tema definitivo\0. Código Matlab\Resultados gráficos\';

exportgraphics(figure_1, strcat(path,Nom_case,'figura 1.png'))
exportgraphics(figure_2, strcat(path,Nom_case,'figura 2.png'))

%EXPORTAMOS EN UN .TXT LA VARIABLE RESUMEN_RESULTADOS

writematrix(RESUMEN_RESULTADOS, strcat(path,Nom_case,'RESUMEN_RESULTADOS.xlsx'));