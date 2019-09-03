function dists = mydist(distance,temp,C)
%MYDIST -Draw the K-means clustering results.
%   
%   dists = mydist(distance,temp,C)
% 
%   Input - 
%   distance: a string representing the distance measure employed;
%   temp: temp = repmat(X(i,1:P),k,1), which means temp is a matrix
%         extended from the i(th) SINGLE data, a 1*P vector, to an
%         equivalent-in-row and k*P sized matrix.
%   C: a k*P matrix containing the coordinate of k cluster centers.
%   Output - 
%   dists: a k*1 vector containing the distance between the i(th) 
%          SINGLE data to each cluster center.
% 
%   Copyright (c) 2018 CHEN Tianyang
%   more info contact: tychen@whu.edu.cn

%% 
if ~ischar(distance)
    error('Error! "distance" should be string.');
end
if ~ismatrix(temp) || ~ismatrix(C)
    error('Error! You should put in 2 matrics.');
end
if size(temp)~=size(C)
    error('Error! You should put in 2 matrics..');
end

if strcmp(distance,'sqEuclidean')
    dists = sqrt(sum( (temp-C).^2 ,2));
elseif strcmp(distance,'cityblock')
    dists = sum(abs((temp-C)) ,2);
elseif strcmp(distance,'cosine')
    dists = mydist_cosine(temp,C);
elseif strcmp(distance,'correlation')
    dists = mydist_corre(temp,C);
elseif strcmp(distance,'Hamming')
    dists = mydist_hamm(temp,C);
end

end
%%