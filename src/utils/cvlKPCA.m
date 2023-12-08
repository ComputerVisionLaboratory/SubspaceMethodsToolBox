function [eigVec,eigVal,eigRat,kMat] = cvlKPCA(X,Y,nSigma,varargin)
% Function to compute Kernel PCA. Kernel function used is Gaussian kernel
% Parameters:
%   X: sample data in matrix with size of nDim x nNum, where nDim is the 
%      number of variables (dimension of feature data) and nNum is the 
%      number of samples
%   Y: the number of principal component to keep. If Y < 1, the number of
%      principal components kept is based on the cumulative ratio of 
%      eigenvalues
%   nSigma: Gaussian kernel bandwith parameter
%   varargin: if not specified, PCA is computed on covariance matrix of X
%             if varargin == 'R', PCA is computed on autocorrelation 
%             matrix of X 
% Return values:
%   eigVec: Set of the principal vectors
%   eigVal: List of the eigenvalues
%   eigRat: the cumulative ratio of eigenvalues used
%   kMat: kernel Gram matrix
%
% Ver 1.00, Last modified 2014/3/19
% Computer vison laboratory, University of Tsukuba
% http://www.cvlab.cs.tsukuba.ac.jp/

X = X(:,:);
[~,nNum] =size(X);

flgM = true;
if nargin == 4
    if varargin{1} == 'R'
        flgM = false;
    end
end

kMat=exp(-cvlL2Distance(X,X)/nSigma);

if flgM==true % use covariance matrix if flgM == true
    IN =  ones(nNum,nNum)/nNum;
    kMat = kMat - IN*kMat - kMat*IN + IN*kMat*IN;
end

if Y < 1 %  % number of principal components is based on cumulative ratio
    cRate = Y;
    [eigVec, B] = eig(kMat);
    [B, ind] = sort(diag(B),'descend');
    eigVec=eigVec(:,ind);
    eigVal = B/nNum;
    nSubDim = find(cumsum(eigVal)/sum(eigVal)>=cRate, 1 );
    eigVec=eigVec(:,1:nSubDim);
    B=B(1:nSubDim);
    eigVec = eigVec/sqrt(diag(B));
    %U = X*A;
    eigVal = eigVal(1:nSubDim);
    eigRat = sum(eigVal);    
elseif Y >= 1 % % number of principal components is based on fixed value
    nSubDim = floor(Y);
    OPTS.disp = 0;
    [eigVec, B] = eigs(kMat,nSubDim,'lm',OPTS);  %[A B] = eigs(K,nSubDim);
    [B, ind] = sort(diag(B),'descend');
    eigVec=eigVec(:,ind);
    eigVal = B/nNum;
    eigVec = eigVec/sqrt(diag(B));
    eigRat = sum(eigVal);
end
