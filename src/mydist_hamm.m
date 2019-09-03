function C = mydist_hamm(A,B)
%MYDIST_HAMM - K-means clustering distance calculation.
%   To calculate the HAMMING distance between points and corresponding 
%   centers.
%   
%   C = mydist_hamm(A,B)
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
if fix(A)~=A || fix(B)~=B
    warning('Warning! Hamming distance is supposed for intergers.');
end

[m,n] = size(A);
C = zeros(m,1);

for i=1:m
    for j=1:n
        if(A(i,j)~=B(i,j))
            C(i)=C(i)+1;
        end
    end
end

end
%%