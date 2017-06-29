% 2017-5-27崔佳勋
% 展示滑动窗口系列方法获得的平均统计数据
% dispWindowingResult
% 
% 数据通过 testMWSegment、testPyramidAnalysis
% 等方法获得
% 
% statsdata 获得的平均统计数据
% 
function [statsdata]=dispWindowingResult(varargin)
load MoveWindowSegmentResult1108.mat MWindowResult

plotStyle={'r-*','g-p','b-<','r->','g-o','b-+','r-s','g--h','b-.v','r-^','g-.','b-p'};

if( nargin>=2 )
    MWindowData=varargin{1};
    PyramidAnalysisData=varargin{2};
end

[statsdata{1}]=getAverayStatsData(MWindowResult);
[statsdata{2}]=getAverayStatsData(PyramidAnalysisData);

methodCnt=2;

figure(ceil(20077*rand)),
hold on,grid on,
for i=1:methodCnt
    xValue=statsdata{i}(:,2);
    yValue=statsdata{i}(:,1);
    plot(xValue,yValue,plotStyle{i});
end
xlabel('误检率');
ylabel('检测率');
title('ROC曲线');
legend('滑动窗口方法','金字塔分析');

% 
% 求检测率/误检率等数据的平均值
% 
% 针对每个阈值统计每种方法获得统计数据的平均值
% 每一个阈值对应一个系列的平均值（对图片求均值）
% 
% 结果统计数据保存格式为：{图片编号}{阈值编号}Cell
% 每一个元祖包含每幅图像每个阈值下获得的统计数据：
% AreaTPRate 病斑面积的检测率
% AreaFPRate 病斑面积的误检率
% CntTPRate  病斑数量的检测率
% labDisCnt  搜索图像上获得的病斑数量
% StdDisCnt  人工标记图像上的病斑数量
% labTPArea  病斑区域的检测面积
% labFPArea  病斑区域的错误检测面积
% StdDisArea 人工标记图像上的标准病斑面积
% costtime   本次运行花费时间
% 
function [statsAnalysisData]=getAverayStatsData(statsData)
imageCnt=length(statsData);                % 分析的图片数量 
threshCnt=length(statsData{1});            % 阈值数量
nArgOut=length(statsData{1}{1});           % 统计数据的个数 
statsAnalysisData=zeros(threshCnt,nArgOut);% 统计分析的平均值结果
for curThreshNO=1:threshCnt                % 每一个阈值对应一个系列的平均值 
    for i=1:imageCnt
        curArgIndex=1:nArgOut;             % 求平均值的数据下标索引
        statsAnalysisData(curThreshNO,curArgIndex)=...% 对每幅图像获得的结果求和
            statsAnalysisData(curThreshNO,curArgIndex)+statsData{i}{curThreshNO};
    end
end
statsAnalysisData=statsAnalysisData./imageCnt;        % 对每幅图像获得的结果求平均

