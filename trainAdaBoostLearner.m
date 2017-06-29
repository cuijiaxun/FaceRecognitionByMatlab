% 2017-5-21 崔佳勋
% AdaBoost 学习算法 训练过程,目的在于获得一个AdaBoost强学习器
% trainAdaBoostLearner
% AdaBoost 弱分类器为二值分类器
% 
% 算法参考：Robust Real-time Object Detection.pdf
%
% 训练T轮,将会获得第1轮至第T轮的数据,包括弱假设,训练错误率等
% 
% AdaBoost 学习算法 包括训练与测试过程
% AdaBoostClassfy            AdaBoost 学习算法 对一组样本进行分类
% AdaBoostWeakLearnerClassfy AdaBoost 弱假设对一组样本进行分类
% searchBestWeakLearner      在特征列上获得最优的阈值分类器
% trainAdaBoostLearner       AdaBoost 学习算法 训练过程
% testAdaBoostLearner        AdaBoost 学习算法 测试过程
% testAdaBoost(训练与测试)    将样本随机划分为训练集与测试集，多次训练测试 AdaBoost 学习算法
% AdaBoost(训练与测试)        给定训练集与测试集,训练测试AdaBoost分类器
% 
% testAdaBoost 与 AdaBoost 类似，均是先训练，而后测试
% testAdaBoost 测试多次，并且将样本集分为训练集与测试集
% testAdaBoost 通过调用 AdaBoost 函数进行多次的 AdaBoost 算法 训练与测试
% AdaBoost调用 trainAdaBoostLearner 学习分类器
%         调用 testAdaBoostLearner 测试分类器
% 
% 
% 
% 输入:
% X            训练数据集
%              cntSamples X cntFeatures 维矩阵
%              cntSamples 个样本，每个样本cntFeatures个特征值
%              cntSamples    训练数据集中样本数量
%              cntFeatures   特征空间维数
%              如特征矩阵：
%                     特征1 特征2  特征3  特征4
%              样本1    1     2     1     1
%              样本2    2     3     5     2
%              样本3    5     1     2     1
%              样本4    2     4     5     2
%             
% Y            每个样本所属类别的标识,行向量, 1 x cntSamples
%              如：Y = [1 0 1 0]，表示第1个样本与第3个样本为正样本，2，4为负样本
% T            训练轮数
% cntSelectFeatures 
%              可选参数，需要训练指定数量的特征的数量
%              若输入4个参数，则表示不会依照训练轮数为T的规则
%              此时将一直训练，直至分类器训练出指定的特征
%              在这种情况下 costTime 指提取单个特征所获得的时间
% 
% 输出：
% Hypothesis     训练获取的假设,T x 3 矩阵
%                共T个弱分类器，每个弱分类器的组成是 [阈值 偏置 特征列]
%                如4个弱分类器组成的强分类器如下：
%                    阈值     偏置 特征列
%                   -16.4151    1   27
%                     0.0073    1  291
%                     0.4482   -1   14
%                     0.0540    1  315
% 
% AlphaT         每轮假设的权值,1xT 向量
% trainErrorRate 在训练数据集上第1轮至第T轮的训练错误率,1xT 向量
% costTime       训练第1轮至第T轮的花费时间
%
% 调用格式：
% [Hypothesis,AlphaT,trainErrorRate,costTime]=trainAdaBoostLearner(X,Y,T)
% [Hypothesis,AlphaT,trainErrorRate,costTime]=trainAdaBoostLearner(X,Y,T,cntSelectFeatures)
% 
%  
%  增加 返回参数 TPRate,FPRate 用于画图像的ROC曲线
% 同时被修改的三个函数：
% trainAdaBoostLearner, trainFloatBoostLearner, trainSceBoostLearner
%
function [Hypothesis,AlphaT,trainErrorRate,costTime,TPRate,FPRate]=trainAdaBoostLearner(X,Y,T,varargin)
error(nargchk(3,4,nargin)); % 必须输入3-4个参数,否则中止程序
validateattributes(X,{'numeric'},{'2d','real','nonsparse'}, mfilename,'X',1);
validateattributes(Y,{'logical','numeric'},{'row','nonempty','integer'},mfilename, 'Y', 2);
validateattributes(T,{'numeric'},{'row','nonempty','integer'},mfilename, 'T',3);
if( length(T) > 1 )              % 指定训练轮数的参数T长度应为1（不能为向量）
    error(['指定训练轮数的参数(T)长度(' num2str(length(T)) ')应为1(不能为向量).']);
end

[cntSamples,cntFeatures]=size(X); % cntSamples  训练数据集中样本数量
                                  % cntFeatures 特征空间维数
inverseControl=0;           % 控制循环退出标识，为0表示训练T轮，否则需要训练出指定数量的特征
cntSelectFeatures=0;        % 需要选择的特征数量 

if( nargin>3 )              % 若输入4个参数，则表示不会依照训练轮数为T的规则
                            % 此时将一直训练，直至分类器训练出指定的特征
    cntSelectFeatures=varargin{1};
    inverseControl=1;
    validateattributes(cntSelectFeatures,{'numeric'},{'row','nonempty','integer'},mfilename, 'cntSelectFeatures',4);
    if( length(cntSelectFeatures) > 1 ) % 指定特征数量的参数长度应为1（不能为向量）
        error(['指定特征数量的参数(cntSelectFeatures)长度(' num2str(length(cntSelectFeatures)) ')应为1.']);
    end
    if( cntSelectFeatures>=cntFeatures )
        error('需要选择的特征数量(cntSelectFeatures)过大！');
    end
end
if( cntSamples~=length(Y) ) % 训练样本X必须被监督
    error('训练样本X长度必须与类标向量长度相同') ;
end

computeCosttimeFlag=1;      % 计时标识符，为1表示对训练时间计时
if(computeCosttimeFlag==1)
    tic
end

X=ceil(X*10000)/10000;          % 训练数据整理：删除尾部数据，防止产生误差
positiveCols=find(Y==1);        % 正训练样本标号
negativeCols=find(Y==0);        % 负训练样本标号
%{
if(length(positiveCols)==0)     % 检查正样本数
    error('正样本数量为0,无法训练.');
end
if(length(negativeCols)==0)     % 检查负样本数
    error('负样本数量为0,无法训练.');
end
%}
weight=ones(cntSamples,1);       % 权值向量;列向量;一行代表一个样本的权重
weight(positiveCols)=1/(2*length(positiveCols));      % 正训练样例的初始权值
weight(negativeCols)=1/(2*length(negativeCols));      % 负训练样例的初始权值
Hypothesis=zeros(T,3);          % 通过T轮训练获取的T个弱假设，结构为:[阈值 偏置 特征列]
AlphaT=zeros(1,T);              % T轮训练获取的每个弱假设的权值
trainErrorRate=zeros(1,T);      % 第 1 轮至第 T 轮的训练错误率
costTime=zeros(1,T);            % 第 1 轮至第 T 轮花费的时间

trainOutput=zeros(1,cntSamples); % 临时变量:使用前t个分类器对训练数据进行分类的结果  
h=zeros(1,cntSamples);           % 临时变量:使用第t轮最优分类器进行分类 的结果      

TPRate = zeros(1,T);             % 第1至T轮检测率
FPRate = zeros(1,T);             % 第1至T轮误检率

t=1; 
curFeaSize=0;                   % 当前已经选择的特征的数量
while(true)                     % 训练轮数
    minError=cntSamples;        % 错误率初值：cntSamples
    weight=weight/(sum(weight));% 权值归一化
%     if(outputTips==1)
%         disp(strcat('当前第',num2str(t),'轮....'));
%     end
    for j=1:cntFeatures         % 对每个特征值,获取最优的分类器(假设)
        [tempError,tempThresh,tempBias]=searchBestWeakLearner(X(:,j),Y.',weight);
                                                      % 搜索获取j列最优的假设

        if(tempError<minError)                        % 在cntFeatures个最优的分类器中选择错误率最小的分类器
            minError=tempError;                       % 第t轮 最小的错误率
            Hypothesis(t,:)=[tempThresh,tempBias,j];  % 第t轮 最优弱分类器
        end
    end
    h=AdaBoostWeakLearnerClassfy(X,Hypothesis(t,:));   % 使用第t轮最优弱分类器进行分类
    
    errorRate=sum(weight(find(h~=Y)));                 % 计算第t轮分类错误率
    AlphaT(t)=log10((1-errorRate)/(errorRate+eps));    % 计算第t轮权重         
    if(errorRate>eps)                                  % 减小被正确分类的样本的权值
        weight(find(h==Y))=weight(find(h==Y))*(errorRate/(1-errorRate));                                     
    end
    % 下面是计算当前轮数(第t轮)下训练错误率
    [trainOutput]=AdaBoostClassfy(X,Hypothesis,AlphaT,t);
    [curErrorRate,curTPRate,curFPRate]=calPredictErrorRate(Y,trainOutput);
    trainErrorRate(t) = curErrorRate;
    TPRate(t) = curTPRate;
    FPRate(t) = curFPRate;
   
    if(inverseControl==0)            % 采用训练轮数限制循环
        if(computeCosttimeFlag==1)
            costTime(t)=toc;
        end
        if(t>=T)                     % 达到期望的训练轮数                       
             break;
        end
    else                             % 采用提取的特征数量限制循环
        [SelectFeaNo]=analysisHypothesisFeature(Hypothesis(1:t,:),0);
        if( length(SelectFeaNo)>curFeaSize )
            curFeaSize=length(SelectFeaNo);
            if( computeCosttimeFlag==1 )
                costTime(curFeaSize)=toc;
            end
        end
        if( curFeaSize>=cntSelectFeatures )% 达到期望的特征数量
            break;
        end
    end
    t=t+1;
end

if(computeCosttimeFlag==1)
    costTime=costTime(find(costTime~=0));% 输出训练时间
else
    costTime=0;
end

if(t<T)     
    Hypothesis=Hypothesis(1:t,:);      % 强分类器
    AlphaT=AlphaT(1:t);                % 强分类器权重
    trainErrorRate=trainErrorRate(1:t);% 训练错误率
end

