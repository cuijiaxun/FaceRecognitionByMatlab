% 2017-5-28 崔佳勋
% 多阈值分割
%
% 标记图像里像素值大于Thresh，则认为时病斑，否则认为是非病斑
% 调用ThreshSegement实现
% 
% 输入：
% image     进行阈值分割的图像
% thresh    阈值（>=1）
% bias      分割的偏置，默认为1
%           bias=+1  大于阈值为1，小于阈值为0
%           bias=-1  大于阈值为0，小于阈值为1
% bgImage   背景图像，image上标识为目标的区域被保留，而标识为背景的则删除
%           默认为进行阈值分割的图像，即image
% 
% 输出：
% labBinaryImage 标识病斑图像,二值图像,cell元组
% labSrcImage    在背景图像上作标记，标识病斑区域,cell元组
% 
% labBinaryImage、labSrcImage均为cell
% 每一个阈值对应一组标记
% 此时,length(thresh)=length(labBinaryImage)=length(labSrcImage)
% 
% [labBinaryImage,labSrcImage]=MultiThreshSegement(image,thresh);
% [labBinaryImage,labSrcImage]=MultiThreshSegement(image,thresh,bias);
% [labBinaryImage,labSrcImage]=MultiThreshSegement(image,thresh,bias,bgimage);
% 
% 
function [labBinaryImage,labSrcImage]=MultiThreshSegement(image,thresh,varargin)
narginchk(2,4);  % 检测输入参数数量
validateattributes(image,{'numeric'},{'2d','real','nonsparse'}, mfilename,'image',1);
validateattributes(thresh,{'numeric'},{'row','nonempty','real'},mfilename, 'thresh',2);

bias=1;              % 偏置，默认为1
if(nargin>2)         % 指定偏置
    bias=varargin{1};  
end
if(bias~=1)          % 偏置只允许取值1和-1
    bias=-1;
end
image=double(image); % 类型转换 
validateattributes(bias,{'numeric'},{'row','nonempty','integer'},mfilename, 'bias',3);

if(nargin>3)        % 显示的背景图像
    bgImage=varargin{2}; 
else
    bgImage=image;  % 默认为进行阈值分割的图像image
end
validateattributes(bgImage,{'numeric'},{'real','nonsparse'}, mfilename,'bgImage',4);

% 用多个阈值分割，生成一系列标记图像
ThreshNO=length(thresh);          % 阈值数量  
labBinaryImage=cell(1,ThreshNO);  % 在二值图像上标识病斑区域,cell
labSrcImage=cell(1,ThreshNO);     % 在原始图像上标识病斑区域,cell


for curThreshNO=1:length(thresh)  % 一个阈值对应两幅标记图像
    [curlabBinaryImage,curlabSrcImage]=ThreshSegement(image,thresh(curThreshNO),bias,bgImage);
    
    labBinaryImage{curThreshNO}=curlabBinaryImage;
    labSrcImage{curThreshNO}=curlabSrcImage;
end







