% 2017-5-24 崔佳勋
% 根据标准的类别标记，计算分类结果的错误率
% calPredictErrorRate
% 在 testAdaBoostLearner/testBoostLearner/testCascadeAdaBoost 等计算分类错误率时调用
% 
% 输入：
% stdOutput     标准样本类别标记
% predictOutput 预测样本类别标记
% 
% 输出：
% errorRate  错误率 ：分类错误率的样本比例
% TPRate     检测率 ：True-Positive Rate
% FPRate     误检率： Negative-True Rate
% 
% 
function [errorRate,TPRate,FPRate]=calPredictErrorRate(stdOutput,predictOutput)
TPSamples=((predictOutput.*stdOutput)==1); % Positive被判为True的样本索引
ErrorSamples=stdOutput-predictOutput;      % 分类错误的样本索引
errorRate=length(find(ErrorSamples~=0))/length(stdOutput);
                                           % 计算错误率
TPRate=length(find(TPSamples==1))/length(find(stdOutput==1));  
                                           % 计算Positive被判为True的比例
FPRate=length(find(ErrorSamples==-1))/length(find(stdOutput==0));    
                                           % 计算Negative被判为True的比例


