% NAME, GROUP (EE4/MSc), 2010, Imperial College.
% DATE

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Takes polynomial weights and produces an M-Sequence
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Inputs
% coeffs (Px1 Integers) = Polynomial coefficients. For example, if the
% polynomial is D^5+D^3+D^1+1 then the coeffs vector will be [1;0;1;0;1;1]
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Outputs
% MSeq (Wx1 Integers) = W bits of 1's and 0's
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [MSeq]=fMSeqGen(coeffs)

coeffs = coeffs(2:end); % Discard first coeff 
selectedcoeffs = find(coeffs); % select non-zero coeffs

bits = ones(size(coeffs));
Nc = 2^(size(bits,2)) - 1; %sequence period
temp = bits;

MSeq = [];
for i=1:Nc % concatenation of bits to [sumof(coeffs),2:end] using temp
    MSeq(i) = temp(size(bits,2));
    temp(1) = mod(sum(bits(selectedcoeffs)),2);
    temp(2:size(bits,2)) = bits(1:size(bits,2)-1);
    bits = temp;
%     MSeq(i) = temp(size(bits,2));
end
end