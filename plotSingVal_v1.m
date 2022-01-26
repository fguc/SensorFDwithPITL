function [] = plotSingVal_v1(simData)
Sig = simData.resultsDMDc.Sig;
val = diag(Sig);
valSum = sum(diag(Sig));
for idx = 1:1:length(val)
    valSumidx = sum(val(1:idx,1));
    valPrc(idx) = valSumidx/valSum*100;
end

figure
set(gcf, 'units','normalized','outerposition',[0.1 0 0.4 1]);
subplot(2,1,1)
semilogy(1:1:length(diag(Sig)),diag(Sig),'.k','MarkerSize',17);
set(gca,'FontSize',16);
grid on
xlabel('[k]')
ylabel('Singular Value')

subplot(2,1,2)
plot([0 1:1:length(diag(Sig))],[0 valPrc],'.k','MarkerSize',17);
hold on
xline(7,'--r','LineWidth',3)
grid on
xlabel('[k]')
ylabel('Total Energy [%]')
ylim([0 100])
set(gca,'FontSize',16);
saveas(gca,'plotSingVal.png');
end

