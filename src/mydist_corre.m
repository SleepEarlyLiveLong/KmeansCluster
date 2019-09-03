function C = mydist_corre(A,B)
%MYDIST_CORRE - K-means clustering distance calculation.
%   To calculate the CORRELATION distance between points and corresponding 
%   centers.
%   
%   C = mydist_corre(A,B)
% 
%   Input - 
%   A: a k*P matrix whose raw means number of points and columns means the
%       dimensio;
%   B: a k*P matrix whose raw means number of points and columns means the
%       dimension.
%   Attention: one of them is the replicate(¸´ÖÆÆ½ÆÌ) of the coordinate of
%               a to-be-clustered point (replicate k times).
%   Output - 
%   C: a k*1 matrix comtaining the distance between the to-be-clustered 
%       point and each center.
% 
%   Copyright (c) 2018 CHEN Tianyang
%   more info contact: tychen@whu.edu.cn

%% 
if ~ismatrix(A) || ~isreal(B)
    error('Input parameter error! ');
end
if size(A)~=size(B)
    error('Input parameter should be of same size.');
end
[m,~] = size(A);
C = zeros(m,1);
% function 'corrcoef' gets correlation coefficient of 2 random variables
for i=1:m
    correcoff = corrcoef(A(i,:),B(i,:));
    C(i,1) = 1-correcoff(1,2);
end

end
%%