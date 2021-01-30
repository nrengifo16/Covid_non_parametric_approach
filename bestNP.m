function [markov,kernel] = bestNP(data_orig,num_pred,daily)
% Find the better combination of parameters for NP forecasting method.
data = data_orig(1:end-num_pred);
[a, b ,c] = parcorr(diff(data,1),'NumLags',round(length(data)/4));
cand_d = [b( a>c(1) | a<c(2));round(length(data)/4)];
cont = 0;
Wait = waitbar(0,'Loading');
for i = 1:length(cand_d)
    if(cand_d(i)>3)
        for j = 1:9
            if(daily == 0)
                [error, ~] = est_np(data_orig,cand_d(i),j,num_pred);
            else
                [error, ~] = est_np_d(data_orig,cand_d(i),j,num_pred);
            end
            if ( cont == 0)
                best = [sum(error),cand_d(i),j];
            end
            if(sum(error) < best(1))
                best = [sum(error),cand_d(i),j];
            end
            cont = cont +1;
        end
        waitbar(i/length(cand_d),Wait,'Loading');
    end
end
markov = best(2); kernel = best(3);
close(Wait)
end

