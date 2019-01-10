function M = AIC(eVals, L)
    N = length(eVals);
    sum = zeros(1,N);
    mult = ones(1,N);
    descEVals = eVals;
    sum = flip(tril(ones(N))*flip(descEVals)); %sum array
    sum = sum';
    
    for i=1:N
        mult(i) = prod(descEVals(1:i)); %mult array
    end
    mult = flip(mult); %invert order
    asc = 0:N-1; % ascending array
    desc = flip(1:N); % descending array
    desc2 = flip(N+1:2*N); %descending array 2N to N+1
    
    AIC = -2*L*(log(mult)+ desc.*((log(desc)-log(sum)))) + 2*asc.*desc2; % equation from slides
    [~,Idx] = min(AIC);
    M = Idx - 1;
end