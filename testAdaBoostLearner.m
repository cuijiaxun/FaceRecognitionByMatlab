% 2017-5-26 崔佳勋
% AdaBoost 学习算法 测试过程
% testAdaBoostLearner
% 通过 AdaBoost 对样本进行分类，然后计算统计错误率
% 分类过程通过调用 AdaBoostClassfy 实现
% 
% AdaBoost 学习算法 包括训练与测试过程
% AdaBoostClassfy            AdaBoost 学习算法 对一组样本进行分类
% AdaBoostWeakLearnerClassfy AdaBoost 弱假设对一组样本进行分类
% searchBestWeakLearner      在特征列上获得最优的阈值分类器
% trainAdaBoostLearner       AdaBoost 学习算法 训练过程
% testAdaBoostLearner        AdaBoost 学习算法 测试过程
% testAdaBoost(训练与测试)    将样本随机划分为训练集与测试集，多次训练测试AdaBoost学习算法
% AdaBoost(训练与测试)        给定训练集与测试集,训练测试AdaBoost分类器
% 
% testAdaBoost 与 AdaBoost 类似，均是先训练，而后测试
% testAdaBoost 测试多次，并且将样本集分为训练集与测试集
% testAdaBoost 通过调用 AdaBoost 函数进行多次的 AdaBoost 算法 训练与测试
% AdaBoost调用 trainAdaBoostLearner 学习分类器
%         调用 testAdaBoostLearner 测试分类器
% 
% 
% 输入:
% testX        测试数据集,cntSamples X cntFeatures 维矩阵
%              cntSamples个样本，每个样本cntFeatures个特征值
%              cntSamples    待分类的样本的数量
%              cntFeatures   特征空间维数
% testY        测试数据类标,每个样本所属类别的标识
% Hypothesis   训练获取的AdaBoost分类器
%              共T个弱分类器，每个弱分类器的组成是 [阈值 偏置 特征列]
% AlphaT       AdaBoost分类器的权重,T维向量
% T            分类器的数量
% T            若输入的弱分类器长度超过T，则截取前T个弱分类器进行测试
% T            若输入的弱分类器长度小于T，则自动使用所有分类器进行测试
% thresh       AdaBoost分类器的阈值,默认阈值0.5
% 
% 输出：
% testErrorRate 在测试数据集X上第1轮至第T轮的测试错误率
% TPRate        在测试集上第1轮至第T轮的 True-Positive 比例
% FPRate        在测试集上第1轮至第T轮的 Negative-True 比例
% 
% 调用格式： 
% [testErrorRate,TPRate,FPRate]=testAdaBoostLearner(testX,testY,Hypothesis,AlphaT)
% [testErrorRate,TPRate,FPRate]=testAdaBoostLearner(testX,testY,Hypothesis,AlphaT,T)
% [testErrorRate,TPRate,FPRate]=testAdaBoostLearner(testX,testY,Hypothesis,AlphaT,T,thresh)
% 
% 
function [testErrorRate,TPRate,FPRate]=testAdaBoostLearner(testX,testY,Hypothesis,AlphaT,varargin)
error(nargchk(4,6,nargin));          % 参数数量检查，必须输入4-6个参数,否则中止程序
validateattributes(testX,{'numeric'},{'2d','real','nonsparse'}, mfilename,'testX',1);
validateattributes(testY,{'logical','numeric'},{'row','nonempty','integer'},mfilename, 'testY',2);
validateattributes(Hypothesis,{'numeric'},{'2d','real','nonsparse'}, mfilename,'Hypothesis',3);
validateattributes(AlphaT,{'numeric'},{'row','nonempty','real'},mfilename, 'AlphaT',4);

cntHypothesis=size(Hypothesis,1);    % 分类器数量
if( nargin>4 )                       % 指定所采用的分类器的数量
    T = varargin{1};
    validateattributes(T,{'numeric'},{'row','nonempty','integer'},mfilename, 'T',5);
    if( cntHypothesis>T )            % 检查参数 T 的有效性 
        Hypothesis=Hypothesis(1:T,:);% 截取前T个弱分类器
        AlphaT=AlphaT(1:T);
    elseif( cntHypothesis<T )        % 使用所有分类器进行测试
        disp('警告：输入参数 T（使用分类器数） 过大...');
        T=cntHypothesis;
    end
else                                 % 默认采取所有的弱分类器 
    T=cntHypothesis;
end
cntHypothesis=size(Hypothesis,1);    % 分类器数量

thresh=0.5;                          % 默认的阈值
if( nargin>5 )                       % 指定分类器阈值
    thresh=varargin{2};
    validateattributes(thresh,{'numeric'},{'row','nonempty','real'},mfilename, 'thresh',6);
    if( length(thresh) > 1 )         % 阈值长度应为1（不能为向量）
        error(['AdaBoost分类器阈值(thresh)长度(' num2str(length(thresh)) ')应为1(不能为向量).']);
    end
    if(thresh>0.99||thresh<0.01)
        disp(['警告：输入参数阈值(' num2str(thresh) ')无效，采用默认阈值0.5...']);
        thresh=0.5; 
    end
end

if( cntHypothesis~=length(AlphaT) )% 分类器数量必须与权重向量alphaT长度相同
    error('分类器数量必须与权重向量alphaT长度相同！');
end

nSamples=size(testX,1);         % 待分类的样本的数量
testErrorRate=zeros(1,T);       % 第1轮至第T轮的训练错误率
TPRate=zeros(1,T);              % 第1轮至第T轮的 True-Positive   比例
FPRate=zeros(1,T);              % 第1轮至第T轮的 Negative-True  比例

testOutput=zeros(1,nSamples);   % 临时变量:使用前t个分类器对测试数据进行分类的结果  
h=zeros(1,nSamples);            % 临时变量:使用第t轮最优分类器进行分类 的结果      

for t=1:T                       % 分类器数量：T
   [testOutput]=AdaBoostClassfy(testX,Hypothesis,AlphaT,t,thresh);
                                % 获取测试样本的分类输出           
   [errorRate,curTPRate,curFPRate]=calPredictErrorRate(testY,testOutput);
                                % 计算错误率、检测率与误检率 
   testErrorRate(t)=errorRate;
   TPRate(t)=curTPRate;
   FPRate(t)=curFPRate;
end

