function [M] = localMinima(A)
    % Find local minima points of array A, 1 == local minima point
    M = zeros(size(A));
    if A(1) < A(2) M(1)=1; else M(1)=0; end % 1st point condition
    for i=2:length(A)-1
       if (A(i)<A(i+1)) && (A(i)<A(i-1)) % check point less than previous and next point
           M(i) = 1;
       end
    end
    if A(end) < A(end-1) M(end)=1; else M(end)=0; end % last point condition
end