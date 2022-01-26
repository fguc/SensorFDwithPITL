clear
clc
close all

parentDir = pwd;
dataDir = '2022-01-24_SquareRef_L10';
caseDir = 'Sensor5Scenario';

cd(fullfile(parentDir,dataDir,caseDir))

load(fullfile('DMDDataDL.mat'))

for i = 1:1:length(DMDDataDL.Data)
    refFolder = ['Scenario_' num2str(i)];
    
    Data = DMDDataDL.Data(1,i);
    Data = Data{1};
    Labels = DMDDataDL.Labels(1,i);
    Labels = Labels{1};
    
    dataWndL = size(Data,2);
    Fs = 100;
    fb = cwtfilterbank('SignalLength',dataWndL,...
        'SamplingFrequency',Fs,...
        'VoicesPerOctave',12);
    
    r = size(Data,1);
    
    for ii = 1:r
        cfs = abs(fb.wt(Data(ii,:)));
        im = ind2rgb(im2uint8(rescale(cfs)),jet(128));
        
        imgLoc = fullfile(fullfile(parentDir,dataDir,caseDir,refFolder),char(Labels(ii)));
        if exist(imgLoc,'dir')
            
        else
            mkdir(imgLoc)
        end
        imFileName = strcat(char(Labels(ii)),'_',num2str(ii),'.jpg');
        imwrite(imresize(im,[224 224]),fullfile(imgLoc,imFileName),'jpg');
    end
    disp([refFolder ' completed!!'])
end

