function [VE_P] = Function_VE_DSS(VE_bus_conn, VE_fases, VE_fdp, VE_hora_c, VE_n_coches, VE_tipo_c, V_nominal, t)

% Nissan Leaf: Capacidad de la batería 40 kWh

VE_CapBat = 40;


VE_P = 0;

% CREAMOS EL IEEE13VE.DSS

fileID = fopen("IEEE13VE.dss", 'w');

formatSpec = 'New Load.%s Bus1=%s Phases=%s Conn=Wye Model=1 kV=%s  kW=%s  kvar=%s \n';

for i = 1:length(VE_bus_conn)

        % Parámetros VE en función de la estrategia de carga

        if VE_tipo_c(i)==1 %Low Charge
            P = 3.7;  %kW
            %     V = 0.23; %kV
            t_carga = (VE_CapBat/P)*3600*0.6;

        elseif VE_tipo_c(i)==2 % Semi-fast Charge

            if VE_fases == 3
                P = 22;
                %         V = 0.4;
                t_carga = (VE_CapBat/P)*3600*0.6;

            else
                P = 7.4;
                %         V = 0.23;
                t_carga = (VE_CapBat/P)*3600*0.6;

            end

        else  % Fast Charge

            P = 50;
            %     V = 0.125;
            t_carga = (VE_CapBat/P)*3600*0.6;


        end


     if (t>=VE_hora_c(i)*3600) && (t<VE_hora_c(i)*3600+t_carga)
   
        % Calculamos la tensión nominal de la carga acorde a la conexión
        % definida
        
        VE_bus = strsplit(VE_bus_conn(i),'.');
        [row,~] = find(V_nominal(:,1) == VE_bus(1));

        if strcmp(VE_bus_conn(i),'Delta')

            V = str2double(V_nominal(row,2));
        else

            V = str2double(V_nominal(row,2))/sqrt(3);
        end


        Q = P*tan(acos(VE_fdp(i)));


        if VE_tipo_c(i) == 1 % nombre VE carga lenta
            VE_nom = strcat(VE_bus_conn(i),'_L_VE');

        elseif VE_tipo_c(i) == 2 % nombre VE carga semi-rápida
            VE_nom = strcat(VE_bus_conn(i),'_M_VE');

        else % nombre VE carga rápida
            VE_nom = strcat(VE_bus_conn(i),'_R_VE');

        end


        fprintf(fileID, formatSpec, VE_nom, VE_bus_conn(i), num2str(VE_fases(i)), num2str(V), num2str(P*VE_n_coches(i)), num2str(Q*VE_n_coches(i)));

        % Almacenamos el valor total de la potencia demandada por los VE
        % para cada instante de tiempo

        VE_P = VE_P + P*VE_n_coches(i);

     else % t<hi

     end

end

fclose(fileID);

end
