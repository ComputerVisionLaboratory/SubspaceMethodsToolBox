function [eigVec, eigVal, eigRat] = cvlBasisVector(X,nSubDim,varargin)
% Function to generate basis vector
% Parameters:
%   X: sample data in n-multidimensional array matrix where n is limited 
%      to either 2,3,4. The order of the multidimensional matrix array is:
%       1st-order: the dimension of feature vector
%       2nd-order: the number of samples
%       3rd-order: subset of samples (i.e. sub category)
%       4th-order: bigger set of samples (i.e. superset category)
%   nSubDim: dimension of subspace (number of basis vectors)
%            if nSubDim < 1, it is based on cumulative ratio of eigenvalues
%   varargin: if nSubDim < 1, this value is ignored. Return values are in 
%             the form of cell
%             if nSubDim >= 1, varargin specifies the type of return values:
%             ->if varargin == 'C' return values are in the form of cell
%             ->if varargin is not specified, return values are in the form
%               of matrix
% Return values:
%   eigVec: cell type with size of {1,3rd-order} or {3rd-order,4th-order} 
%           containing basis vector, or in the form of multidimensional 
%           array matrix with size of 
%              (1st-order x nSubDim x 3rd-order x ...)
%   eigVal: cell type with the same size with eigVec: containing the list of 
%           the eigenvalue, or in the form of multidimensional array matrix
%   eigRat: cell type with the same size with eigVec: containing the energy 
%           ratio or in the form of array matrix
% 
% Ver 1.00, Last modified 2014/3/18
% Computer vison laboratory, University of Tsukuba
% http://www.cvlab.cs.tsukuba.ac.jp/

flgM = true;
if (nSubDim < 1)
    flgM = false;
end
if nargin == 3    
    if ((varargin{1} == 'C'))
        flgM = false;
    end
end

nSizeX = size(X);

if (flgM == true) % return values in the form of matrix
    nSubNum = prod(nSizeX)/prod(nSizeX(1:2));
    X = reshape(X,size(X,1),size(X,2),nSubNum);
    eigVec = zeros(size(X,1),nSubDim,nSubNum);
    eigVal = zeros(nSubDim,nSubNum);
    eigRat = zeros(1,nSubNum);
    for I=1:nSubNum
        [~,eigVec(:,:,I),eigVal(:,I),eigRat(I)] = cvlPCA(X(:,:,I),nSubDim,'R');    
    end
    eigVec = reshape(eigVec,[nSizeX(1),nSubDim,nSizeX(3:end),1]);    
    eigVal = reshape(eigVal,[nSubDim,nSizeX(3:end),1]);
    if (numel(nSizeX) >=3)
        eigRat = reshape(eigRat,[nSizeX(3:end),1]);
    end
else % return values in the form of cell
    switch(numel(nSizeX)) % check the number of set 
    case 2 % single set
        eigVec = cell(1,1);
        eigVal = cell(1,1);
        eigRat = cell(1,1);
        [~,eigVec{1},eigVal{1},eigRat{1}] = cvlPCA(X(:,:),nSubDim,'R');    
    case 3 % one-level set
        eigVec = cell(1,nSizeX(3));
        eigVal = cell(1,nSizeX(3));
        eigRat = cell(1,nSizeX(3));
        for i=1:nSizeX(3)
            [~,eigVec{i},eigVal{i},eigRat{i}] = cvlPCA(X(:,:,i),nSubDim,'R');    
        end
    case 4 % two-level set
        eigVec = cell(nSizeX(3),nSizeX(4));
        eigVal = cell(nSizeX(3),nSizeX(4));
        eigRat = cell(nSizeX(3),nSizeX(4));
        for i=1:nSizeX(3)
            for j=1:nSizeX(4)
                [~,eigVec{i,j},eigVal{i,j},eigRat{i,j}] = cvlPCA(X(:,:,i,j),nSubDim,'R');    
            end
        end
    end
end
