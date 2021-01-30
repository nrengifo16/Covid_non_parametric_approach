function [error, Z] = est_arima_d(data_orig,ar,i,ma,num_pred)

aux = data_orig(1:end-num_pred);
real = data_orig(end-num_pred+1:end);

Mdl = arima(ar, i , ma);
EstMdl = estimate(Mdl,aux);
[Z,~] = forecast(EstMdl,num_pred,aux);

error = abs((real-Z)./real);
end