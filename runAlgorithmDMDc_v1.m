function [resultsDMDc] = runAlgorithmDMDc_v1(simData)

rtil = simData.rtil;
r = simData.r;
dataDMD = simData.dataDMD;

%%﻿Collect and construct the snapshot matrices:
X = dataDMD.ys(:,1:end-1);
Xp = dataDMD.ys(:,2:end);
Ups = dataDMD.r(:,1:end-1);

% % center matrices
Xmean = mean(X,2);
X = X - Xmean;
Xp = Xp - Xmean;

Omega = [X;Ups];

%% Compute the SVD of Ω to obtain the decomposition Ω≈ ˜U˜Σ˜V∗ with truncation value rtil

[U,Sig,V] = svd(Omega,'econ');
Util    = U(:,1:rtil); 
Sigtil  = Sig(1:rtil,1:rtil);
Vtil    = V(:,1:rtil); 

%% ﻿Compute the SVD of Xp to obtain the decomposition Xp ≈ ˆUˆΣˆV∗ with truncation value r
[U,Sig,~] = svd(Xp,'econ');
Uhat    = U(:,1:r); 
Sighat  = Sig(1:r,1:r);
Vbar    = V(:,1:r); 

%% ﻿Compute the approximation of the operators G=[AB].
n = size(X,1); 
q = size(Ups,1);
U_1 = Util(1:n,:);
U_2 = Util(n+q:n+q,:);

approxA = Uhat'*(Xp)*Vtil*inv(Sigtil)*U_1'*Uhat;
approxB = Uhat'*(Xp)*Vtil*inv(Sigtil)*U_2';

%% ﻿Perform the eigenvalue decomposition of A˜
[W,resultsDMDc.eigs] = eig(approxA);

%% ﻿Compute the dynamic modes of the operator A.
resultsDMDc.Phi = Xp * Vtil * inv(Sigtil) * U_1'*Uhat * W;

%% Compute amplitude matrix b
alpha1 = Sigtil*Vtil(1,:)'; 
b =(W*resultsDMDc.eigs)\alpha1;
resultsDMDc.b = diag(b);
resultsDMDc.Sig = Sig;

end

