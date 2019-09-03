function matrix = mynumstatistic(vector)
%MYNUMSTATISTIC - To do data statistics for the input vector.
%   
%   matrix = myNumStatistic(vector)
% 
%   Input - 
%   vector: the input vector;
%   Output - 
%   matrix: statistical results, representing as a matrix.
% 
%   Copyright (c) 2018 CHEN Tianyang
%   more info contact: tychen@whu.edu.cn

%% 
raw = unique(vector);
matrix = zeros(length(raw),2);
matrix(:,1) = raw;
for i=1:length(raw)
    matrix(i,2) = length(find(vector==raw(i)));
end
if sum(matrix(:,2))~=length(vector)
    error('Error!');
end

end
%%