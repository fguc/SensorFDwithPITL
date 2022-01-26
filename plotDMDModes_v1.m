function [] = plotDMDModes_v1(simData)
resultsDMDc = simData.resultsDMDc;
dataRaw = simData.dataDMD.raw;

numPlot=8;
a = 4;
b = 2;

figure
set(gcf, 'units','normalized','outerposition',[0.0 0.1 0.32 0.7]);
subplot(a,b,numPlot)
plot(dataRaw.r{1},'r','LineWidth',2)
grid on; hold on
plot(dataRaw.ys{1},'k','LineWidth',1)
plot(dataRaw.y{1},'b','LineWidth',1)
set(gca,'FontSize',10);
title([simData.simDef ' Scenario with 95% window'])

eigStr = num2str(diag(resultsDMDc.eigs));
for idx=1:1:7
    subplot(a,b,idx)
    plot(dataRaw.time(1:length(real(resultsDMDc.Phi(:,idx))),1),real(resultsDMDc.Phi(:,idx)),'k','LineWidth',1)
    set(gca,'FontSize',10);
    title(['\lambda:' eigStr(idx,:)])
    grid on
%     disp(['Case: ' num2str(idx) ' eigs: ' num2str(std(imag(resultsDMDc.eigs(:,idx))))]);
end
saveas(gca,'plotDMDModes.png');

temp = diag(resultsDMDc.eigs);

% figure
% theta = (0:0.1:100)*2*pi/100;
% plot(cos(theta),sin(theta),'--') % plot unit circle
% hold on, grid on
% scatter(real(temp(1:7)),imag(temp(1:7)),60)
% xlabel('$\mathcal{R}$','Interpreter','latex')
% ylabel('$\mathcal{I}$','Interpreter','latex')
% axis([-0.05 0.6 -0.035 0.035]);
% set(gca,'FontSize',16);
% saveas(gca,'plotEigVal.png');

