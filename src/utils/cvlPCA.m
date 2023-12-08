function [Z,eigVec,eigVal,eigRat] = cvlPCA(X,nSubDim,varargin)
% Function to compute PCA
% Parameters:
%   X: sample data in matrix with size of nDim x nNum, where nDim is the 
%      number of variables (dimension of feature data) and nNum is the 
%      number of samples
%   Y: the number of principal component to keep. If Y < 1, the number of
%      principal components kept is based on the cumulative ratio of 
%      eigenvalues
%   varargin: if not specified, PCA is computed on covariance matrix of X
%             if varargin == 'R', PCA is computed on autocorrelation 
%             matrix of X 
% Return values:
%   Z: Projected data to the Principal components
%   eigVec: Set of the principal vectors
%   eigVal: List of the eigenvalues
%   eigRat: the cumulative ratio of eigenvalues used
%
% Ver 1.00, Last modified 2014/3/18
% Computer vison laboratory, University of Tsukuba
% http://www.cvlab.cs.tsukuba.ac.jp/

X = X(:,:);
[nDim,nNum] =size(X); 

flgM = true;
if nargin == 3
    if varargin{1} == 'R'
        flgM = false;
    end
end

if nSubDim < 1 % number of principal components is based on cumulative ratio
    cRate = nSubDim;
    if nDim<nNum
        if flgM==true
            C = cov(X',1);
        else
            C = X*X'/nNum;
        end
        [eigVec,tmpD]= eig(C);
        [eigVal, ind]= sort(diag(tmpD),'descend');
        eigVec = eigVec(:,ind);
        nSubDim = find(cumsum(eigVal)/sum(eigVal)>=cRate, 1 );
        eigVec=eigVec(:,1:nSubDim);
        eigVal = eigVal(1:nSubDim);
        eigRat = sum(eigVal)/trace(C);
    else
        if flgM==true
            K = X'*X;
            IN =  ones(nNum,nNum)/nNum;
            K = K - IN*K - K*IN + IN*K*IN;
        else
            K = X'*X;
        end
        [A, B] = eig(K);
        [B, ind] = sort(diag(B),'descend');
        A=A(:,ind);
        eigVal = B/nNum;
        nSubDim = find(cumsum(eigVal)/sum(eigVal)>=cRate, 1 );
        A=A(:,1:nSubDim);
        B=B(1:nSubDim);
        A = A/sqrt(diag(B));
        eigVec = X*A;
        eigVal = eigVal(1:nSubDim);
        eigRat = sum(eigVal);        
    end
elseif nSubDim >= 1 % number of principal components is based on fixed value
    nSubDim = floor(nSubDim);
    if nDim<nNum
        if flgM==true
            C = cov(X',1);
        else
            C = X*X'/nNum;
        end
        
        OPTS.disp = 0;
        if nSubDim<nDim
           [eigVec, tmpD] = eigs(C,nSubDim,'lm',OPTS); %[U,tmpD]= eigs(C,nSubDim);
        else
           [eigVec, tmpD] = eig(C);
        end
        [eigVal, ind]= sort(diag(tmpD),'descend');
        eigVec = eigVec(:,ind);
        eigRat = sum(eigVal)/trace(C);
    else
        if flgM==true
            K = X'*X;
            IN =  ones(nNum,nNum)/nNum;
            K = K - IN*K - K*IN + IN*K*IN;
        else
            K = X'*X;
        end
        OPTS.disp = 0;        
        [A, B] = eigs(K,nSubDim,'lm',OPTS);
        [B, ind] = sort(diag(B),'descend');
        A=A(:,ind);
        eigVal = B/nNum;
        A = A/sqrt(diag(B));
        eigVec = X*A;
        eigRat = sum(eigVal);
    end
end
Z = eigVec'*X;