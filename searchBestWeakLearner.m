%崔佳勋2017-05-25 
%在特征列上获得最优的阈值分类器
% searchBestWeakLearner
% 
% 假设分布满足高斯分布
% 通过高斯模型求取两个类别的均值
% 在两个类别的均值中间搜索最有阈值分类器
% 采用逐步求精的搜索策略
%
% 输入:
% FeatureVector 特征向量，查找最佳弱分类器的特征列;列向量      
% Y             每个样本所属类别的标识;列向量
% weight        权重向量,存放当前每个样本的权重值;列向量
% 以上三个列向量必须具备相等的长度
% 
% 例如：
%      FeatureVector  Y      weight
% 样本1     11        0       0.10 
% 样本2     12        0       0.20
% 样本3     10        0       0.40 
% 样本4     20        1       0.15 
% 样本5     30        1       0.15 
% 
% 
% 输出:
%  bestError    当前特征列最佳弱分类器得到的最小错误率
%  bestThresh   当前特征列最佳弱分类器的阈值
%  bestBias     当前特征列最佳弱分类器的偏置
% 
% 迭代4次,每次将区间划分为8个小段
%
% 调用格式为
% [bestError,bestThresh,bestBias]=searchBestWeakLearner(FeatureVector,Y,weight)
% 
% 
% findBestWeakLearner 扩展版本
% 
function [bestError,bestThresh,bestBias]=searchBestWeakLearner(FeatureVector,Y,weight)
error(nargchk(3,3,nargin));         % 输入3个参数,否则中止程序
% 检查输入特征向量与类标需为列向量
validateattributes(FeatureVector,{'logical','numeric'},{'column','nonempty','real'},mfilename, 'FeatureVector',1);
validateattributes(Y,{'logical','numeric'},{'column','nonempty','integer'},mfilename, 'Y',2);
validateattributes(weight,{'numeric'},{'column','nonempty','real'},mfilename, 'weight',3);

cntSamples=length(FeatureVector);    % 样本容量
if( length(Y)~=cntSamples || length(weight)~=cntSamples ) % 检查长度
    error('特征向量、样本类标、与样本权重必须具备相等的长度.');
end
u1=mean(FeatureVector(find(Y==1)));  % 类别1均值
u2=mean(FeatureVector(find(Y==0)));  % 类别2均值

iteration=4;                         % 迭代次数
sectNum=8;                           % 每次迭代,将搜索区域划分的片段

maxFea=max(u1,u2);                   % 搜索空间的最大值 
minFea=min(u1,u2);                   % 搜索空间的最小值
step=(maxFea-minFea)/(sectNum-1);    % 每次搜索的递增量
bestError=cntSamples;                      % 初值:最好的分类器错误率

for iter=1:iteration                 % 迭代iteration次,范围逐步缩小,寻找最优值
    tempError=cntSamples;                  % 初值:第iter次迭代的分类器错误率      
    for i=1:sectNum                  % 第iter次迭代的搜索次数
        thresh=minFea+(i-1)*step;    % 第i次搜索的阈值
        h=FeatureVector<thresh;      % 所有样本的阈值分类结果
        errorrate=sum(weight(find(h~=Y)));% 第iter次迭代第i次搜索加权错误率
        p=1;
        if(errorrate>0.5)            % 若错误率超过0.5，则将偏置反向
            errorrate=1-errorrate;
            p=-1;
        end
        if( errorrate<bestError )    % 第iter次迭代最优的错误率 阈值 偏置
            bestError=errorrate;     % 第iter次迭代最小的错误率
            bestThresh=thresh;       % 第iter次迭代最小错误分类情况下的阈值
            bestBias=p;              % 第iter次迭代最小错误分类情况下的偏置
        end
    end

    % 将搜索范围缩小,继续进行搜索
    span=(maxFea-minFea)/8;          % 搜索范围减为原有的1/4                    
    maxFea=bestThresh+span;          % 减少搜索范围后搜索空间的最大值     
    minFea=bestThresh-span;          % 减少搜索范围后搜索空间的最小值

   step=(maxFea-minFea)/(sectNum-1); % 减少搜索范围后每次搜索的递增量
end
