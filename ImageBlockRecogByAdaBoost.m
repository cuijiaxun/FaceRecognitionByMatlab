%崔佳勋2017-5-25
%采用 AdaBoost 对输入图像块进行判决
% ImageBlockRecognizedByAdaBoost
% 
% 由于该函数被大量的重复调用，基于效率考虑，没有对该函数的参数进行类型检测
% 
% 为了方便调用的一致性
% 分类所需要的参数均被封装在 Parameters 中
% 
% 真正实现了对样本进行分类的函数为：AdaBoostDecisionForSample
%                                ImageBlockRecognizedByAdaBoost
% 
% 
% 输入为图像块数据，每次仅仅提取需要的特征进行判别
% 每个弱分类器对样本进行判决时，首先判断该弱分类器的特征是否已提取
% 若该特征没有提取，则提取该特征所属的系列特征(identifySeriesFeatureByIndex)
% 
% 
% 输入：
% ImageBlock              输入图像块，即待判决图像
% Parameters              AdaBoost 学习算法的参数，包括如下：
% Parameters.Hypothesis   T个弱分类器经AdaBoost算法训练获得的强学习器
% Parameters.AlphaT       各弱分类器的权重
% Parameters.thresh       各弱分类器的阈值，默认为0.5
% 
% 输出：
% predictOutput           AdaBoost 对图像的预测输出，其值为0或者1
% predictConfidence       AdaBoost 对图像的预测输出的置信度，值在[0 1]间
% 
% 调用：
% [predictOutput,predictConfidence]=ImageBlockRecogByAdaBoost(ImageBlock,Parameters)
% 
% 
function [predictOutput,predictConfidence]=...
    ImageBlockRecogByAdaBoost(ImageBlock,Parameters)

Hypothesis=Parameters.Hypothesis; % T个弱分类器经AdaBoost算法训练获得的强学习器
AlphaT=Parameters.AlphaT;         % 各弱分类器的权重
decidethresh=Parameters.thresh;   % 判决时的阈值，默认为0.5

predictOutput=0;                  % 样本对强分类器的输出     
%predictConfidence=0;              % 隶属度 
T=length(AlphaT);                 % 分类器轮数
h=zeros(1,T);                     % 所有分类器对样本的输出 

baseSize=2:2:4;
HarrLike{1}=[1 -1];         %定义haar-like特征
HarrLike{2}=[1 -1].';
HarrLike{3}=[1 -1 1];
HarrLike{4}=[1 -1 1].';
HarrLike{5}=[1 -1;-1 1];


cntFeatures=T;                     % 特征空间维数
%feature=zeros(1,cntFeatures);      % 特征向量
%extFlags=zeros(1,cntFeatures);    % 特征是否已提取的标志数组
image=imresize(ImageBlock,[20 20]);%使窗口为［20 20大小］
[II]=integralImage(image);
feature=extHarrLikeFeature(II,HarrLike,baseSize);
for t=1:T
      thresh=Hypothesis(t,1);     % 第t个分类器的 阈值
      p=Hypothesis(t,2);          % 第t个分类器的 偏置
      j=Hypothesis(t,3);          % 第t个分类器的 特征列
      
      %{
      if( extFlags(t)==0 )        % 若第j个特征尚未提取，则提取该系列特征
        [seriesFeatures,seriesIndex]=identifySeriesFeatureByIndex(ImageBlock,t);
         feature(seriesIndex)=seriesFeatures; % 特征
         extFlags(seriesIndex)=1;             % 已提取特征标志 
      end 
      %}
   
      if((p*feature(j))<(p*thresh))% 第t个分类器的对样本的输出
          h(t)=1;
      end
    
end 
    
      tempH=sum(AlphaT.*h);                 % T个分类器结果*权重
      if(tempH>=(decidethresh*sum(AlphaT))) % 将T个弱分类器组成强分类器,并输出样本的类别 
        predictOutput=1;
      end


predictConfidence=tempH/sum(AlphaT);  % 计算隶属度

end 

