% 2017-5-17 崔佳勋
% 求原始亮度图像的积分图像
% 积分图像第一行和第一列值均为0
% 方便后续的求取矩形区域值
function [II]=IntegralImage(srcImage)
srcImage=double(srcImage);
imgWidth=size(srcImage,1);
imgHeight=size(srcImage,2);
II=zeros(imgWidth+1,imgHeight+1);
for i=1:imgWidth
    for j=1:imgHeight
        if i==1 && j==1             %积分图像左上角
            II(i,j)=srcImage(i,j);
        elseif i==1 && j~=1         %积分图像第一行
            II(i,j)=II(i,j-1)+srcImage(i,j);
        elseif i~=1 && j==1         %积分图像第一列
            II(i,j)=II(i-1,j)+srcImage(i,j);
        else                        %积分图像其它像素
            II(i,j)=srcImage(i,j)+II(i-1,j)+II(i,j-1)-II(i-1,j-1);  
        end
    end
end

end 

