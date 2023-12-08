function [C ]= cvlKernelCanonicalAngles(X1, A1, X2, A2, nSigma,varargin)
% Function to compute canonical angles for nonlinear subspaces
% This function only computes the average of cos^2 canonical angles. 
% Currently this function does not support the calculation of cos^2 of the
% first canonical angle.
% By default, this function return C in the form of multidimensional array
% Parameters:
%   X1, X2: n-multidimensional array matrix containing the set of original
%           data, where n is only limited to either 2 or 3.
%           1st-order: dimension of the vector data
%           2nd-order: the number of samples
%           3rd-order: subset of samples (i.e. sub category)
%              or
%           in the form of cell {1,subset-of-samples}
%           Both X1 and X2 must have the same type (either cell or 
%           multidimensional array matrix)
%   A1, A2: set of eigenvectors obtained from kernel PCA, correspond to X1
%           and X2.
%           A1 and A2 can be in the form of multidimensional array matrix
%             or 
%           in the form of cell.
%           Both A1 and A2 must have the same type (either cell or multi
%           dimensional array matrix)
%  varargin: optional. 
%           varargin is only affected if A1 and A2 in the form of cell
%           varargin == 'C':
%              will return C in the form of cell with all similarity values
%              using varied subspace dimension.
%           
% Return values:
%   C:   Similarity matrix:
%        if A1 and A2 are in the form of multi dimensional array matrix:
%            contains multi dimensional array similarity matrix, with varied
%            subspace dimension. The similarity is based on the average of 
%            cosine^2 canonical angles. C has size of 
%                 (set-of-eigenvectors-A1 x set-of-eigenvectors-A2 x 
%                        number-of-eigVec-A1 x number-of-eigVec-A2)
%        if A1 and A2 are in the form of cell,
%            if varargin == 'C':
%                C is in the form of cell 
%                 {set-of-eigenvectors-A1 x set-of-eigenvectors-A2} 
%                 containing similarity matrix with varied subspace dimension
%            otherwise:
%                C is in the form of 2D matrix:
%                 (set-of-eigenvectors-A1 x set-of-eigenvectors-A2)
%                 containing similarity value of fixed subspace dimension
%
% Ver 1.00, Last modified 2014/3/19
% Computer vison laboratory, University of Tsukuba
% http://www.cvlab.cs.tsukuba.ac.jp/


flgC = false;
if nargin == 6    
    if ((varargin{1} == 'C') && iscell(A1) && iscell(A2))
        flgC = true;
    end
end

if (iscell(A1) && iscell(A2))
	nSet1 = numel(A1);
    nSet2 = numel(A2);
    if (flgC == true)
        C = cell(nSet1,nSet2);
    else
        C = zeros(nSet1,nSet2);
    end
    for i=1:nSet1
        for j=1:nSet2
            if (iscell(X1) && iscell(X2))
                tmp = cvlKernelCanonicalAngles(X1{i}, A1{i}, X2{j}, A2{j}, nSigma);   
            else
                tmp = cvlKernelCanonicalAngles(X1(:,:,i), A1{i}, X2(:,:,j), A2{j}, nSigma);
            end
            if (flgC == true)
                C{i,j} = squeeze(tmp);
            else
                C(i,j) = tmp(end);
            end
        end
    end
else
    if (iscell(X1) && iscell(X2))
        nSet1 = numel(X);
        nSet2 = numel(X2);
        C = zeros(nSet1,nSet2);
        for i=1:nSet1
            for j=1:nSet2
                tmp = cvlKernelCanonicalAngles(X1{i}, A1(:,:,i), X2{j}, A2(:,:,j), nSigma);
                C(i,j) = tmp(end);
            end
        end
    else
        X1 = X1(:,:,:);
        A1 = A1(:,:,:);
        X2 = X2(:,:,:);
        A2 = A2(:,:,:);
        [~,nSubDim1,nSet1] = size(A1);
        [~,nSubDim2,nSet2] = size(A2);
        B = zeros(nSet1,nSet2,nSubDim1,nSubDim2);
        for I=1:nSet1
            for J=1:nSet2          
                K = exp(-cvlL2Distance(X1(:,:,I),X2(:,:,J))/nSigma);                    
                B(I,J,:,:) = (A1(:,:,I)'*K*A2(:,:,J)).^2;
            end
        end
        C =(cumsum(cumsum(B,3),4));
        for S1 = 1:nSubDim1
            for S2 = 1:nSubDim2
                C(:,:,S1,S2) = C(:,:,S1,S2)/min([S1,S2]);
            end
        end
    end        
end
    

