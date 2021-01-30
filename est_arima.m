function [error, Z] = est_arima(data_orig,ar,i,ma,num_pred)

data = data_orig(1:end-num_pred);
real = data_orig(end-num_pred+1:end);

Mdl = arima(ar, i , ma);
EstMdl = estimate(Mdl,data);
[Z,YMSE] = forecast(EstMdl,num_pred,data);

error = abs((real-Z)./real);
end