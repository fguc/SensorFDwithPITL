clear
clc
close all

name = 'Sensor5Scenario';

parentDir = pwd;
dataDir = '2022-01-22_SquareRef';
caseDir = 'Sensor5Scenario';

parentFold = fullfile(parentDir,dataDir,caseDir);
cd(parentFold)

load(fullfile('DMDDataDL.mat'))
N = length(DMDDataDL.Data);
dataFold{N} = [];
for i=1:1:N
    dataFold{i} = ['Scenario_' num2str(i)];
end


%% Divide into Training and Validation Data
allImages = imageDatastore({fullfile(parentFold,dataFold{1})},...
    'IncludeSubfolders',true,...
    'LabelSource','foldernames');

rng default
[imgsTrain,imgsValidation] = splitEachLabel(allImages,0.8,'randomized');
disp(['Number of training images: ',num2str(numel(imgsTrain.Files))]);
[imgsTest,imgsValidation] = splitEachLabel(imgsValidation,0.5,'randomized');
disp(['Number of validation images: ',num2str(numel(imgsValidation.Files))]);
disp(['Number of test images: ',num2str(numel(imgsTest.Files))]);

%% GoogLeNet
net = googlenet;

lgraph = layerGraph(net);
% numberOfLayers = numel(lgraph.Layers);
% figure('Units','normalized','Position',[0.1 0.1 0.8 0.8]);
% plot(lgraph)
% title(['GoogLeNet Layer Graph: ',num2str(numberOfLayers),' Layers']);

net.Layers(1)

newDropoutLayer = dropoutLayer(0.6,'Name','new_Dropout');
lgraph = replaceLayer(lgraph,'pool5-drop_7x7_s1',newDropoutLayer);

numClasses = numel(categories(imgsTrain.Labels));
newConnectedLayer = fullyConnectedLayer(numClasses,'Name','new_fc',...
    'WeightLearnRateFactor',5,'BiasLearnRateFactor',5);
lgraph = replaceLayer(lgraph,'loss3-classifier',newConnectedLayer);

newClassLayer = classificationLayer('Name','new_classoutput');
lgraph = replaceLayer(lgraph,'output',newClassLayer);

options = trainingOptions('sgdm',...
    'MiniBatchSize',30,...
    'MaxEpochs',1000,...
    'InitialLearnRate',1e-4,...
    'ValidationData',imgsValidation,...
    'ValidationFrequency',10,...
    'Verbose',1,...
    'ExecutionEnvironment','auto',...
    'Plots','training-progress');
rng default

trainedGN = trainNetwork(imgsTrain,lgraph,options);

trainedGN.Layers(end)

[YPred,~] = classify(trainedGN,imgsTrain);
accuracy = mean(YPred==imgsTrain.Labels);
disp(['GoogLeNet Train Accuracy: ',num2str(100*accuracy),'%'])
figure
plotconfusion(imgsTrain.Labels,YPred)
saveas(gcf,[datestr(now, 'yyyy-mm-dd-HH-MM-SS-') name '-Conf_Train.png'])

[YPred,~] = classify(trainedGN,imgsValidation);
accuracy = mean(YPred==imgsValidation.Labels);
disp(['GoogLeNet Validation Accuracy: ',num2str(100*accuracy),'%'])
figure
plotconfusion(imgsValidation.Labels,YPred)
saveas(gcf,[datestr(now, 'yyyy-mm-dd-HH-MM-SS-') name '-Conf_Valid.png'])

[YPred,~] = classify(trainedGN,imgsTest);
accuracy = mean(YPred==imgsTest.Labels);
disp(['GoogLeNet Test Accuracy: ',num2str(100*accuracy),'%'])
figure
plotconfusion(imgsTest.Labels,YPred)
saveas(gcf,[datestr(now, 'yyyy-mm-dd-HH-MM-SS-') name '-Conf_Test.png'])

% probV = probs(49:56,[5 7 2])
wghts = trainedGN.Layers(2).Weights;
wghts = rescale(wghts);
wghts = imresize(wghts,5);
figure
montage(wghts)
title('First Convolutional Layer Weights')

convLayer = 'conv1-7x7_s2';

imgClass = 'Bias';
imgName = 'Bias_87.jpg';
imarr = imread('D:\Box\00_PhD\03_Publish\2022_01_MDPISensors\00_Matlab\2022-01-22_SquareRef\Sensor5Scenario\Scenario_1\Bias\Bias_87.jpg');

trainingFeaturesARR = activations(trainedGN,imarr,convLayer);
sz = size(trainingFeaturesARR);
trainingFeaturesARR = reshape(trainingFeaturesARR,[sz(1) sz(2) 1 sz(3)]);
figure
montage(rescale(trainingFeaturesARR),'Size',[8 8])
title([imgClass,' Activations'])

imgSize = size(imarr);
imgSize = imgSize(1:2);
[~,maxValueIndex] = max(max(max(trainingFeaturesARR)));
arrMax = trainingFeaturesARR(:,:,:,maxValueIndex);
arrMax = rescale(arrMax);
arrMax = imresize(arrMax,imgSize);
figure;
imshowpair(imarr,arrMax,'montage')
title(['Strongest ',imgClass,' Channel: ',num2str(maxValueIndex)])