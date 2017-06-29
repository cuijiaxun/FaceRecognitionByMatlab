% 获得标准的病斑标记图像
% generateStdDiseaseImage
% 
% 本函数仅完成调用功能
% 需与函数geneStdDisImage联合使用
% 
% 通过对原始图像和人工标识图像的处理，获得标识后的病斑区域
% 
% 使用人工标记的图像减去原始的图像
% 得到两者的差值图像
% 对差值图像进行阈值分割，即可获得标识的病斑区域
% 
%
% 
function [labImage]=getStdDisImage(fileNO)
winSize=2;   % 进行阈值分割的窗口大小（每次提取一个窗口进行分割）
thresh=10;   % 进行阈值分割的窗口阈值
dirPathSource='TestPicture\\TestOrangeCanker\\';   % 原始图像目录
dirPathModify='TestPicture\\TestOrangeCanker2\\';  % 人工标记图像目录 
preFilename='TestOrangeCanker-';
fileFormate='.jpg';
filename=strcat(preFilename,num2str(fileNO),fileFormate);% 文件名

fileSource=strcat(dirPathSource,filename);   % 原始图像文件名
fileModified=strcat(dirPathModify,filename); % 人工标记图像文件名

rawimage=rgb2gray(imread(fileSource));       % 原始图像
manualImage=rgb2gray(imread(fileModified));  % 手工标记图像
DiffImage=(manualImage-rawimage);            % 原始图像与手工标记的差别图像

% 通过图像之差标识出病斑区域
[labImage]=geneStdDisImage(DiffImage,winSize,thresh);


