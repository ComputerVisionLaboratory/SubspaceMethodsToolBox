function D = cvlL2Distance(A,B)
% Function to compute L2 distance matrix between two sets of vectors
% Parameter:
%   A, B: multi dimensional array matrix:
%         1st-order: the dimension of one vector
%         2nd-order: the number of vectors
%         if A or B contains more than 2nd-order dimensionality, they
%         will be merged in the output matrix D.
% Return values:
%   D: distance matrix with the size of (number-of-vectors-in-A x
%      number-of-vectors-in-B)
%
% Ver 1.00, Last modified 2014/3/19
% Computer vison laboratory, University of Tsukuba
% http://www.cvlab.cs.tsukuba.ac.jp/

if size(size(A),2) >2
    A=A(:,:);
end
if size(size(B),2) >2
    B=B(:,:);
end
nNumA = size(A,2);
nNumB = size(B,2);
D = abs(repmat(sum((A.^2),1)',1,nNumB)+repmat(sum((B.^2),1),nNumA,1)-2*A'*B);