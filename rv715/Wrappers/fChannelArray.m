% NAME, GROUP (EE4/MSc), 2010, Imperial College.
% DATE

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Models the channel effects in the system
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Inputs
% paths (Mx1 Integers) = Number of paths for each source in the system.
% For example, if 3 sources with 1, 3 and 2 paths respectively then
% paths=[1;3;2]
% symbolsIn (MxR Complex) = Signals being transmitted in the channel
% delay (Cx1 Integers) = Delay for each path in the system starting with
% source 1
% beta (Cx1 Integers) = Fading Coefficient for each path in the system
% starting with source 1
% DOA = Direction of Arrival for each source in the system in the form
% [Azimuth, Elevation]
% SNR = Signal to Noise Ratio in dB
% array = Array locations in half unit wavelength. If no array then should
% be [0,0,0]
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Outputs
% symbolsOut (FxN Complex) = F channel symbol chips received from each antenna
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [symbolsOut]=fChannelArray(paths,symbolsIn,delay,beta,DOA,SNR,array)

S = spv(array,DOA); %manifold

%Shift symbols according to paths array
n = 1;
symbolsOut = zeros(size(array,1),size(symbolsIn,2));
symbolsIn = [symbolsIn,zeros(3,max(delay))];
X = zeros(size(beta,1),size(symbolsIn,2));

for i = 1:size(paths,1)
    for j = 1:paths(i)
        X(n,:) = lagmatrix(symbolsIn(i,:), delay(n)); % delay signals
        X(isnan(X)) = 0; % get rid of NaNs
        X(n,:) = beta(n)*X(n,:); % multiply by fading coeffs
        n = n + 1;
    end
end

symbolsOut = S*X;

% Add Noise
Ps = (symbolsOut*symbolsOut')/length(symbolsOut); % signal power
Pn = Ps/db2mag(SNR); % noise power
sOutSize = size(symbolsOut);
noise = sqrt(Pn/2)*randn(sOutSize(1),sOutSize(2)) + 1i*sqrt(Pn/2)*randn(sOutSize(1),sOutSize(2)); % noise
symbolsOut = symbolsOut + noise;


end