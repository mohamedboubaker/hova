function [c] = hamming(a,b)
%This funcion calculates the hamming distance between the binary
%representation of the two integers introduced as it's paramaters
A=de2bi(a);
B=de2bi(b);
LA=length(A);
LB=length(B);
if a > b
    B = [ B zeros(1,LA-LB)  ];
else
    if b > a
        A = [ A zeros(1,LB-LA) ] ;
    end
end

c=max(LA,LB)*pdist([A;B],'hamming');
end

