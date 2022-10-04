function [Cargas_P] = Function_CargasDSS(Carga_bus_conn, Carga_fases, Carga_conn, Carga_P, Carga_Q, Carga_modelo, V_nominal, t)

Pct_Industrial = 0.15;
Pct_Residencial = 0.60;
Pct_Comercial = 0.25;

% PROMEDIO HORARIO DE LOS PERFILES ANUALES DE DEMANDA DEL 2022 (FUENTE REE)

Perfil_REE_2022 = [0 1.28969448180044E-04 9.62799486007896E-05 8.70513818787088E-05; 1 1.05526038492838E-04 8.88558424629452E-05 6.24522666681169E-05 ; 2 8.8145161220419E-05 8.36564858823025E-05 4.27388770965206E-05 ; 3 7.80159413571519E-05 8.11894511880169E-05 3.42057546197133E-05 ; 4 7.28042590203729E-05 8.01161503967309E-05 2.58059094220854E-05 ; 5 7.06283957722724E-05 8.00677422033029E-05 2.39975074584467E-05 ; 6 7.17378001176773E-05 8.22881493499891E-05 2.70695897975953E-05 ; 7 7.805205672106E-05 8.9096111710854E-05 2.97776021740572E-05 ; 8 9.14658293215728E-05 1.00246387261607E-04 4.0542923060647E-05 ; 9 1.03378035997829E-04 1.21857154214056E-04 8.02893861637603E-05 ; 10 1.14325917725207E-04 1.38797216342548E-04 1.32448268420028E-04 ; 11 1.23645444587623E-04 1.4700890238616E-04 1.6898402417678E-04 ; 12 1.26063191497592E-04 1.49371123692985E-04 1.77383911658002E-04 ; 13 1.27821328392874E-04 1.50967394649158E-04 1.74919238299656E-04 ; 14 1.34801042012579E-04 1.45491844280767E-04 1.81283703627632E-04 ; 15 1.35220970395944E-04 1.32048393645705E-04 1.81675995550113E-04 ; 16 1.25995576369252E-04 1.2597331073814E-04 1.77804177531373E-04 ; 17 1.20163369271209E-04 1.24920794607639E-04 1.68420167302753E-04 ; 18 1.20642572905311E-04 1.25322060633692E-04 1.60717227685759E-04 ; 19 1.27449747337916E-04 1.2649671333109E-04 1.59718893573604E-04 ; 20 1.36947485689424E-04 1.25754213369961E-04 1.63729695615994E-04 ; 21 1.4977477880731E-04 1.22198158373696E-04 1.63749490241007E-04 ; 22 1.59107324340057E-04 1.15794287269779E-04 1.52902808188254E-04 ; 23 1.50328063592018E-04 1.05872144062129E-04 1.21513482426202E-04 ; 24 1.28969448180044E-04 9.62799486007896E-05 8.70513818787088E-05];

% NORMALIZAMOS LOS DATOS PROMEDIOS DE LOS PERFILES TENIENDO EN CUENTA EL
% PORCENTAJE DE CADA CARGA

Nrm_modelo_carga_Industrial = normalize(Perfil_REE_2022(:,2),'range').*Pct_Industrial;
Nrm_modelo_carga_Residencial = normalize(Perfil_REE_2022(:,3),'range').*Pct_Residencial;
Nrm_modelo_carga_Comercial = normalize(Perfil_REE_2022(:,4),'range').*Pct_Comercial;

%SUMAMOS LOS VALORES NORMALIZADOS PARA OBTENER UNA ÚNICA CURVA Y LA
%NORMALIZAMOS

Sum_Nrm = Nrm_modelo_carga_Industrial + Nrm_modelo_carga_Residencial + Nrm_modelo_carga_Comercial;

% CREAMOS EL IEEE13CARGAS.DSS

fileID = fopen("IEEE13Cargas.dss", 'w');

formatSpec = 'New Load.%s Bus1=%s Phases=%s Conn=%s Model=1 kV=%s  kW=%s  kvar=%s \n';

Cargas_P = 0;
for i = 1:length(Carga_bus_conn)

    if Carga_modelo(i) == 0 % Modelo cargas constantes

        % Calculamos la tensión nominal de la carga acorde a la conexión
        % definida
        
        Carga_bus = strsplit(Carga_bus_conn(i),'.');
        [row,~] = find(V_nominal(:,1) == Carga_bus(1));

        if strcmp(Carga_conn(i),'Delta')

            Carga_V = str2double(V_nominal(row,2));
        else

            Carga_V = str2double(V_nominal(row,2))/sqrt(3);
        end

        fprintf(fileID, formatSpec, Carga_bus_conn(i), Carga_bus_conn(i), Carga_fases(i), Carga_conn(i), num2str(Carga_V), num2str(Carga_P(i)), num2str(Carga_Q(i)));
        
        % Almacenamos el valor total de la potencia demandada por las
        % Cargas para cada instante de tiempo

        Cargas_P = Cargas_P + Carga_P(i);

    elseif Carga_modelo(i) == 1 % Modelo cargas variables
        
        % Calculamos la tensión nominal de la carga acorde a la conexión
        % definida
        
        Carga_bus = strsplit(Carga_bus_conn(i),'.');
        [row,~] = find(V_nominal(:,1) == Carga_bus(1));

        if strcmp(Carga_conn(i),'Delta')

            Carga_V = str2double(V_nominal(row,2));
        else

            Carga_V = str2double(V_nominal(row,2))/sqrt(3);
        end

        % Calculamos P y Q para cada instante de tiempo

        Perfil_modelo_carga_P = [Perfil_REE_2022(:,1).*3600 normalize(Sum_Nrm,'range').*Carga_P(i)];
        Perfil_modelo_carga_Q = [Perfil_REE_2022(:,1).*3600 normalize(Sum_Nrm,'range').*Carga_Q(i)];

        
        % Interpolamos los valores de potencias no definidos en
        % Perfil\_modelo\_carga\_P y Perfil\_modelo\_carga\_Q

        if sum(t==Perfil_modelo_carga_P(:,1))== 1 %Es punto de la curva
            Nueva_P = Perfil_modelo_carga_P(t==Perfil_modelo_carga_P(:,1),2);
            Nueva_P = Nueva_P(1);
            Nueva_Q = Perfil_modelo_carga_Q(t==Perfil_modelo_carga_Q(:,1),2);
            Nueva_Q = Nueva_Q(1);

        else %no es un punto de la curva . Tenemos que interpolar
            Nueva_P = interp1(Perfil_modelo_carga_P(:,1),Perfil_modelo_carga_P(:,2),t);
            Nueva_P = Nueva_P(1);
            Nueva_Q = interp1(Perfil_modelo_carga_Q(:,1),Perfil_modelo_carga_Q(:,2),t);
            Nueva_Q = Nueva_Q(1);
        end
        
        fprintf(fileID, formatSpec, Carga_bus_conn(i), Carga_bus_conn(i), Carga_fases(i), Carga_conn(i), num2str(Carga_V), num2str(Nueva_P), num2str(Nueva_Q));
    
        % Almacenamos el valor total de la potencia demandada por las
        % Cargas para cada instante de tiempo

        Cargas_P = Cargas_P + Nueva_P;

    else

    end

end


fclose(fileID);


end