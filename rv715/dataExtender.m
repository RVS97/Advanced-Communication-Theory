function [dataExtended] = dataExtender(x, length)    
    L = size(x,2);
    N = size(x,1);
    numSymbols = floor(L/length)-1; % number of symbols sent
    dataExtended = zeros(N*2*length,numSymbols);
    x = x.';
    for i=1:numSymbols
        %snap i : i+2Nc and flatten to array
       dataExtended(:,i) = reshape(x((i-1)*length+1:(i+1)*length,:),N*2*length,1); 
    end
    
end