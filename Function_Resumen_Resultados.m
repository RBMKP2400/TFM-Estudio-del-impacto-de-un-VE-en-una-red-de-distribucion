function  [RESUMEN_RESULTADOS] = Function_Resumen_Resultados(V_nominal, Voltage_data, Carga_P, VE_P, Cargas_P, t_0, t, Resumen_Resultados)

% DEFINIR LIMITES DEL SISTEMA

Lim_V_max = 1.1;
Lim_V_min = 0.9;
Lim_P = 5000;
Lim_Kd = 3;

%CALCULAMOS LOS VALORES MÁXIMOS DE LOS PARÁMETROS LIMITANTES PARA CADA
%INSTANTE DE TIEMPO

num_buses = size(Voltage_data,1);
nom_buses = strrep(Voltage_data(:,1),"""","");


V = [Voltage_data(:,6) Voltage_data(:,10) Voltage_data(:,14)];
V = str2double(V);
V_max = max(V,[],"all");  
V_min = min(V(V>0),[],"all");

[row1,~] = find(V(:,:) == V_max);
[row2,~] = find(V(:,:) == V_min);
row1 = unique(row1);
row2 = unique(row2);

P_total = Cargas_P + VE_P;

P_usuario = sum(Carga_P,"all") + VE_P;


% ALMACENAMOS LOS VALORES EN UNA VARIABLE

if t_0 <= 1

    RESUMEN_RESULTADOS = ["P_Cargas+VE = " P_usuario;"Tiempo ="  num2str(t/3600)];
    Count_rows = size(RESUMEN_RESULTADOS,1);

    for i = 1:length(row1)

        RESUMEN_RESULTADOS = [RESUMEN_RESULTADOS; strcat('V_max_', nom_buses(row1(i),1), ' = ') num2str(V_max)];

%         if str2double(RESUMEN_RESULTADOS(i+1,2)) >= Lim_V_max
%             disp(RESUMEN_RESULTADOS(Count_rows,1) + RESUMEN_RESULTADOS(Count_rows,2));
%             disp(RESUMEN_RESULTADOS(i+1,1) + RESUMEN_RESULTADOS(i+1,2));
%         else
%         end
    end

    for j = 1:length(row2)

        RESUMEN_RESULTADOS = [RESUMEN_RESULTADOS; strcat('V_min_', nom_buses(row2(j),1), ' = ') num2str(V_min)];

        if str2double(RESUMEN_RESULTADOS(j+i+1,2)) <= Lim_V_min
            disp(RESUMEN_RESULTADOS(Count_rows,1) + RESUMEN_RESULTADOS(Count_rows,2));
            disp(RESUMEN_RESULTADOS(j+i+1,1) + RESUMEN_RESULTADOS(j+i+1,2));
        else
        end
    end

    RESUMEN_RESULTADOS = [RESUMEN_RESULTADOS; strcat('P_total_', num2str(t/3600), ' = ') {num2str(P_total)}];

    if str2double(RESUMEN_RESULTADOS(j+i+2,2)) >= Lim_P
        disp(RESUMEN_RESULTADOS(Count_rows,1) + RESUMEN_RESULTADOS(Count_rows,2));
        disp(RESUMEN_RESULTADOS(j+i+2,1) + RESUMEN_RESULTADOS(j+i+2,2));
    else
    end

    %Teorema de Fortescue

    m = 0;
    for k = 1:num_buses

        if strcmp(V_nominal(k,3), '3')

            V_complex = [str2double(Voltage_data(k,4))*complex(cosd(str2double(Voltage_data(k,5))), sind(str2double(Voltage_data(k,5)))); str2double(Voltage_data(k,8))*complex(cosd(str2double(Voltage_data(k,9))), sind(str2double(Voltage_data(k,9)))); str2double(Voltage_data(k,12))*complex(cosd(str2double(Voltage_data(k,13))), sind(str2double(Voltage_data(k,13))))];
            Fortescue_a = complex(-0.5,sqrt(3)/2);
            Fortescue_A = [1 1 1; 1 Fortescue_a^2 Fortescue_a; 1 Fortescue_a Fortescue_a^2];
            Fortescue_V = Fortescue_A\V_complex;

            kd = 100*abs(Fortescue_V(3))/abs(Fortescue_V(2));

            RESUMEN_RESULTADOS = [RESUMEN_RESULTADOS; strcat('kd_', nom_buses(k,1), ' = ') num2str(kd)];

            m = m+1;

        else
           
        end

    end

    if str2double(RESUMEN_RESULTADOS(1+j+i+2,2)) >= Lim_Kd
        disp(RESUMEN_RESULTADOS(Count_rows,1) + RESUMEN_RESULTADOS(Count_rows,2));
        disp(RESUMEN_RESULTADOS(1+j+i+2,1) + RESUMEN_RESULTADOS(1+j+i+2,2));
    else
    end

else

    RESUMEN_RESULTADOS = Resumen_Resultados;
    RESUMEN_RESULTADOS = [RESUMEN_RESULTADOS;"" "";"Tiempo ="  num2str(t/3600)];
    Count_rows = length(RESUMEN_RESULTADOS);

    for i = 1:length(row1)
        
        RESUMEN_RESULTADOS = [RESUMEN_RESULTADOS; strcat('V_max_', nom_buses(row1(i),1), ' = ') num2str(V_max)];

%         if str2double(RESUMEN_RESULTADOS(i,2)) >= Lim_V_max
%             disp(RESUMEN_RESULTADOS(Count_rows,1) + RESUMEN_RESULTADOS(Count_rows,2));
%             disp(RESUMEN_RESULTADOS(i+Count_rows,1) + RESUMEN_RESULTADOS(i+Count_rows,2));
%         else
%         end
    end

    for j = 1:length(row2)

        RESUMEN_RESULTADOS = [RESUMEN_RESULTADOS; strcat('V_min_', nom_buses(row2(j),1), ' = ') num2str(V_min)];

        if str2double(RESUMEN_RESULTADOS(j+i+Count_rows,2)) <= Lim_V_min
            disp(RESUMEN_RESULTADOS(Count_rows,1) + RESUMEN_RESULTADOS(Count_rows,2));
            disp(RESUMEN_RESULTADOS(j+i+Count_rows,1) + RESUMEN_RESULTADOS(j+i+Count_rows,2));
        else
        end
    end

    RESUMEN_RESULTADOS = [RESUMEN_RESULTADOS; strcat('P_total_', num2str(t/3600), ' = ') {num2str(P_total)}];

    if str2double(RESUMEN_RESULTADOS(j+i+Count_rows+1,2)) >= Lim_P
        disp(RESUMEN_RESULTADOS(Count_rows,1) + RESUMEN_RESULTADOS(Count_rows,2));
        disp(RESUMEN_RESULTADOS(j+i+Count_rows+1,1) + RESUMEN_RESULTADOS(j+i+Count_rows+1,2));
    else
    end

    %Teorema de Fortescue

    m = 0;
    for k = 1:num_buses
  
        if strcmp(V_nominal(k,3), '3')

            V_complex = [str2double(Voltage_data(k,4))*complex(cosd(str2double(Voltage_data(k,5))), sind(str2double(Voltage_data(k,5)))); str2double(Voltage_data(k,8))*complex(cosd(str2double(Voltage_data(k,9))), sind(str2double(Voltage_data(k,9)))); str2double(Voltage_data(k,12))*complex(cosd(str2double(Voltage_data(k,13))), sind(str2double(Voltage_data(k,13))))];
            Fortescue_a = complex(-0.5,sqrt(3)/2);
            Fortescue_A = [1 1 1; 1 Fortescue_a^2 Fortescue_a; 1 Fortescue_a Fortescue_a^2];
            Fortescue_V = Fortescue_A\V_complex;

            kd = 100*abs(Fortescue_V(3))/abs(Fortescue_V(2));

            RESUMEN_RESULTADOS = [RESUMEN_RESULTADOS; strcat('kd_', nom_buses(k,1), ' = ') num2str(kd)];

            m = m+1;

        else
           
        end

    end

    if str2double(RESUMEN_RESULTADOS(1+j+i+Count_rows+1,2)) >= Lim_Kd
        disp(RESUMEN_RESULTADOS(Count_rows,1) + RESUMEN_RESULTADOS(Count_rows,2));
        disp(RESUMEN_RESULTADOS(1+j+i+Count_rows+1,1) + RESUMEN_RESULTADOS(1+j+i+Count_rows+1,2));
    else
    end


end


end
