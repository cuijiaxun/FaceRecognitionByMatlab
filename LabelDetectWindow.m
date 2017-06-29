% 2017-5-28 崔佳勋
% 给原始图像加上病斑边框标记
% 
% 输入：
% image         需要进行标记的图像
% detectWindow  检测为人脸的窗口信息
%               其格式为[i j WinSize]，即[横坐标 纵坐标 窗口大小]
% 
% 输出：
% labelImage    在原始图像上加上窗口的标记图像
% 
function [labelImage]=LabelDetectWindow(image,detectWindow)
winCnt=size(detectWindow,1); % 人脸窗口数量
counter=1;                   % 计数器

labelImage=image;            % 标记图像

LabelLineColor=255;          % 标记线颜色

while(counter<=winCnt)
     i=detectWindow(counter,1);  % 人脸窗口 横坐标            
     j=detectWindow(counter,2);  % 人脸窗口 纵坐标
     winSize=detectWindow(counter,3);% 人脸窗口 大小

     topMost=i;                  % 窗口上边缘
     botMost=i+winSize-1;        % 窗口下边缘
     lefMost=j;                  % 窗口左边缘
     rigMost=j+winSize-1;        % 窗口右边缘

     % 加边框
     labelImage(topMost:botMost,lefMost,:)=LabelLineColor; % 左边框
     labelImage(topMost:botMost,rigMost,:)=LabelLineColor; % 右边框
     labelImage(topMost,lefMost:rigMost,:)=LabelLineColor; % 上边框
     labelImage(botMost,lefMost:rigMost,:)=LabelLineColor; % 下边框
     counter=counter+1;
end
