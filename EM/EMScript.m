
clc
clear all

[imageData1a] = imread('images/image1_a.png');
[imageData1b] = imread('images/image1_b.png');
[imageData1c] = imread('images/image1_c.png');
[imageData2a] = imread('images/image2_a.png');
[imageData2b] = imread('images/image2_b.png');
[imageData2c] = imread('images/image2_c.png');

startMiu = InitParam.Qn1Image1b();
[rows, numOfKernel] = size(startMiu);
segmentMode = 0; %segmentMode off

[miu, maskOut] = EMImageSegment(imageData1b, startMiu, segmentMode);

figure, imshow(imageData1b,'InitialMagnification', 1000);
hold on
for c = 1:numOfKernel
    plot(startMiu(4,c),startMiu(5,c),'Marker','o',...
        'MarkerSize',10, 'MarkerFaceColor',[.49 1 .63]);
    hold on
end

for c = 1:numOfKernel
    plot(miu(4,c), miu(5,c), 'Marker', 'o',...
        'MarkerSize',7,'MarkerFaceColor',[.9 .9 .9]);
    hold on
end



%Image2b
%  imwrite(imageData, 'originalQ12b.png');
startMiu = InitParam.Qn3Image2b();
[rows, numOfKernel] = size(startMiu);

[miu, maskOut] = EMImageSegment(imageData2b, startMiu, segmentMode);
imwrite(maskOut, 'Qn1Image2b.png');


figure, imshow(imageData2b, 'InitialMagnification', 1000);
hold on
for c = 1:numOfKernel
    plot(startMiu(4,c),startMiu(5,c),'Marker','o',...
        'MarkerSize',10, 'MarkerFaceColor',[.49 1 .63]);
    hold on
end

for c = 1:numOfKernel
    plot(miu(4,c), miu(5,c), 'Marker', 'o',...
        'MarkerSize',7,'MarkerFaceColor',[.9 .9 .9]);
    hold on
end

hold off


%===============Question 2===============%

%for 13 kernels
startMiu = InitParam.Qn2Image2c13k();
segmentMode = 0; %segmentation off
[miu, maskOut] = EMImageSegment(imageData2c, startMiu, segmentMode);
imwrite(maskOut, 'Qn2Image2c13k.png');

%for 9 kernels
startMiu = InitParam.Qn2Image2c9k();
[miu, maskOut] = EMImageSegment(imageData2c, startMiu, segmentMode);
imwrite(maskOut, 'Qn2Image2c9k.png');

%==============Question 3================%
startMiu = InitParam.Qn3Image1b();
segmentMode = 1; %segmentation on
[miu, maskOut] = EMImageSegment(imageData1b, startMiu, segmentMode);
imwrite(maskOut, 'Qn3Image1b.png');

startMiu = InitParam.Qn3Image2b();
[miu, maskOut] = EMImageSegment(imageData2b, startMiu, segmentMode);
imwrite(maskOut, 'Qn3Image2b.png');

