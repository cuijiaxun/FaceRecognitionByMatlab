% 2017-5-28崔佳勋
% 普通滑动窗口实现图像分割
% MoveWindowing
% 
% 输入参数:
% image               输入图像
% MVParameters        滑动窗口方法的参数，包含：
% ::WindowingPatchSize  搜索时的窗口大小序列
% ::xynum               窗口滑动过程中将图像划分的格数
% 
% WinParameters       对图像窗口进行判别的学习算法的参数
%                       不同的学习算法有不同的参数，比如 AdaBoost 包括如下参数 
% ::Method              ImageBlockRecogByAdaBoost，指定 AdaBoost 学习算法对图像块进行判别   
% ::Hypothesis          T个弱分类器经 AdaBoost 算法训练获得的强学习器
% ::AlphaT              各弱分类器的权重
% ::thresh              各弱分类器的阈值，默认为0.5
% 
% WinParameters         只有下面的参数是必须指定的：
% ::Method              对图像窗口进行判别的学习算法名称
% 其他参数依学习算法而定
% 
% 比如，采用 ImageBlockRecognizedByAdaBoost 对窗口判别时，参数应输入： 
% MVParameters.WindowingPatchSize=[60 80]; 搜索时的窗口大小序列
% MVParameters.xnum=30;                    水平方向上将图像划分的格数 
% MVParameters.ynum=30;                    垂直方向上将图像划分的格数 
% 
% WindowParameters.Method=@ImageBlockRecognizedByAdaBoost;
% WindowParameters.Hypothesis=AreaHypothesis;
% WindowParameters.AlphaT=AreaAlphaT;
% WindowParameters.thresh=0.5;
% 
% 
% 返回:
% detectWindow          检测为人脸的窗口信息
%                       其格式为[i j WinSize]，即[横坐标 纵坐标 窗口大小]
% detectImage           检测图像，在原始图像上标识了人脸窗口的图像
% pixFreImage           像素在窗口中出现次数的频率图像 
% 
% 调用：
% [detectWindow,detectImage,pixFreImage]=
%               MoveWindowing(image,MVParameters,WindowParameters)
% 

function [detectWindow,detectImage,pixFreImage]=MoveWindowing(image,MVParameters,WindowParameters)
narginchk(3,3);  % 检测输入参数数量
validateattributes(image,{'numeric'},{'real','nonsparse'}, mfilename,'image',1);

WindowingPatchSize=MVParameters.WindowingPatchSize; % 搜索时的窗口大小序列
xnum=MVParameters.xnum;                % 窗口滑动过程中垂直方向上图像划分的格数 
ynum=MVParameters.ynum;                % 窗口滑动过程中水平方向上图像划分的格数 
validateattributes(WindowingPatchSize,{'numeric'},{'row','integer'}, mfilename,'WindowingPatchSize',2);
validateattributes(xnum,{'numeric'},{'row','real','integer'}, mfilename,'xynum',2);
validateattributes(ynum,{'numeric'},{'row','real','integer'}, mfilename,'xynum',2);

[xSize,ySize]=size(image); %必须是灰度图像
%image=rgb2gray(image);

%imageSize=[xSize,ySize];
disp('滑动窗口识别...');

xstep=ceil(xSize/xnum);        % 垂直方向移动尺寸
ystep=ceil(ySize/ynum);        % 水平方向移动尺寸
detectWindow=[];               % 检测的人脸窗口信息

MWCounter=1;
for i=1:xstep:xSize            % 穷举法搜索窗口
    for j=1:ystep:ySize
        detectWindow1=[];  
        disp(MWCounter);
        MWCounter=MWCounter+1; % 窗口计数器增加 
        for k=1:length(WindowingPatchSize) % 改变窗口大小搜索
            xx=i+WindowingPatchSize(k)-1;  % 窗口右边缘
            yy=j+WindowingPatchSize(k)-1;  % 窗口下边缘
            if(xx>xSize||yy>ySize)         % 窗口越边界    
                break;
            end
            windata=image(i:xx,j:yy);    % 窗口数据   
            % 根据指定的学习算法测试该窗口是否为人脸窗口
            [output]=feval(WindowParameters.Method,windata,WindowParameters); 
            
            if(output==1)     % 保存已判为人脸的区域
                tempWinInfo=[i j WindowingPatchSize(k)];% 人脸窗口信息
                detectWindow1=[detectWindow1;tempWinInfo];% 保存人脸窗口
            end
        end
        size(detectWindow1,1)
        %detectWindow1=detectWindow1
        detectWindow=[detectWindow;detectWindow1];% 保存人脸窗口
        
    end
end


if(nargin>1)   % 输出标识了人脸窗口的图像
    detectImage=LabelDetectWindow(image,detectWindow);
end

if(nargin>2)  %  输出像素在窗口中出现次数的频率图像    
    pixFreImage=CalPixelFrequencyInWindow(size(image),detectWindow,1);
end
