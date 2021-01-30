%% Importar datos
clear all
clc
close all
ker = ["Uniform", "Triangular", "Epanechnikov", "Bi-squared", "Gaussian",...
    "Tricube","Triweight","Cosinus","Logistic","Sigmoide"];

% Inflación
% data_orig = xlsread('inflacion.xlsx','Hoja1');
% data_orig = data_orig(1:end,2);
% data = data_orig(1:end); % Serie de tiempo
% caso = 1;

% TRM
% data_orig = xlsread('saw.dll.xlsx','Sheet2');
% data_orig = data_orig(10337:end,1);
% data = data_orig(1:end); % Serie de tiempo
% caso = 1;

% Agua
% data_orig = xlsread('Libro1.xlsm','Sheet1');
% data = data_orig(1:end,1);
% caso = 2;

% Caudales
% data_orig = xlsread('caudales.xlsx','Hoja2');
% data = data_orig(1:end);
% caso = 3;

% UCI
% data = xlsread('uci_acumulado.xlsx','Sheet1');
% data_orig = data(1:end,3);
% data = data(1:end,3);
% caso = 4;

% Casos confirmados
% datac = xlsread('casos.xlsx', 'Colombia');% 1 muertes acu,2 casos acum, 3 casos ln
% data_orig = datac(1:end,3);
% caso = 4;

% Geología acumulado
% data_orig = xlsread('CALAMAR-Q_Mensual 1940-2020.xlsx',...
%     'CALAMAR-Q_Mensual 1940-2015');
% data_orig = data_orig(:,2:13);
% data_orig = reshape(data_orig,[],1);
% data = data_orig(1:end);
% caso = 5;

% Geología mensual
% data_orig = xlsread('CALAMAR-Q_Mensual 1940-2020.xlsx',...
%     'CALAMAR-Q_Mensual 1940-2015');
% mes = 1;
% data_orig = data_orig(1:end,mes+1);
% caso = 7 + mes - 1;

% Dengue
ciudades = ["bello","itagui","medellin","neiva","riohacha"];
num_ciud = 5;
data_orig = xlsread(['data_dengue\',char(ciudades(num_ciud)),'\dengue.csv']);
data_orig = data_orig(:,3);

%% Análisis exploratorio
num_pred = 10;
data = data_orig(1:end-num_pred);
Real = data_orig(end-num_pred+1:end);

figure
nexttile
plot(data)
title('Data')
nexttile
parcorr(data,'NumLags',20)
title('PACF')

dif = 1;
data = diff(data,dif);
figure
nexttile
plot(data)
title(['Data (diff = ',num2str(dif),')'])
nexttile
parcorr(data,'NumLags',20)

%% Parámetros y simulación
coef = xlsread('arima_coef.xlsx','Sheet1');
% d = coef(caso,6); kernel = coef(caso,7);
[d, kernel] = bestNP(data_orig,num_pred,1); 

ar = coef(caso,1);
i = coef(caso,2);
ma = coef(caso,3);

[error_np, Z_np] = est_np_d(data_orig,d,kernel,num_pred);
[error_arima, Z_arima] = est_arima_d(data_orig,ar,i,ma,num_pred);
table(Real,Z_np,Z_arima,error_np,error_arima)

%% Validación arima
if ( ar > 0)
if ( i > 0 )
    data = diff(data,i);
end
[~,pValue_pp,tstat_pp] = pptest(data,'lags',1:ar); % H0: estacionaria
[~,pValue_df,tstatdf] = adftest(data,'lags',1:ar); % H0: estacionaria
[~,pValue_kpss,tstat_kpss] = kpsstest(data,'Lags',1:ar,'Trend',true); % H0: No estacionaria
min_pValue_pp = min(pValue_pp);
min_pValue_df = min(pValue_df);
max_pValue_kpss = max(pValue_kpss);
table(min_pValue_pp,min_pValue_df,max_pValue_kpss)
end
%% Resultados
if ( length(Z_np) > 1)
    ttl = [num2str(num_pred),' Periods ', 'daily Forecast. ',' NP: d = ',num2str(d),...
    ', ',ker(kernel),' Kernel.  ARIMA: (',num2str(ar),',',num2str(i),',',...
    num2str(ma),')'];
figure
nexttile
plot(data_orig,'-r','LineWidth',1)
hold on
plot(length(data_orig)-num_pred+1:length(data_orig),Z_np,'o-b','LineWidth',0.2)
hold on
plot(length(data_orig)-num_pred+1:length(data_orig),Z_arima,'*-k','LineWidth',0.2)
title(join(ttl))
legend('Real','Est NP','Est ARIMA','Location','best')
axis([1 length(data_orig) 0 1.1*max(max(Z_arima),max(max(data_orig),max(Z_np)))])

nexttile
plot(Real,'s-r','LineWidth',1)
hold on
plot(Z_np,'o-b','LineWidth',0.9)
hold on
plot(Z_arima,'*-k','LineWidth',0.9)
legend('Real','Est NP','Est ARIMA','Location','best')
% axis([1 num_pred 0 1.1*max(max(Z_arima),max(max(Real),max(Z_np)))])

figure
plot(error_np,'o-b','LineWidth',0.3)
hold on
plot(error_arima,'*-k','LineWidth',0.3)
title('Percentage error')
legend('Est NP','Est arima')
axis([1 num_pred 0 1.1*max(max(error_np),max(error_arima))])

end