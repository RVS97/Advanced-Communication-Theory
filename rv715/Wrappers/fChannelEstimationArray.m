% NAME, GROUP (EE4/MSc), 2010, Imperial College.
% DATE

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Performs channel estimation for the desired source using the received signal
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Inputs
% symbolsIn (Fx1 Complex) = R channel symbol chips received
% goldseq (Wx1 Integers) = W bits of 1's and 0's representing the gold
% sequence of the desired source used in the modulation process
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Outputs
% delay_estimate = Vector of estimates of the delays of each path of the
% desired signal
% DOA_estimate = Estimates of the azimuth and elevation of each path of the
% desired signal
% beta_estimate = Estimates of the fading coefficients of each path of the
% desired signal
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [delay_estimate, DOA_estimate, beta_estimate]=fChannelEstimationArray(symbolsIn,goldseq)

    % AIC for number of signals
    L = size(symbolsIn,2);
    Rxx = cov(symbolsIn');
    [Vecs,Vals] = eig(Rxx); 
    [eVals, eIdx] = sort(diag(Vals),'descend');
    M = AIC(eVals,L); % number of multipaths
    
    % Music Algorithm
    sortedVecs = Vecs(:,eIdx);
    En = sortedVecs(:,M+1:end);
    En= fliplr(En);
    
    % Set Array structure
    array = zeros(5,3);
    for i = 0:4
        array(i+1,:) = [sqrt(2)*cos(deg2rad(30+(i*72))),sqrt(2)*sin(deg2rad(30+(i*72))),0];
    end
    % Loop over all possible azimuths
    for azimuth = 0:180
        S = spv(array,[azimuth 0]);
        zNorm2(azimuth+1) = S'*(En*En')*S;
    end
    
    % Find local minima = pred azimuths
    localMin = find(localMinima(zNorm2));
    [~, predIdx] = mink(zNorm2(localMin),M);
    predAzimuth = localMin(predIdx)-1;
    
    %Calculate manifold for each pred azimuth and calc weights
    for i=1:M
        S(:,i) = spv(array,[predAzimuth(i) 0]);
        w(:,i) = Rxx\S(:,i);
    end
    
    y = w'*symbolsIn;
    
    goldseq = 1-2*goldseq;
    goldseqL = repmat(goldseq, 1, floor(length(symbolsIn)/length(goldseq))); % extend goldseq
    
    for i=1:size(y,1)
        DOAcorr(:,i) = xcorr(y(i,:),goldseqL,length(goldseq));
        DOAcorr(:,i) = DOAcorr(:,i) - mean(DOAcorr(:,i)); % to get relative difference
        [maxVals(i,:), maxInd] = maxk(abs(DOAcorr(length(goldseq)+1:end-1,i)), M);
    end
    [~,azimuthIdx] = max(maxVals(:,1)); 
    azimuthEst = predAzimuth(azimuthIdx);
    
    symbolsOut = w(:,azimuthIdx)'*symbolsIn;
    
    corr = xcorr(symbolsOut, goldseqL, length(goldseq));
    [maxVals, maxInd] = maxk(abs(corr(length(goldseq)+1:end-1)), M);
    delay_estimate = mod(maxInd-1, length(goldseq));
    DOA_estimate = [azimuthEst 0];
    beta_estimate = symbolsOut; % cheat to avoid recalculation outside function

end