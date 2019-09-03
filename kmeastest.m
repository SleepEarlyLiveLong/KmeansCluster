%KMEANSTEST -Test file to examine the performance of the whole project.
% 
%   Note: You can choose different values of parameters such as 'num' and
%   'centers' and others to test the performance of function 'mykmeans'.
% 
%   Copyright (c) 2018 CHEN Tianyang
%   more info contact: tychen@whu.edu.cn

%% use function 'randn' get Guassian distributed points
clear; close all;
num = 40;
x1 = -2 + 1*randn(num,1);
y1 = 3 + 1*randn(num,1);
x2 = -4 + 1*randn(num,1);
y2 = -1 + 2*randn(num,1);
x3 = 5 + 1.5*randn(num,1);
y3 = 2 + 1.5*randn(num,1);
x4 = 1 + 1.2*randn(num,1);
y4 = -1 + 0.9*randn(num,1);
x5 = 3 + 1.1*randn(num,1);
y5 = -5 + 2*randn(num,1);
figure;
x = [x1;x2;x3;x4;x5];
y = [y1;y2;y3;y4;y5];
scatter(x,y);
X = [x,y];

%% kmeans clustering
centers = 5;
[Idx,C,sumD,D,Errlist] = mykmeans(X,centers);