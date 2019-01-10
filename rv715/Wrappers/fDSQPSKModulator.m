% NAME, GROUP (EE4/MSc), 2010, Imperial College.
% DATE

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Perform DS-QPSK Modulation on a vector of bits using a gold sequence
% with channel symbols set by a phase phi
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Inputs
% bitsIn (Px1 Integers) = P bits of 1's and 0's to be modulated
% goldseq (Wx1 Integers) = W bits of 1's and 0's representing the gold
% sequence to be used in the modulation process
% phi (Integer) = Angle index in degrees of the QPSK constellation points
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Outputs
% symbolsOut (Rx1 Complex) = R channel symbol chips after DS-QPSK Modulation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [symbolsOut]=fDSQPSKModulator(bitsIn,goldseq,phi)

T = [];
Nc = size(goldseq, 2);

for i=1:length(bitsIn)/2
    a = bitsIn(2*i-1);
    b = bitsIn(2*i);
    if a==0
        if b==0
            T(i) = sqrt(2)*exp(j*deg2rad(phi)); % 00
        else
            T(i) = sqrt(2)*exp(j*deg2rad(phi+90)); % 01
        end
    else
        if b==0
            T(i) = sqrt(2)*exp(j*deg2rad(phi-90)); % 10
        else
            T(i) = sqrt(2)*exp(j*deg2rad(phi-180)); % 11
        end
    end
end

for k=0:size(T,2)-1
    Tss((Nc*k) + 1:Nc*(k+1))=T(k+1); %extend signal
end

goldSeqRep = repmat(goldseq, 1, size(T,2)); %extend goldseq
goldSeqRep = -2*goldSeqRep + 1;

symbolsOut = Tss.*goldSeqRep;


end