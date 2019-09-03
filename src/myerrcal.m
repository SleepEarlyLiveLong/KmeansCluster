function err = myerrcal(distance,X,C)
%MYERRCAL -Get total error between data set X and cluster ceters C.
%   
%   err = myerrcal(distance,X,C)
% 
%   Input - 
%   distance: a string representing the distance measure employed;
%   X: the input N*(P+1) matrix X with N points of P-dimension, where the
%      (P+1)th bit marks the cluster center it belongs to;
%   C: a k*P matrix containing the coordinate of k cluster centers.
%   Output - 
%   err: total error between data set X and cluster ceters C.
% 
%   Copyright (c) 2018 CHEN Tianyang
%   more info contact: tychen@whu.edu.cn

%%
if ~ischar(distance)
    error('Error! "distance" should be string.');
end
if ~ismatrix(X) || ~ismatrix(C)
    error('Error! You should put in 2 matrics.');
end

[N,~] = size(X);
[~,P] = size(C);
if size(X,2)~=size(C,2)+1
    error('Error! You should put in 2 matrics with correct size.');
end

err = 0;
if strcmp(distance,'sqEuclidean')
    for i=1:N
        err = err+sqrt( sum( (X(i,1:P)-C(X(i,P+1),:)).^2 ) );
    end
elseif strcmp(distance,'cityblock')
    for i=1:N
        err = err+sum( abs( X(i,1:P)-C(X(i,P+1),:) ) );
    end
elseif strcmp(distance,'cosine')
    for i=1:N
        err = err+mydist_cosine( X(i,1:P),C(X(i,P+1),:) );
    end
elseif strcmp(distance,'correlation')
    for i=1:N
        err = err+mydist_corre( X(i,1:P),C(X(i,P+1),:) );
    end
elseif strcmp(distance,'Hamming')
    for i=1:N
        err = err+mydist_hamm( X(i,1:P),C(X(i,P+1),:) );
    end
end

end
%% 