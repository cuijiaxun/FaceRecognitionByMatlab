%崔佳勋 2017-5-20

clear 
clc
%开始提取Haar-Like 特征
positiveRange=1:1000;
negativeRange=1:2000;

positiveNum=length(positiveRange);         % 正样本数量
negativeNum=length(negativeRange);         % 负样本数量
n=negativeNum+positiveNum;
stdSize=[20 20];            %MIT人脸库素材大小

HarrLike{1}=[1 -1];         %定义5种haar-like特征
HarrLike{2}=[1 -1].';
HarrLike{3}=[1 -2 1];
HarrLike{4}=[1 -2 1].';
HarrLike{5}=[1 -1;-1 1];


baseSize=2:2:4;


features=zeros(n,78460); 
for i=positiveRange
    picName=strcat('face',num2str(i),'.bmp');       %自动生成图片名，对图片进行遍历
    %picName='face1.bmp';
    FaceRegion=imread(picName);
    if numel(size(FaceRegion))>2
         FaceRegion=rgb2gray(FaceRegion);           %将rgb图像转化为灰度图像
    end 
    FaceRegion=imresize(FaceRegion,stdSize);
    [II]=integralImage(FaceRegion);
    [fea]=extHarrLikeFeature(II,HarrLike,baseSize);
    features(i,:)=fea';
    disp(picName);
end 


for i=negativeRange
    picName=strcat('nonface',num2str(i),'.bmp');
    FaceRegion=imread(picName);
    if numel(size(FaceRegion))>2
         FaceRegion=rgb2gray(FaceRegion);            %将rgb图像转化为灰度图像
    end 
    FaceRegion=imresize(FaceRegion,stdSize);
    [II]=integralImage(FaceRegion);
    [fea]=extHarrLikeFeature(II,HarrLike,baseSize);
    features(i+positiveNum,:)=fea';
    disp(picName);
end


Y=[ones(1,positiveNum) zeros(1,negativeNum)];% 类标  

HarrLikeFeatures=features;
save HarrLikeFeatures-2.mat HarrLikeFeatures Y 
%}
%开始训练
trainingRate=0.5;     % 训练样本占总体样本比例    

T=200;                % 训练轮数的范围
%T=100;                % 训练轮数的范围
%  
% trainError=zeros(1,T);    % 训练错误率矩阵
% testError=zeros(1,T);    % 训练错误率矩阵
% testTP=zeros(1,T);        % TRUE-Positive   比例矩阵 
% testFP=zeros(1,T);        % FALSE-Positive  比例矩阵
% AdaCostTime=cell(1);      % 花费时间


rows=size(features,1);

% 确实训练与测试样本
trainingRows=1:2:rows;            
testingRows=2:2:rows;

trainX=features(trainingRows,:);         % 获得训练数据
trainY=Y(trainingRows);                  % 训练数据的类标
testX=features(testingRows,:);           % 获得测试数据
testY=Y(testingRows);                    % 测试数据的类标

[Hypothesis,AlphaT,trainError,AdaCostTime]=trainAdaBoostLearner(trainX,trainY,T);
[testError,testTP,testFP]=testAdaBoostLearner(testX,testY,Hypothesis,AlphaT,T);

    
    

% 下面一部分是作图的程序
% 该图形显示 获得训练错误率和测试错误率 
figure(1002);hold on,
grid on,
xlabel('训练轮数');
ylabel('AdaBoost分类器错误率) ');
testingNum=ceil((1-trainingRate)*size(features,1)); %测试样本数量
trainingNum=size(features,1)-testingNum;            %训练样本数量
title(strcat('AdaBoost训练与测试错误率',' ( 训练',num2str(trainingNum),'例,测试',num2str(testingNum),'例 )'));

testRange=1:T;
plot(testRange,mean(trainError,1),'r-');
plot(testRange,mean(testError,1),'b-');
legend('Harr-Like特征训练错误率','Harr-Like特征测试错误率');

save HarrLikeFeatures-2.mat HarrLikeFeatures Y trainError testError testTP testFP Hypothesis AlphaT AdaCostTime
