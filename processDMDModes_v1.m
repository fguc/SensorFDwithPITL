function [MatPhi,MatLabels] = processDMDModes_v1(sim,numRef,order)

MatPhi = [];
MatLabels = {};


for i = numRef:numRef
    for j = 1:size(sim,2)
        simData = sim{i,j};
        eigs = diag(simData.resultsDMDc.eigs);
        SelPhi = [];
        for r = 1:2:3
            SelPhi = [SelPhi;real(simData.resultsDMDc.Phi(:,r))];
%             if abs(imag(eigs(r))-0.014)<= 0.01 && abs(real(eigs(r))-0.48) <= 0.01
%                 SelPhi = [SelPhi;real(simData.resultsDMDc.Phi(:,r))];
% %                 simData.simDef
% %                 eigs(r)
%             end
        end
        MatPhi = [MatPhi SelPhi];
        MatLabels = [MatLabels simData.simDef];
    end    
end

MatPhi = MatPhi';
MatLabels = MatLabels';