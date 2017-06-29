% AdaBoost 强学习算法 对一组样本进行分类，获得AdaBoost算法对样本的预测输出
% 2017-5-22 崔佳勋
% 
% AdaBoostClassfy 与 AdaBoostDecisionForSample 类似，其不同之处在于
% AdaBoostClassfy 判别一组样本, AdaBoostDecisionForSample 判别单个样本类别
% AdaBoostClassfy  输入的是所有待分类样本的特征值
% AdaBoostDecisionForSample 输入的是单个样本的特征值
% 
% 
% 输入：
% Samples      待分类的样本, cntSamples x cntFeatures 矩阵
%              cntSamples    待分类的样本的数量
%              cntFeatures   特征空间维数
% Hypothesis   给定的AdaBoost强分类器,由T个弱分类器组成
% AlphaT       AdaBoost分类器的权重
% T            分类过程中使用的AdaBoost弱分类器的数量
% boostthresh  AdaBoost强分类器的阈值，默认为0.5
% 
% 输出:
% predictOutput      AdaBoost对每个样本的预测输出，其值为0或者1
%                    行向量，1 x cntSamples
% predictConfidence  AdaBoost对每个样本的预测输出的置信度，值在[0 1]间
%                    行向量，1 x cntSamples
% 
% 调用格式:
% [predictOutput,predictConfidence]=AdaBoostClassfy(Samples,Hypothesis,AlphaT,T)
% [predictOutput,predictConfidence]=AdaBoostClassfy(Samples,Hypothesis,AlphaT,T,boostThresh)
% 
% 
function [predictOutput,predictConfidence]=AdaBoostClassfy(Samples,Hypothesis,AlphaT,T,varargin)
error(nargchk(4,5,nargin));        % 输入4-5个参数,否则中止程序
validateattributes(Samples,{'numeric'},{'2d','real','nonsparse'}, mfilename,'Samples',1);
validateattributes(Hypothesis,{'numeric'},{'2d','real','nonsparse'}, mfilename,'Hypothesis',2);
validateattributes(AlphaT,{'numeric'},{'row','nonempty','real'},mfilename, 'AlphaT',3);

cntSamples=size(Samples,1);        % 待分类的样本的数量
boostthresh=0.5;                   % AdaBoost强分类器的默认阈值
if( nargin>4 )                     % 指定AdaBoost强分类器的阈值
    boostthresh=varargin{1};
end
validateattributes(T,{'numeric'},{'row','nonempty','integer'},mfilename, 'T',4);
if( length(T) > 1 )              % 指定使用弱分类器的数量的参数T长度应为1（不能为向量）
    error(['指定使用弱分类器的数量的参数(T)长度(' num2str(length(T)) ')应为1.']);
end
validateattributes(boostthresh,{'numeric'},{'row','nonempty','real'},mfilename, 'boostthresh',5);
if( length(boostthresh) > 1 )     % 参数阈值长度应为1（不能为向量）
    error(['AdaBoost分类器阈值(thresh)长度(' num2str(length(boostthresh)) ')应为1(不能为向量).']);
end

predictOutput=zeros(1,cntSamples); % 每个样本对强分类器的判别输出，0或者1
predictConfidence=zeros(1,cntSamples); % 每个样本分类结果的置信度，[0 1]

Hypothesis=Hypothesis(1:T,:);      % 取前T个弱分类器 

AlphaT=AlphaT(1:T);                % 前T个弱分类器权重

for i=1:cntSamples              
    h=zeros(1,T);                  % 所有分类器每个样本的分类器输出 
    for t=1:T
          thresh=Hypothesis(t,1);  % 第t个弱分类器的 阈值
          p=Hypothesis(t,2);       % 第t个弱分类器的 偏置
          j=Hypothesis(t,3);       % 第t个弱分类器的 特征列
          if((p*Samples(i,j))<(p*thresh))% 第t个弱分类器的对样本i的输出
              h(t)=1;
          end
     end
     tempH=sum(AlphaT.*h);      
     if(tempH>=(boostthresh*sum(AlphaT)))          % 将T个弱分类器组成强分类器,并输出样本i的类别 
          predictOutput(i)=1;
     end
     predictConfidence(i)=tempH/(sum(AlphaT)+eps); % 置信度
end

