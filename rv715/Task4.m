clear;
%% Adding functions to path
addpath('.\Manikas Functions');
addpath('.\Wrappers');

%% set variables
load 'rv715.mat';

% personal datafile variables
beta = Beta_1;
shift = phase_shift; %23
phi = phi_mod; %72
receivedSymbols = Xmatrix;

%Channel variables
halfwave = 360/5;
% arrA = sqrt(2);
arrA = 0.5/sin(deg2rad(36)); % to get distance between antenna = 1
array = zeros(5,3);
for i = 0:4
    array(i+1,:) = [arrA*cos(deg2rad(30+(i*halfwave))),arrA*sin(deg2rad(30+(i*halfwave))),0];
end

% polynomials of sequences, first value not included (D^5)
mesPoly1 = [1 0 0 1 0 1]; % D^5 + D^2 + 1
mesPoly2 = [1 0 1 1 1 1]; % D^5 + D^3 + D^2 + D + 1

%% Gold sequence generation

mseq1 = fMSeqGen(mesPoly1);
mseq2 = fMSeqGen(mesPoly2);

balanced = 0;
while balanced == 0
    goldseq = fGoldSeq(mseq2,mseq1,mod(shift,31));
    balanced = balancedgoldseq(goldseq);              % Check if balanced 1/0
end

goldseq = -2*goldseq + 1;

%% extend data and calc zeta for each extended manifold
extData = dataExtender(receivedSymbols, length(goldseq)); % extend data for spatiotemporal

% Rxx = (extData*extData')/size(extData,2);
Rxx = zeros(size(extData,1));
for i = 1:size(extData,2)
   rxx = extData(:,i)*extData(:,i)';
   Rxx = Rxx + rxx;  % get cumulative cov for each observation
end
Rxx = Rxx/i; % get expectation = average

% get projection operator of noise subspace of Rxx
P = Rxx*pinv(Rxx'*Rxx)*Rxx';
ProjN = eye(size(Rxx,1)) - P; % proj operator of noise subspace of Rxx

J = [zeros(1,2*size(goldseq,2)-1) 0; eye(2*size(goldseq,2)-1) zeros(2*size(goldseq,2)-1,1)];
paddedGoldSeq = [goldseq zeros(1,31)];
zeta = zeros(size(goldseq,2)+1, 181);
for azimuth=0:180
   S = spv(array,[azimuth 0]); %original manifold
   for delay=0:size(goldseq,2)
       h = kron(S,(J^delay)*paddedGoldSeq'); %extended manifold
       zeta(delay+1,azimuth+1) = 1/(h'*ProjN*h); %cost function
   end
end

surf(0:180,0:31,abs(zeta), 'FaceColor','interp')
title('STAR subspace cost function')
xlabel('Azimuth')
ylabel('Delay')
set(gca, 'Fontsize', 18)

%% Calculate max params of channel
zetaT = zeta.';
z = zetaT(:);
localMin = find(localMinima(-abs(z))); % find min of -ve to find local max
[~, Idxs] = maxk(abs(z(localMin)),3); % find top 3 local max
predIdxs = localMin(Idxs); % get original idxs
estimates = zeros(3,2); %[azimuth delay]
for i=1:3
   [estimates(i,1), estimates(i,2)] = ind2sub(size(zetaT),predIdxs(i)); % map to azimuth and delay
end

estimates = estimates - 1; % correct azimuth and delay (due to for loop idx)

%% Beamformer

H = zeros(size(h,1),size(estimates,1));
for i=1:size(estimates,1)
   S = spv(array,[estimates(i,1) 0]);
   H(:,i) = kron(S,(J^estimates(i,2))*paddedGoldSeq'); %form H from extended manifold
end

% weights
w = H*beta;

% data despreading
G = w'*extData; %name from slides

%% Demodulation
% Recycling code from 3rd year
That = G;

bitsOut = [];
k=1;
for m=1:length(That)
    % demodulate according to position of point
    %&shift by (72-45) in order to center points and minimise error
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

rx = (char(bin2dec(reshape(char(bitsOut+'0'), 8,[]).')))'
