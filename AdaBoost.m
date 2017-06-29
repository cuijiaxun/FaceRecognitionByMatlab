% 2017-5-21崔佳勋
% AdaBoost 学习算法，训练过程与测试过程
% AdaBoost
% 提供AdaBoost训练与测试
% 算法来源 Robust Real-time Object Detection.pdf & 一种新的adaboost快速训练算法.PDF
%
% 训练T轮,将会获得第1轮至第T轮的数据,包括弱假设,训练错误率,测试错误率等
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
% 输入:
% trainX  训练数据集
% trainY  训练数据集类别
% T       训练轮数
% testX   测试数据集
% testY   测试数据类标
% 
% 
% 输出：
% AdaBoostInfo 结构体
% 包括如下成员：
% Hypothesis        训练获取的弱分类器,共T个弱分类器
%                   每个弱分类器的组成是 [阈值 偏置 特征列]
% AlphaT            每个弱分类器的权值,T维向量
% trainError        在训练数据集X上第1轮至第T轮的训练错误率
% testError         在测试数据集X上第1轮至第T轮的测试错误率
% TPRate            在测试集上第1轮至第T轮的 True-Positive   比例
% FPRate            在测试集上第1轮至第T轮的 Negative-True  比例
% costTime          训练第1轮至第T轮的花费时间
%
% 
function [AdaBoostInfo]=AdaBoost(trainX,trainY,T,testX,testY)
[Hypothesis,AlphaT,trainErrorRate,costTime,trainTPRate,trainFPRate]=trainAdaBoostLearner(trainX,trainY,T);
[testErrorRate,testTPRate,testFPRate]=testAdaBoostLearner(testX,testY,Hypothesis,AlphaT,T);

AdaBoostInfo.Hypothesis=Hypothesis;         % 训练获取的弱分类器
AdaBoostInfo.AlphaT=AlphaT;                 % 每个弱分类器的权值
AdaBoostInfo.trainError=trainErrorRate;     % 训练错误率
AdaBoostInfo.trainTPRate=trainTPRate;       % 训练 True-Positive Rate
AdaBoostInfo.trainFPRate=trainFPRate;       % 训练 Negative-True Rate
AdaBoostInfo.testError=testErrorRate;       % 测试错误率
AdaBoostInfo.testTPRate=testTPRate;         % 测试 True-Positive Rate
AdaBoostInfo.testFPRate=testFPRate;         % 测试 Negative-True Rate
AdaBoostInfo.costTime=costTime;             % 花费时间
