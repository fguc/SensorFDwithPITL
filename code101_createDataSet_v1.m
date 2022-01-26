clear
clc
close all

% Reference inputs
parentFolder = pwd;
childFolder = ['2022-01-24_SquareRef_L10'];
caseFolder = 'Sensor5Scenario';
root = fullfile(parentFolder,childFolder,caseFolder);
mkdir(root)

% Scenario inputs
simDef = {'Nominal'...
    'Bias'...
    'Drift'...
    'Sine'...
    'Noise'};

simInputs = diag(1:5);
simRefCurrent = 1;

A = 1:1:length(simDef);
B = repmat(A,1,300);

sim{length(B)} = {};
i = 1; j = length(B);
MatPhi{i} = [];
MatLabels{i}  = [];

tic

idx = 1;
% Run Simulation
for numSim = B
    disp(['Iteration for Sim:' num2str(idx) '/' num2str(length(B))])
    simData.simName = 'model_FOPTD_DMD_5SensorScenario_v1.slx';
    simData.thresh = 5;
    simData.rtil = 11;
    simData.r = 11;
    %         simData.DMDWndw = floor(length(simRefCurrent.Time)*0.97);
    simData.DMDWndw = 1900;

    simData.simDef = simDef{numSim};
    simData.simInputs = simInputs(numSim,:);
    [simData.dataDMD.ys,simData.dataDMD.r,simData.dataDMD.raw] = runSimulation_v1(simData,numSim);

    % DMDc
    [simData.resultsDMDc] = runAlgorithmDMDc_v1(simData);
    if idx ==1
        plotSingVal_v1(simData);
        plotDMDModes_v1(simData);
    end
    
    sim{1,idx} = simData;
    idx = idx+1;
end

[MatPhi{1},MatLabels{1}] = processDMDModes_v1(sim,1,simData.r);
toc

DMDDataDL.Data = MatPhi;
DMDDataDL.Labels = MatLabels;

saveRoot = fullfile(parentFolder,childFolder,caseFolder);
cd(saveRoot)

save DMDDataDL DMDDataDL