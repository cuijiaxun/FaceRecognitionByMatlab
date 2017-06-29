% 2017-5-23崔佳勋
% 定量测度识别的病斑区域与人工标注的区域的差别
% calDetectRate
% 
% 计算病斑的检测率、花费时间
% 计算病斑面积的检测率和误检率
% 
% 计算参数：
% AreaTPRate 病斑面积的检测率
% AreaFPRate 病斑面积的误检率
% CntTPRate  病斑数量的检测率
% labDisCnt  搜索图像上获得的病斑数量
% StdDisCnt  人工标记图像上的病斑数量
% labTPArea  病斑区域的检测面积
% labFPArea  病斑区域的错误检测面积
% StdDisArea 人工标记图像上的标准病斑面积
% 
% 
% 输出参数：
% detectrate       所有计算数据组成的向量, 输出格式
%                  AreaTPRate AreaFPRate CntTPRate labDisCnt  
%                  StdDisCnt labTPArea labFPArea StdDisArea
% detectProperties 所有计算数据组成的结构体 
% 
% 输入参数：
% StdImage      通过人工标记图像获得的标准病斑标示图像 
% labStim       通过识别算法获得的病斑标记图像,0为病斑,其他为非病斑
% Thresh        判定所选区域是否为病斑的阈值
%               只有大于该值，才认为找到了完整的病斑
% 
% [detectrate,detectProperties]=calDetectRate(StdImage,labImage)
% [detectrate,detectProperties]=calDetectRate(StdImage,labImage,Thresh);
% 

function [detectrate,detectProperties]=calDetectRate(StdImage,labImage,varargin)
iptchecknargin(2,3,nargin,mfilename);   % 检测输入参数数量
iptcheckinput(StdImage,{'numeric'},{'2d','real','nonsparse'}, mfilename,'StdImage',1);
iptcheckinput(labImage,{'numeric'},{'2d','real','nonsparse'}, mfilename,'labImage',2);

Thresh=0.6;       % 判定所选区域是否为病斑的阈值
if(nargin>2)      % 指定判定区域为病斑的阈值
    Thresh=varargin{1};
end

[StdImage,StdDisCnt]=bwlabel(StdImage,8); % 标记连通区域
if(StdDisCnt==0)                                 
    error('该叶片上不存在病斑，无法计算检测率~');
end
StdDisArea=length(find(StdImage~=0));    % 人工标记图像上的标准病斑面积

labDisCnt=0;  % 图像上检测获得的病斑数量                             
labTPArea=0;  % 病斑区域的检测面积

for i=1:StdDisCnt                        % 人工标记图像上的标准病斑数量
    [rows cols]=find(StdImage==i);
    curDisArea=0;

    for j=1:length(rows)
        if(labImage(rows(j),cols(j))~=0)
            curDisArea=curDisArea+1;
            labImage(rows(j),cols(j))=-1;
        end
    end
    labTPArea=labTPArea+curDisArea;     % 病斑区域的检测面积
    curDisAreaRate=curDisArea/length(rows);% 检测病斑所占比例
                
    if(curDisAreaRate>=Thresh)          % 超过阈值，则增加病斑数 
        labDisCnt=labDisCnt+1;
    end
end

labFPArea=length(find(labImage>0));    % 病斑区域的误检面积

AreaTPRate=labTPArea/(StdDisArea+eps); % 病斑面积的检测率
AreaFPRate=labFPArea/length(find(StdImage==0)); % 病斑面积的误检率
CntTPRate=labDisCnt/(StdDisCnt+eps);   % 病斑数量的检测率

% 以向量形式输出计算检测参数
detectrate=[AreaTPRate,AreaFPRate,CntTPRate,labDisCnt,StdDisCnt,labTPArea,labFPArea,StdDisArea];
 
if(nargout>1)  % 以结构体形式输出计算检测参数
    detectProperties.AreaTPRate=AreaTPRate; % 病斑面积的检测率
    detectProperties.AreaFPRate=AreaFPRate; % 病斑面积的误检率
    detectProperties.CntTPRate=CntTPRate;   % 病斑数量的检测率
    detectProperties.labDisCnt=labDisCnt;   % 搜索图像上获得的病斑数量
    detectProperties.StdDisCnt=StdDisCnt;   % 人工标记图像上的病斑数量
    detectProperties.labTPArea=labTPArea;   % 病斑区域的检测面积
    detectProperties.labFPArea=labFPArea;   % 病斑区域的错误检测面积
    detectProperties.StdDisArea=StdDisArea; % 人工标记图像上的标准病斑面积
end

