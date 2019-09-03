function varargout = mykmeans(X,k,varargin)
%MYKMEANS - K-means clustering.
%   To divide the input data into k classes using the k-means algorithm.
%   
%   Idx = mykmeans(X,k)
%   Idx = mykmeans(X,k,DIM)
%   Idx = mykmeans(X,k,DIM,errdlt)
%   Idx = mykmeans(X,k,DIM,errdlt,replicates)
%   Idx = mykmeans(X,k,DIM,errdlt,replicates,Cin)
%   [Idx,C,sumD,D,Errlist] = mykmeans(...)
%   [...] = mykmeans(...,'Param1','Param2'...)  
% 
%   Input - 
%   X:          the input N*P matrix X with N points of P-dimension;
%   k:          the number of classes;
%   DIM:        1-the number of rows represents the number of points;
%               2-the number of columns represents the number of points;
%   errdlt:     the error between the last cluster and current cluster
%               that stops clustering;
%   replicates: the number of repeated clusters;
%   Cin:        the number of repeated clusters;
%   Param1:     distance
%   Val1:       sqEuclidean:    欧氏距离 Euclidean distance
%               cityblock:      曼哈顿距离 Manhattan Distance
%               cosine:         余弦距离-针对向量 Cosine distance
%               correlation:    相关距离 Correlation distance
%               Hamming:        汉明距离-针对字符串和数字量(整数) Hamming distance
%   Param2:     start
%   Val2:       sample:         随机选取 Random selection
%               plus  :         尽可能远选取 kmeans++ method
%               canopy:         (没有实现-因存在人为经验阈值故不适合)
%               matrix:         直接输入 Direct input
%   Output - 
%   Idx:        a N*1 vector containing the cluster number of each point;
%   C:          a k*P matrix containing the coordinate of k cluster centers;
%   sumD:       a k*1 vector containing the sum of distances between every cluster
%               center and its within-cluster points;
%   D:          a N*k vector containing the distance between each point and each
%               cluster center;
%   Errlist:    a vector containing the clusting error after each round.
% 
%   Copyright (c) 2018 CHEN Tianyang
%   more info contact: tychen@whu.edu.cn

%% 首先进行函数的初始化工作
% 参数数目检测
narginchk(2,8);
nargoutchk(1,5);

if ~ismatrix(X) || k<=0
    error('Input error!');
end
[N,P] = size(X);
if k>N
    error('Error! The unmber of classes must not be larger than the number of points.');
end

% 初始化聚类中心，默认随机
start = 'sample';
startset = {'sample','plus','canopy','cluster','matrix'};
if (nargin > 2 && ischar(varargin{end})) && any(strcmpi(varargin{end},startset))
    start = varargin{end};
    varargin(end)=[];
end

% 距离测度，默认欧氏距离
distance = 'sqEuclidean';
startset = {'sqEuclidean','cityblock','cosine','correlation','Hamming'};
if (nargin > 2 && ischar(varargin{end})) && any(strcmpi(varargin{end},startset))
    distance = varargin{end};
    varargin(end)=[];
end

% 获取剩余输入参数数目
narg = numel(varargin);
DIM = [];
errdlt = [];
replicates = [];
Cin = [];
% DIM,errdlt,replicates,Cin
switch narg
    case 0
    case 1
        DIM = varargin{:};
    case 2
        [DIM,errdlt] = varargin{:};
    case 3
        [DIM,errdlt,replicates] = varargin{:};
    case 4
        [DIM,errdlt,replicates,Cin] = varargin{:};
    otherwise
        error('Input parameter error!');
end

% 输入矩阵的行列意义
% 如果用户没提到，那就默认行数为点数、列数为维度数
if isempty(DIM)
    DIM = 1;
elseif DIM~=1 && DIM~=2
    error('Error! The parameter "DIM" should be specified correctly.');
end
% 若输入数据为列数为点数，则将数据改为行数为点数、列数为维度数
if DIM==2
     X = X';
end

%--- errdlt 和 replicates 都是控制cluster循环次数的量,优先考虑replicates
% 初始化运算次数上限
% 如果用户没提到，那就默认无上限
if isempty(replicates)
    limit_exist = 0;
elseif (replicates<=0) || (fix(replicates)~=replicates)
    error('Error! The operational limit must be a positive integer when specified.');
else
    limit_exist = 1;
end

% 初始化 errdlt-最小误差极限,即停止聚类循环的误差
% 如果用户没提到，得先看 replicates，再确定 errdlt
if isempty(errdlt)
    if limit_exist==0           % 既无最大循环次数，又无最小误差极限
        errdlt = 1;
        errdlt_exist = 0;
    else
        errdlt_exist = 1;
    end
end

% 初始化初始聚类中心
% 如果用户没提到，检测初始化方式
if isempty(Cin)
    if strcmpi(start,'matrix')
        errror('Error! A matrix must be put when "start" is chosen as "matrix".');
    end
else
    if ~strcmpi(start,'matrix')
        warning('Warning! A matrix is not required when "start" is not chosen as "matrix".');
    else
        if size(Cin,1)>N || size(Cin,2)~=P
            error('Error! The size of the initial clustering matrix is not correct.');
        end
    end
end

%% 确定初始化矩阵-初始中心
if strcmpi(start,'matrix')
    % 使用特定的K个点
    C = Cin;
elseif strcmpi(start,'sample')
    % 随机选择K个点-default
    Idx = randperm(N);
    Idx = Idx(1:k);
    C = X(Idx,:);
elseif strcmpi(start,'plus')
    % 选择彼此距离尽可能远的K个点
    C = mycluster_plus(X,k);
elseif strcmpi(start,'canopy')
    % canopy算法初始化
    error('Error! Change another method.');        % emmm 这个方法暂时没有做
end

%% 确定初始分类，并求初始误差
% 给X额外加了1列，在一次程序中只允许运行1次
if size(X,2)==P
    X = [X,zeros(N,1)];
else
    error('Error! X alreadly has %d columns.',P);
end
% 确定初始分类
for i=1:N
    temp = repmat(X(i,1:P),k,1);            % 拓展成k行方便相减
    dists = mydist(distance,temp,C);
    [~,X(i,P+1)] = min(dists);            % 取距离最小的,dists:k*1
end
% 求初始误差
err_init = myerrcal(distance,X,C);
fprintf('初始聚类误差为%d.\n',err_init);

%% 进入"中心-分类-求误差"循环
err = err_init;
T=1;
if limit_exist==0
    while(1)
        % 已知分类求新中心C-质心运算
        C = zeros(k,P);
        n = zeros(k,1);
        for i=1:N
            g_num = X(i,P+1);
            C(g_num,:)=( C(g_num,:)*n(g_num)+X(i,1:P) ) / (n(g_num)+1);
            n(g_num) = n(g_num)+1;
        end
        % 已知中心确定分类
        for i=1:N
            % 拓展成k行方便相减
            temp = repmat(X(i,1:P),k,1);          
            % 距离测度
            dists = mydist(distance,temp,C);
            % 取距离最小的
            [~,X(i,P+1)] = min(dists);            
        end
        
        % 确定分类后计算误差
        err_temp = myerrcal(distance,X,C);
        fprintf('第%d轮聚类误差为%d.\n',T,err_temp);
        T=T+1;
        
        % 绘制图像-仅用于调试，实际使用时为运算速度计应注释
        mydrawkmeans(X,C);
        % 误差列表增加一项
        err = [err;err_temp];
        % 设置退出条件
        if ( abs(err(end-1)-err(end))<errdlt )
            fprintf('聚类完成，一共进行了%d轮.\n',T-1);
            break;
        end
        % 暂停-仅用于调试，实际使用时应注释
%         pause;
    end
else    % limit_exist==1
    isfinish = 0;
    while(T~=replicates && isfinish==0)
        % 已知分类求新中心C-质心运算
        C = zeros(k,P);
        n = zeros(k,1);
        for i=1:N
            g_num = X(i,P+1);
            C(g_num,:)=( C(g_num,:)*n(g_num)+X(i,1:P) ) / (n(g_num)+1);
            n(g_num) = n(g_num)+1;
        end
        % 已知中心确定分类
        for i=1:N
            % 拓展成k行方便相减
            temp = repmat(X(i,1:P),k,1);          
            % 距离测度
            dists = mydist(distance,temp,C);
            % 取距离最小的
            [~,X(i,P+1)] = min(dists);            
        end
        
        % 确定分类后误差
        err_temp = myerrcal(distance,X,C);
        fprintf('第%d轮聚类误差为%d.\n',T,err_temp);
        T=T+1;
        
        % 绘制图像-仅用于调试，实际使用时为运算速度计应注释
        mydrawkmeans(X,C);
        % 误差列表增加一项
        err = [err;err_temp];
        % 若同时有errdlt-最小误差极限,也需要设置退出条件;
        while(errdlt_exist)
            if ( abs(err(end-1)-err(end))<errdlt )
                fprintf('聚类完成，一共进行了%d轮.\n',T-1);
                isfinish = 1;       % 只要误差变化量小于阈值无论轮数够不够直接结束
            end
        end
        % 即使同时没有设置errdlt-最小误差极限,在误差为0时也退出;
        if ( abs(err(end-1)-err(end))==0 )
            fprintf('聚类完成，一共进行了%d轮.\n',T-1);
            isfinish = 1;           % 只要误差变化量等于0无论轮数够不够直接结束
        end
        % 暂停-仅用于调试，实际使用时应注释
%         pause;
    end
end

%% 计算输出参数
% 每个点的类
Idx = X(:,P+1);
% 计算每个点到所有中心点的距离
D = zeros(N,k);
for i=1:N
    for j=1:k
        D(i,j) = sqrt(sum( (X(i,1:P)-C(j,:)).^2 ));
    end
end
% 计算每个范围内的误差(距离)和
sumD = zeros(k,1);
for i=1:N
    sumD(X(i,P+1),1) = sumD(X(i,P+1),1)+sqrt(sum( (X(i,1:P)-C(X(i,P+1),:)).^2 ));
end
% 误差列表
Errlist = err;

%% 输出
switch(nargout)
    case 1
        varargout = {Idx};
    case 2
        varargout = {Idx,C};
    case 3
        varargout = {Idx,C,sumD};
    case 4
        varargout = {Idx,C,sumD,D};
    case 5
        varargout = {Idx,C,sumD,D,Errlist};
end

end
%% 