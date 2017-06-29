% 2017-5-28崔佳勋
% 对标记图像进行阈值分割
%
% 标记图像里像素值大于Thresh，则认为时病斑，否则认为是非病斑
% 
% 输入：
% image     进行阈值分割的图像
% thresh    分割的阈值
% bias      分割的偏置，默认为1
%           bias=+1  大于阈值为1，小于阈值为0
%           bias=-1  大于阈值为0，小于阈值为1
% bgImage   背景图像，image上标识为目标的区域被保留，而标识为背景的则删除
%           默认为进行阈值分割的图像，即image
% 
% 输出：
% labBinaryImage 标识病斑图像、二值图像
% labSrcImage    在背景图像上作标记，标识病斑区域
% 
% [labBinaryImage,labSrcImage]=ThreshSegement(image,thresh);
% [labBinaryImage,labSrcImage]=ThreshSegement(image,thresh,bias);
% [labBinaryImage,labSrcImage]=ThreshSegement(image,thresh,bias,bgimage);
% 
% 
function [labBinaryImage,labSrcImage]=ThreshSegement(image,thresh,varargin)
narginchk(2,4);  % 检测输入参数数量
validateattributes(image,{'numeric'},{'2d','real','nonsparse'}, mfilename,'image',1);
validateattributes(thresh,{'numeric'},{'row','nonempty','real'},mfilename, 'thresh',2);
thresh=thresh(1);    % 只取第一个阈值
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
    if( (size(bgImage,1)~=size(image,1))||(size(bgImage,2)~=size(image,2)) )
        error('背景图像大小需与分割图像完全一致。');
    end
else
    bgImage=image;  % 默认为进行阈值分割的图像image
end
validateattributes(bgImage,{'numeric'},{'real','nonsparse'}, mfilename,'bgImage',4);


% 阈值分割，生成两幅标记图像
labBinaryImage=zeros(size(image));  % 在二值图像上标识病斑区域

labBinaryImage(find(bias*image>=bias*thresh))=1;


if ( nargout>1 )                   % 输出背景图像上标识病斑区域
    for cur=1:size(bgImage,3)      % 对每个平面均进行标记
        curLabSrcImage=bgImage(:,:,cur); 
        curLabSrcImage(find(bias*image<bias*thresh))=0;
        labSrcImage(:,:,cur)=curLabSrcImage;
    end
end







