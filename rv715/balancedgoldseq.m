function balanced = balancedgoldseq(goldseq)
% for a balanced gold sequence need # of -1s = # of 1s + 1

    i = 0;                       % count 0s 
    j = 0;                       % count 1s 
    for n=1:size(goldseq,2)      
        if(goldseq(n)==0)
            i = i+1;
        else
            j = j+1;
        end
    end
    if(j==i+1)            
        balanced=1;
    else
        balanced=0;
    end
    
end