% 2017-5-22崔佳勋
% AdaBoost 弱假设对一组样本进行分类，获得AdaBoost弱假设对所有样本的预测输出
% AdaBoost 弱假设为二值分类器
% AdaBoostWeakLearnerClassfy
% 
% 输入：
% Samples      待分类的样本, cntSamples x cntFeatures 矩阵
%              cntSamples    待分类的样本的数量
%              cntFeatures   特征空间维数
% weakLearner  给定的弱分类器，此处采用的是二值分类器
% 
% 输出:
% predictOutput  AdaBoost弱分类器对每个样本的预测输出，其值为0或者1
%                输出行向量，1 x cntSamples
% 
%
% 
function [predictOutput]=AdaBoostWeakLearnerClassfy(Samples,weakLearner)
thresh=weakLearner(1);          % 弱分类器的 阈值  
p=weakLearner(2);               % 弱分类器的 偏置
j=weakLearner(3);               % 弱分类器的 特征列标号

predictOutput=(p.*Samples(:,j)<p*thresh); % 每个样本对弱假设的输出
predictOutput=predictOutput.';
