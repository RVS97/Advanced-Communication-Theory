function [B, I] = mink(A,k)
    [val, idx] = sort(A, 'ascend');
    B = val(1:k);
    I = idx(1:k);
end