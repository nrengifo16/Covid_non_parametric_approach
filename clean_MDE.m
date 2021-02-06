clear all;clc;

file1 = xlsread('data_dengue\medellin\dengue_2008.csv');
file1 = file1(:,2);
file2 = xlsread('data_dengue\medellin\dengue_2009.csv');
file2 = file2(:,2);
file3 = xlsread('data_dengue\medellin\dengue_2010.csv');
file3 = file3(:,2);
file4 = xlsread('data_dengue\medellin\dengue_2011.csv' );
file4 = file4(:,2);
file5 = xlsread('data_dengue\medellin\dengue_2012.csv' );
file5 = file5(:,2);
file6 = xlsread('data_dengue\medellin\dengue_2013.csv' );
file6 = file6(:,2);
file7 = xlsread('data_dengue\medellin\dengue_2014.csv' );
file7 = file7(:,2);
file8 = xlsread('data_dengue\medellin\dengue_2015.csv' );
file8 = file8(:,2);
file9 = xlsread('data_dengue\medellin\dengue_2016.csv' );
file9 = file9(:,2);

file = [file1;file2;file3;file4;file5;file6;file7;file8;file9];
n = length(file);
serie = [];

cont = 0;
for i = 1: n-1
    if (file(i) == file(i+1))
        cont = cont + 1;
    else
        serie = [serie;cont];
        cont = 0;
    end    
    i/n
end

dengue = serie(1:419);
csvwrite('data_dengue\medellin\dengue.csv',dengue)