# FaceRecognitionByMatlab
This program is based on the Adaboost Algorithm and Haar Feature
背景阐述
开发一个纯Matlab下的人脸识别系统其实非常有益，因为Matlab具有极强的图像处理功能。然而目前互联网上大多采用OpenCV＋C++编译Matlab API的方法进行Matlab人脸识别，我觉得这是完全没有意义的。因此，我选择理解Viola－Jones提出的人脸识别算法，并仅用Matlab进行编程。

1.1主要文件及作用

测试训练及提取特征：运行ExtractAndTrain.m（不建议低gpu配置运行）
测试检测性能：运行testMWSegment.m

数据库
faces文件夹
4422张人脸
正样本
nonfaces文件夹
4381张非人脸
负样本
主程序1
（特征提取及训练）
ExtractAndTrain.m
提取和训练的主程序
（建议不要跑，训练要7小时左右）
定义了Haar特征，提取特征，训练，错误率计算
特征提取函数
integralImage.m
求积分图像

extHarrLikeFeature.m
提取Harr-like特征

训练所需要的函数
trainAdaBoostLearner.m
训练100个强分类器，找到区别人脸的阈值

searchBestWeakLearner.m
根据错误率找到最好的weak learner

AdaBoostClassfy.m
强学习分类

calPredictErrorRate.m
计算错误概率

testAdaBoostLearner.m
自我循环样本，测试误判

数据库
HarrLikeFeatures-2.mat
保存提取的特征及训练数据
可以直接使用作为数据库

主函数2
图像检测
testMWSegment.m
窗口检测程序
指定判断算法、窗口数据、划定网格
判断函数
MoveWindowing.m
移动窗口、放缩

ImageBlockRecogByAdaBoost.m
对当前窗口进行识别

ThreshSegement.m
阈值分割

LabelDetectWindow.m
给找到的图像进行加框

级联检测
ImageBlockRecogByCascadeAdaBoost.m
级联检测
就写了一下，还没有整合进程序
