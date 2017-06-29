%2017-5-23崔佳勋
%统计各像素在检测窗口内出现的频率
% 并可转化成灰度图像
% CalPixelFrequencyInWindow
% 
% 在窗口分割系列算法(Windowing)中通用
%
% 输入数据：
% StimSize            原始的RGB图像的大小
% detectWindow        检测为病斑的窗口信息
%                     其格式为[i j k]，即[横坐标 纵坐标 窗口大小]
% isMat2Gray          是否将频率矩阵转化为灰度图像的标志
%
% 输出：
% pixFreImage         将频率矩阵转化为灰度图像
%
% 
function [pixFreImage]=CalPixelFrequencyInWindow(StimSize,detectWindow,varargin)
narginchk(2,3);   % 检测输入参数数量
iptcheckinput(StimSize,{'numeric'},{'row','nonempty','integer'},mfilename, 'StimSize',1);
iptcheckinput(detectWindow,{'numeric'},{'2d','real','nonsparse'}, mfilename,'detectWindow',2);

isMat2Gray=0;  % 是否将频率矩阵转化为灰度图像的标志；默认不转换
if(nargin>2)   % 指定该标志
    isMat2Gray=varargin{1};
end

winCnt=size(detectWindow,1);         % 窗口数量
xSize=StimSize(1);                   % 原始的RGB图像的宽度
ySize=StimSize(2);                   % 原始的RGB图像的高度
pixFreImage=zeros(xSize,ySize);      % 像素在窗口中出现的频率矩阵

counter=1;
while(counter<=winCnt)
         i=detectWindow(counter,1);  % 病斑窗口 横坐标            
         j=detectWindow(counter,2);  % 病斑窗口 纵坐标
         winSize=detectWindow(counter,3);% 病斑窗口 大小
         
         topMost=i;                  % 窗口上边缘
         botMost=i+winSize-1;        % 窗口下边缘
         lefMost=j;                  % 窗口左边缘
         rigMost=j+winSize-1;        % 窗口右边缘

         % 窗口像素的标记值增1
         pixFreImage(topMost:botMost,lefMost:rigMost)=pixFreImage(topMost:botMost,lefMost:rigMost)+1;  
         counter=counter+1;
end

if(isMat2Gray) % 频率矩阵转化为灰度图像         
    pixFreImage=mat2gray(pixFreImage);               
end
