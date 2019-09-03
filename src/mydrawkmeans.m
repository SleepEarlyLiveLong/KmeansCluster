function mydrawkmeans(X,C)
%MYDRAWKMEANS -Draw the K-means clustering results.
%   
%   mydrawkmeans(X,C)
% 
%   Input - 
%   X: the input N*(P+1) matrix X with N points of P-dimension, where the
%      (P+1)th bit marks the cluster center it belongs to;
%   C: a k*P matrix containing the coordinate of k cluster centers.
%   Output - 
%   No output parameter.
% 
%   Copyright (c) 2018 CHEN Tianyang
%   more info contact: tychen@whu.edu.cn

[datanum,S] = size(X);
[classnum,P] = size(C);
if S~=P+1
    error('Error!');
end
numstatistic = mynumstatistic(X(:,S));
Pattern = repmat(struct('Class',1,...
    'Num',zeros(min(numstatistic(:,2)),2)),classnum,1);
for i=1:classnum
    Pattern(i).Class = i;
end
k=ones(classnum,1);
for i=1:datanum
    Pattern(X(i,S)).Num(k(X(i,S)),:) = X(i,1:P);
    k(X(i,S)) = k(X(i,S))+1;
end
figure;
color = ['r','g','b','y','k','m','c'];
for i=1:classnum
    plot(Pattern(i).Num(:,1),Pattern(i).Num(:,2),'*','color',color(mod(i,7)+1));hold on;
    plot(C(i,1),C(i,2),'ro','linewidth',3);hold on;
end
    
end