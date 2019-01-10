% NAME, GROUP (EE4/MSc), 2010, Imperial College.
% DATE

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Reads an image file with AxB pixels and produces a column vector of bits
% of length Q=AxBx3x8 where 3 represents the R, G and B matrices used to
% represent the image and 8 represents an 8 bit integer. If P>Q then
% the vector is padded at the bottom with zeros.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Inputs
% filename (String) = The file name of the image
% P (Integer) = Number of bits to produce at the output - Should be greater
% than or equal to Q=AxBx3x8
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Outputs
% bitsOut (Px1 Integers) = P bits (1's and 0's) representing the image
% x (Integer) = Number of pixels in image in x dimension
% y (Integer) = Number of pixels in image in y dimension
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [bitsOut,x,y]=fImageSource(filename,P)

[X,map] = imread(filename);
if ~isempty(map)
    Im = ind2rgb(X,map);
end

x = size(X,2);
y = size(X,1);
Q = x*y*3*8;
msg = reshape(X,[x*y,3]); % by colour
msg1 = reshape(msg,[x*y*3,1]); % merge colours
msg2 = de2bi(msg1,8,'right-msb'); % to bits
bitsOutQ = reshape(msg2,[Q,1]); 
bitsOut = [bitsOutQ; zeros(P-Q,1)]; %pad

end