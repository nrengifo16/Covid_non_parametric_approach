%% Importar datos
clear all
clc
close all
ker = ["Uniform", "Triangular", "Epanechnikov", "Bi-squared", "Gaussian",...
    "Tricube","Triweight","Cosinus","Logistic","Sigmoide"];

% Dengue, desde [2008 - 2015]
ciudades = ["medellin","bello","riohacha","neiva","itagui"];
cases = [1 1 1 2 2 2 3 3 3];
weeks = [4 8 12 4 8 12 4 8 12];

parfor experim = 1:9
num_ciud = cases(experim); caso = num_ciud;
data_orig = xlsread(['data_dengue\',char(ciudades(num_ciud)),'\dengue.csv']);

%% Análisis exploratorio
num_pred = weeks(experim);
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
    ttl = [num2str(num_pred),' peridos ', 'con pronóstico semanal. ',' NP: d = ',num2str(d),...
    ', ',ker(kernel),' Kernel.  ARIMA: (',num2str(ar),',',num2str(i),',',...
    num2str(ma),')'];

fig1 = figure('Name','Forecast');
nexttile
plot(data_orig,'-r','LineWidth',1)
hold on
plot(length(data_orig)-num_pred+1:length(data_orig),Z_np,'o-b','LineWidth',0.2)
plot(length(data_orig)-num_pred+1:length(data_orig),Z_arima,'*-k','LineWidth',0.2)
title(join(ttl))
legend('Real','Est NP','Est ARIMA','Location','best')
axis([1 length(data_orig) 0 1.1*max(max(Z_arima),max(max(data_orig),max(Z_np)))])
hold off

nexttile
plot(Real,'s-r','LineWidth',1)
hold on
plot(Z_np,'o-b','LineWidth',0.9)
plot(Z_arima,'*-k','LineWidth',0.9)
legend('Real','Est NP','Est ARIMA','Location','best')
axis([1 num_pred 0 1.1*max(max(Z_arima),max(max(Real),max(Z_np)))])
hold off
saveas(gcf,['imgs\',char(ciudades(num_ciud)),'_',num2str(num_pred),'_pred'],'jpeg');


fig2 = figure('Name','error');
plot(error_np,'o-b','LineWidth',0.3)
hold on
plot(error_arima,'*-k','LineWidth',0.3)
title('Percentage error')
legend('Est NP','Est arima')
axis([1 num_pred 0 1.1*max(max(error_np),max(error_arima))])
saveas(gcf,['imgs\',char(ciudades(num_ciud)),'_',num2str(num_pred),'_err'],'jpeg');
end
end