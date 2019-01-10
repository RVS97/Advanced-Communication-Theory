function [B, I] = maxk(A,k)
    [val, idx] = sort(A, 'descend');
    B = val(1:k);
    I = idx(1:k);
end