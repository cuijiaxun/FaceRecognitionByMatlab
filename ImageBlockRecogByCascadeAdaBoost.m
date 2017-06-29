% 崔佳勋2017-5-25
% 级联AdaBoost分类器 对图像块(一个区域的图像数据)进行判别
% ImageBlockRecogByCascadeAdaBoost
% 
% 该方法与 ImageBlockRecogByAdaBoost 属同一类函数，可以被统一调用
% 
% 由于该函数被大量的重复调用，基于效率考虑，没有对该函数的参数进行类型检测
% 
% 为了方便调用的一致性，分类所需要的参数均被封装在 Parameters 中
% 
% 
% 输入为图像块数据，每次仅仅提取需要的特征进行判别
% 每个弱分类器对样本进行判决时，首先判断该弱分类器的特征是否已提取
% 若该特征没有提取，则提取该特征所属的系列特征(identifySeriesFeatureByIndex)
% 
% 
% 输入：
% ImageBlock              输入图像块，即待判决图像
% Parameters              级联AdaBoost 分类器参数，包括如下：
% Parameters.Hypothesis   T 级 级联AdaBoost分类器, 1xT cell
% Parameters.AlphaT       级联AdaBoost各级的权重, 1xT cell
% Parameters.thresh       级联AdaBoost各级的阈值, 1xT cell
% Parameters.T            级联AdaBoost的级数
% 输出：
% predictOutput           AdaBoost 对图像的预测输出，其值为0或者1
% 
% 调用格式：
%  [predictOutput]=...
%     ImageBlockRecogByCascadeAdaBoost(ImageBlock,Parameters)
%
% 
function [predictOutput]=...
    ImageBlockRecogByCascadeAdaBoost(ImageBlock,Parameters)
Hypothesis = Parameters.Hypothesis;    % 弱分类器经 AdaBoost 算法训练获得的强学习器
AlphaT = Parameters.AlphaT;            % 级联 AdaBoost 各级的权重
decidethresh = Parameters.thresh;      % 级联 AdaBoost 各级的阈值
T = Parameters.T;                      % 级联 AdaBoost 的级数

predictOutput = 0;                     % 级联分类器对样本的输出     
cntFeatures = 391;                     % 特征空间维数
feature = zeros(1,cntFeatures);        % 特征向量
extFlags = zeros(1,cntFeatures);       % 特征是否已提取的标志数组

for t=1:T
    tCntHypo = length(AlphaT{t});      % 第t级 分类器轮数
    h = zeros(1,tCntHypo);             % 第t级 tCntHypo 个弱分类器对样本的输出 
    tDThresh = decidethresh{t};        % 第t级 进行决策的阈值

    for i = 1:tCntHypo                 % 第t级 弱分类器的判决
          thresh = Hypothesis{t}(i,1); % 第t级 第 i 个 弱分类器的 阈值
          p = Hypothesis{t}(i,2);      % 第t级 第 i 个 弱分类器的 偏置
          j = Hypothesis{t}(i,3);      % 第t级 第 i 个 弱分类器的 特征列j
          if( extFlags(j) == 0 )       % 若 第 j 个 特征尚未提取，则提取该系列特征
              [seriesFeatures,seriesIndex] = identifySeriesFeatureByIndex(ImageBlock,j);
              feature(seriesIndex) = seriesFeatures; % 特征
              extFlags(seriesIndex) = 1;             % 已提取特征标志 
          end
          if( (p*feature(j)) < (p*thresh) )  % 第t个分类器的对样本的输出
              h(i) = 1;
          end
    end
    tempH = sum( AlphaT{t}.*h );
    if( tempH >= (tDThresh*sum(AlphaT{t})) ) % 将T个弱分类器组成强分类器,并输出样本的类别 
          predictOutput = 1;
    else
         predictOutput = 0;
         break;
    end
end

