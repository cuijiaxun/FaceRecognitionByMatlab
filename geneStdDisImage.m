% 生成标准的病斑标记图像
% geneStdDisImage
% 
% 使用人工标记的图像减去原始的图像
% 得到两者的差值图像
% 对差值图像进行阈值分割，即可获得标识的病斑区域
%
% 输入：
% DiffImage  差值图像
%            手工标记图像与原始图像之差，通过两者差值识别出病斑区域
% winSize    进行阈值分割的窗口大小
% thresh     阈值，若差值大于此阈值，则被认为是人工标记的病斑区域
% 
% 输出：
% labImage   输出的病斑标记图像，1表示病斑区域
% 
% 
% 
% 
function [labImage]=geneStdDisImage(DiffImage,winSize,thresh)
imageHeight=size(DiffImage,1);   % 差值图象区域高度
imageWidth=size(DiffImage,2);    % 差值图象区域宽度
xstep=winSize;                   % 窗口在垂直方向每次移动步长
ystep=xstep;                     % 窗口在水平方向每次移动步长

% 标记图像，保存读取的病斑信息 0:无病斑，1:已被标记为病斑窗口
labImage=zeros(imageHeight,imageWidth); 

i=1;
while(i<=(imageHeight-winSize))       % 忽略边缘区域
    j=1;
    while(j<=(imageWidth-winSize)) 
        window=DiffImage(i:(i+winSize-1),j:(j+winSize-1));% 在差值图象上,获取该窗口区域的数据
        center=mean2(window(:,:));
        if(center>=thresh)
             labImage(i:(i+winSize-1),j:(j+winSize-1))=1;  % 标志为病害窗口
        end
        j=j+ystep;   % 窗口移动
    end
    i=i+xstep;       % 窗口移动至下一行
end
