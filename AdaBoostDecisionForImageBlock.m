% 2017-5-22 崔佳勋
% AdaBoost 对图像块(一个区域的图像数据)进行判别
% AdaBoostDecisionForImageBlock
% 通过调用 AdaBoostDecisionForSample 实现对图像块的判决
% 
% AdaBoostDecisionForSample 与 AdaBoostDecisionForImageBlock 类似
% 它们都是对单个样本进行判别，但它们的输入参数不同：
% AdaBoostDecisionForSample      输入的是图像样本的特征值( 特征向量 )
% AdaBoostDecisionForImageBlock  输入的是图像样本的图像数据( RGB颜色空间值 )
%                                其特征值尚未提取
% 
% AdaBoostDecisionForSample 与 AdaBoostClassfy 有一定的类似
% 这两个函数输入的都是待分类样本的特征值，但处理的样本数量不同：
% AdaBoostClassfy            对一组样本进行判别
% AdaBoostDecisionForSample  对单个样本进行判别
% 
% 
% AdaBoostDecisionForImageBlock 与 ImageBlockRecogByAdaBoost 类似
% 它们都是对单个样本进行判别，并且输入也均为图像数据，特征值尚未提取
% 不同之处在于：
% AdaBoostDecisionForImageBlock 一次提取所有特征
%          然后通过调用 AdaBoostDecisionForSample 实现样本判别
% ImageBlockRecogByAdaBoost     在判决过程中依次提取特征
%          只有当需要的特征值没有提取时，才提取特征
%          另外，为了方便上层调用，分类所需要的所有参数均封装在一个参数 Parameters 中
% 
% 输入：
% ImageBlock   输入图像块，即待判决图像
% Hypothesis   T个弱分类器经AdaBoost算法训练获得的强学习器
% AlphaT       各弱分类器的权重
% decidethresh 判决时的阈值，默认为0.5
% 
% 输出：
% predictOutput      AdaBoost 对图像的预测输出，其值为0或者1
% predictConfidence  AdaBoost 对图像的预测输出的置信度，值在[0 1]间
% 
% 调用：
% [predictOutput,predictConfidence]=...
%     AdaBoostDecisionForImageBlock(ImageBlock,Hypothesis,AlphaT)
% [predictOutput,predictConfidence]=...
%     AdaBoostDecisionForImageBlock(ImageBlock,Hypothesis,AlphaT,decidethresh)
% 
% see:ImageBlockRecognizedByAdaBoost
% 
function [predictOutput,predictConfidence]=AdaBoostDecisionForImageBlock(ImageBlock,Hypothesis,AlphaT,varargin)
error(nargchk(3,4,nargin));        % 必须输入 3-4 个参数,否则中止程序
iptcheckinput(ImageBlock,{'numeric'},{'real'}, mfilename,'ImageBlock',1);
iptcheckinput(Hypothesis,{'numeric'},{'2d','real'}, mfilename,'Hypothesis',2);
iptcheckinput(AlphaT,{'numeric'},{'row','nonempty','real'},mfilename, 'AlphaT',3);

decidethresh=0.5;                   % AdaBoost强分类器的默认阈值
if( nargin>3 )                     % 指定AdaBoost强分类器的阈值
    decidethresh=varargin{1};
end
iptcheckinput(decidethresh,{'numeric'},{'row','nonempty','real'},mfilename, 'decidethresh',4);
if( length(decidethresh) > 1 )     % 参数阈值长度应为1（不能为向量）
    error(['AdaBoost分类器阈值(thresh)长度(' num2str(length(decidethresh)) ')应为1(不能为向量).']);
end


% % [Sample]=extractFeature(ImageBlock);
% TODO 
% 此处为测试 C++  
% TODO
% TODO

[Sample]=extractFeatureForCpp(ImageBlock);

[predictOutput,predictConfidence]=...
    AdaBoostDecisionForSample(Sample,Hypothesis,AlphaT,decidethresh);

% Parameters.Hypothesis=Hypothesis;% T个弱分类器经AdaBoost算法训练获得的强学习器 
% Parameters.AlphaT=AlphaT;        % 各弱分类器的权重
% Parameters.thresh=decidethresh;   % 判决时的阈值，默认为0.5

% [predictOutput,predictConfidence]=... % 调用 ImageBlockRecognizedByAdaBoost
%     ImageBlockRecognizedByAdaBoost(ImageBlock,Parameters);



