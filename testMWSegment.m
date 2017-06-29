% 2017-5-28 崔佳勋
% 测试滑动窗口(MoveWindowing)
% testMWSegment
% 普通滑动窗口实现人脸识别
% 
% 将结果数据保存在 MWindowData 中
% 保存格式为：{图片编号}{阈值编号}Cell
% 每一个元祖包含每幅图像每个阈值下获得的统计数据：
% AreaTPRate 人脸区域的检测率
% AreaFPRate 人脸区域的误检率
% CntTPRate  人脸数量的检测率
% labDisCnt  搜索图像上获得的人脸数量
% StdDisCnt  人工标记图像上的人脸数量
% labTPArea  人脸区域的检测区域
% labFPArea  人脸区域的错误检测区域
% StdDisArea 人工标记图像上的标准人脸区域
% costtime   本次运行花费时间

imBegin=1;
imEnd=1;

% MVParameters        滑动窗口方法的参数，包含如下参数：

MVParameters.WindowingPatchSize=20:4:80; % 搜索时的窗口大小序列 原数据［60 80］
MVParameters.xnum=30;                % 水平方向上将图像划分的格数 
MVParameters.ynum=30;                % 垂直方向上将图像划分的格数 

% WindowParameters       对图像窗口进行判别的学习算法的参数
load HarrLikeFeatures-2.mat Hypothesis AlphaT
WindowParameters.Method=@ImageBlockRecogByAdaBoost;
WindowParameters.Hypothesis=Hypothesis;
WindowParameters.AlphaT=AlphaT;
WindowParameters.thresh=0.5;

segThresh=0.1:0.1:0.9;       % 对频率图像进行分割的多个阈值
DiseaseThresh=0.75;          % 判定所选区域是否为完整人脸的阈值

tic
imageBak=cell(1,imEnd-imBegin+1);

for i=imBegin:imEnd
    filename='8.bmp';
    image=imread(filename);    % 读取原始图像
    [sizex,sizey]=size(image);
    smallimage=imresize(image,[sizex/2,sizey/2]);
    if numel(size(image))~=2
        image=rgb2gray(image);
    end 
    [detectWindow,detectImage,pixFreImage]...% 滑动窗口识别
        =MoveWindowing(image,MVParameters,WindowParameters);

    costtime=toc;

    bias=1;
    [labBinaryImage,labSrcImage]=...         % 多阈值分割
        MultiThreshSegement(pixFreImage,segThresh,bias,image);

    imageBak{i-imBegin+1}=labSrcImage;
    [combineMap]=dispCombineImage(labSrcImage);
    figure
    imshow(detectImage)
    %newName=strcat('TestPicture/Segment/',num2str(i),...
    %    '-MovingWindow-costtime-',num2str(costtime),'.jpg');
    %imwrite(combineMap,newName,'jpg');     % 保存到文件中
    %disp(newName);   
end



