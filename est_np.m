function [error, Z_np] = est_np(data_orig,coef_MK,k,num_pred)
% Pronóstico no paramétrico a varios períodos
% data: Serie de tiempo
% d: Coeficiente de proceso Markoviano
% k: Kernel a emplear

data = data_orig(1:end-num_pred);
real = data_orig(end-num_pred+1:end);
dif = 1;
if(dif>0)
data = diff(data,dif);
end
% Parámetros
kernel = k;
d = coef_MK; % Coeficiente de Markov

for a = 1:num_pred
n = length(data);

m = a; % Fecha futura a estimar

% Armar el bloque de referencia 
X = zeros(d,n-d-m);

for i = 1:n-d-m
    X(:,i) = data(i:d+i-1);
    Y(i) = data(i+d+m);
end
[~, col] = size(X);

% Peso de elementos de traza
for j = 1:col
%     aux = sort(X(:,j))';
     aux = X(:,j)';
    for i = 1:d
        w_elem(i,j) = density_est(aux(i),aux,kernel,d);
    end
end

% Peso de traza
for j = 1:col
    acum = 1;
    for i = 1:d
        acum = acum * w_elem(i,j);     
    end
    w_traza(j) = acum;
end

% Vector de pesos por traza
W = w_traza/sum(w_traza);
% W=flip(W);%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Predictor de la media, m periodos hacia delante
% Z_pre(a) = dot(Y,W);
idx = find(W >= 0.007);
Z_pre(a) = mean(W(idx).*Y(idx));

if (dif > 0)
    if (a == 1)
       Z(a) = data_orig(end - num_pred + 1) + Z_pre(a);
    else
       Z(a) = Z_pre(a) + Z(a-1); 
    end
else 
    Z(a) = dot(Y,W);
end

end

error = abs((real-Z')./real);
Z_np = Z';
end