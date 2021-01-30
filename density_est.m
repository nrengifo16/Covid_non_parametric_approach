function [f] = density_est (x, data, K,d)
% K==1 Kernel Uniforme
% K==2 Kernel Triangular
% K==3 Kernel Epanechnikov
% K==4 Kernel bicuadrado
% K==5 Kernel Gaussiano
% K==6 Kernel Tricubo
% K==7 Kernel Triweight
% K==8 Kernel Coseno
% K==9 Kernel logistico
% K==10 Kernel Sigmoide

[m, ~]=size(data);
h = mad(data)*m^(-1/(d+4)); % Ancho de banda
u = (x - data)/h;
switch K
    case 1
        I = 0.5*(-1<u & u<1) ;
    case 2
        I = (1-abs(u)).*(-1<u & u<1);
    case 3
        I = 0.75*(1-u.^2).*(-1<u & u<1);
    case 4
        I = (15/16)*(1-2*u.^2+u.^4).*(-1<u & u<1);
    case 5
        I = ((1/sqrt(2*pi))*exp(-0.5*u.^2));
    case 6 % Tricubo
        I = (70/81)*(1 - abs(u).^3).^3.*(-1 <= u & u <= 1);
    case 7 % Triweight
        I = (35/32)*(1 - u.^2).^3.*(-1 <= u & u <= 1);
   case 8 % Logistico
        I = 1./(exp(u) + 2 +exp(-u));
    case 9 % Sigmoide
        I = (2/pi)./(exp(u) + exp(-u));
end
f = 1/(m*h)*sum(I);
end