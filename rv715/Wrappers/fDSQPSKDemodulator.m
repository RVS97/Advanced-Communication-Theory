% NAME, GROUP (EE4/MSc), 2010, Imperial College.
% DATE

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Perform demodulation of the received data using <INSERT TYPE OF RECEIVER>
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Inputs
% symbolsIn (Fx1 Integers) = R channel symbol chips received
% goldseq (Wx1 Integers) = W bits of 1's and 0's representing the gold
% sequence of the desired signal to be used in the demodulation process
% phi (Integer) = Angle index in degrees of the QPSK constellation points
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Outputs
% bitsOut (Px1 Integers) = P demodulated bits of 1's and 0's
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [bitsOut]=fDSQPSKDemodulator(symbolsIn,GoldSeq,phi)

%% Despreading
Nc = size(GoldSeq, 2);

goldSeqRep = repmat(GoldSeq, 1, size(symbolsIn,2)/Nc); %extend
goldSeqRep = -2*goldSeqRep + 1;

symbolsIn = symbolsIn.*goldSeqRep;

for i = 0:(size(symbolsIn,2))/Nc -1
   That(i+1) = mean(symbolsIn(Nc*i+1:Nc*(i+1)));        % Taking averages of the demodulated symbols 
end

%% Demodulation
k=1;
for m=1:length(That)
    % demodulate according to position of point
    %&shift by (58-45) in order to center points and minimise error
    point = That(m)*exp(j*deg2rad(45-phi));

    % demodulation according to quadrant in which point is
    if imag(point)>=0
        out1=0;
    else
        out1=1;
    end
    if real(point)>=0
        out2=0;
    else 
        out2=1;
    end
 
    bitsOut(k) = out1;
    bitsOut(k+1) = out2;
    k = k+2;
end 

end