% 2017-5-26 崔佳勋
% 将多幅图像组合在一起显示,图像以cell形式输入,图像矩阵形式输出
% dispCombineImage
% 
% 输入
% images        cell结构，每一个元祖保存一幅图像
%               一般具有相同大小
% 
% xBarImageCnt  垂直方向上显示的图像数量，默认为自动选取
% yBarImageCnt  垂直方向上显示的图像数量，默认为自动选取
% 
% 输出：
% combineImage  将所有的图像顺序在该图像上展示
%               展示前先进行归一化
%               以第一副图像的高度和宽度为标准进行归一化
% 
% 调用方式：
% [combineImage]=dispCombineImage(images)
% [combineImage]=dispCombineImage(images,xBarImageCnt,yBarImageCnt)
% 
function [combineImage]=dispCombineImage(images,varargin)
narginchk(1,3);% 检测输入参数数量
validateattributes(images,{'cell'},{'row'}, mfilename,'images',1);

imageCnt=length(images);      % 图像数量
if(imageCnt==0)               % 没有输入图像,退出      
    error('没有输入图像！');
end
if(nargin==3)                 % 指定横纵方向上显示的图像数量
    xBarImageCnt=varargin{1}; % 垂直方向上显示的图像数量
    yBarImageCnt=varargin{2}; % 水平方向上显示的图像数量
else                          % 自动确定 横纵方向上显示的图像数量
    xBarImageCnt=ceil(sqrt(imageCnt));
    yBarImageCnt=xBarImageCnt;
end

colorspaceCnt=size(images{1},3);% 颜色平面数量，1表示灰度图像，3表示彩色图像 

xSize=size(images{1},1);      % 垂直方向归一化尺寸，以第一副图像高度为标准  
ySize=size(images{1},2);      % 水平方向归一化尺寸，以第一副图像宽度为标准

maxsize=800;                  % 每幅图像高度与宽度的最大值
while( xSize>=maxsize || ySize>=maxsize ) % 保证宽度与高度不超过最大值
    xSize=ceil(xSize/2);      % 高度减半
    ySize=ceil(ySize/2);      % 宽度减半
end

counter=1;
breakOutFlag=0;              % 是否退出标志，为1表示已处理完毕，退出循环
for i=1:xBarImageCnt
    for j=1:yBarImageCnt
        xRange=(xSize*(i-1)+1):xSize*i; % 垂直方向位置
        yRange=(ySize*(j-1)+1):ySize*j; % 水平方向位置 
        for k=1:colorspaceCnt             % 对图像的每个平面进行归一化处理 
           combineImage(xRange,yRange,k)=...% 并在组合图像中展示
               imresize(images{counter}(:,:,k),[xSize,ySize]);
        end
        counter=counter+1;
        if(counter>imageCnt) % 所有图像均已展示完毕，则退出循环 
            breakOutFlag=1;
            break;
        end
    end
    if(breakOutFlag==1)
        break;
    end
end


