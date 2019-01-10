clear;
%% Adding functions to path
addpath('.\Manikas Functions');
addpath('.\Wrappers');

%% load images and define variables

image1 = 'image1.jpg';
image2 = 'image2.jpg';
image3 = 'image3.jpg';

%polynomials of sequences, first value not included (D^5)
mesPoly1 = [1 0 0 1 1]; % D^4 + D + 1
mesPoly2 = [1 1 0 0 1]; % D^4 + D^3 + 1

X = 22; % V = 22
Y = 18; % R = 18
phi = X + 2*Y; % 58

Fs = 8e3; % Sampling frequency
Tb = 1/Fs; % Period
Tcs = 2*Tb; % Channel symbol period
Fc = 1e6; % Carrier frequency
SNR = 40;
shift1 = 1+mod(X+Y,12); % 5
% shift2 = shift1+1;
% shift3 = shift1+2;
P = 2^19;

%Channel variables
paths = [3;1;1]; % No multipaths for sources
delay = [mod(X+Y,4);mod(X+Y,5)+4;mod(X+Y,6)+9;8;13]; % Delays for mod(tau,15)
beta = [0.8;0.4*exp(1i*deg2rad(-40));0.8*exp(1i*deg2rad(80));0.5;0.2]; % Fading coefficients
DOA = [30,0;40,0;20,0;80,0;150,0]; % Direction of arrival, [azimuth,elevation]
array = [0,0,0];  %Array locations in half unit wavelength


%% Convert to bits

[bitsOut1,x1,y1] = fImageSource(image1,P);
[bitsOut2,x2,y2] = fImageSource(image2,P);
[bitsOut3,x3,y3] = fImageSource(image3,P);

Q = x1*y1*3*8;

%% Gold sequence generation

mseq1 = fMSeqGen(mesPoly1);
mseq2 = fMSeqGen(mesPoly2);

balanced = 0;
while balanced == 0
    goldseq1 = fGoldSeq(mseq1,mseq2,mod(shift1,15));
    balanced = balancedgoldseq(goldseq1);              % Check if balanced 1/0
    shift1 = shift1 + 1;
end
shift2 = shift1;
balanced = 0;
% while balanced == 0
    goldseq2 = fGoldSeq(mseq1,mseq2,mod(shift2,15));
    balanced = balancedgoldseq(goldseq2);              % Check if balanced 1/0
    shift2 = shift2 + 1;
% end
shift3 = shift2;
balanced = 0;
% while balanced == 0
    goldseq3 = fGoldSeq(mseq1,mseq2,mod(shift3,15));
    balanced = balancedgoldseq(goldseq3);              % Check if balanced 1/0
    shift3 = shift3 + 1;
% end

%% DSQPSK Modulation

[symbolsMod1] = fDSQPSKModulator(bitsOut1,goldseq1, phi);
[symbolsMod2] = fDSQPSKModulator(bitsOut2,goldseq2, phi);
[symbolsMod3] = fDSQPSKModulator(bitsOut3,goldseq3, phi);

%% Channel

symbolsConcat = [symbolsMod1;symbolsMod2;symbolsMod3];
symbolsOut = fChannel(paths,symbolsConcat,delay,beta,DOA,SNR,array);

%% Channel Estimation

[delay_estimate, ~, ~]=fChannelEstimation(symbolsOut,goldseq1);

delay_estimate = sort(delay_estimate,'ascend');

path1 = symbolsOut(delay_estimate(1) + 1:length(symbolsMod1)+delay_estimate(1));
path2 = symbolsOut(delay_estimate(2) + 1:length(symbolsMod1)+delay_estimate(2));
path3 = symbolsOut(delay_estimate(3) + 1:length(symbolsMod1)+delay_estimate(3));

resolvedPaths = conj(beta(1))*path1+conj(beta(2))*path2+conj(beta(3))*path3;

%% DSQPSK Demodulation and Image Sink

bitsdemod = fDSQPSKDemodulator(resolvedPaths,goldseq1,phi);

[NBE, BER] = biterr(bitsOut1',bitsdemod);

fImageSink(uint8(bitsdemod),Q, x1, y1);