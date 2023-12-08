function C = cvlCanonicalAngles(X,Y,varargin)
% Function to compute the similarity between two set of subspaces:
% The similarity is defined as average of cosine^2 canonical angles (theta)
% between the set of subspaces or the cosine^2 of the first theta (depend on
% varargin). By default: average is used.
%
% Parameters:
%   X, Y: multi dimensional array of matrix containing set of subspaces
%         1st-order: dimension of original vector space
%         2nd-order: dimension of subspace X or Y
%         3rd-order: set of the subspaces (number of subspaces)
%           or
%         cell with format: {1,set of the subspace}
%         Both X and Y must have the same type (either cell or multidimension
%         array)
%   if varargin is not specified:
%         Similarities are based on average of cos^2 theta.
%         Trace of the matrix is used to speed up computation. This does 
%         not affect the results because we consider the similarity as
%         the average (sum of eigenvalues is equal to the trace)
%   if varargin == 'F':
%         Use SVD to obtain all the canonical angles, and will output
%         both the average and the cosine^2 of the first theta.
%
% Return values
%   C : If varargin is not specified:
%        C contains multi dimensional array similarity matrix, with varied
%        subspace dimension from 1 to 3rd-order. The similarity is based
%        on the average of cosine^2 canonical angles.
%        It has size of (set-of-subspace-X x set-of-subspace-Y x 2nd-order-of-X x
%                        2nd-order-of-Y)
%              or
%       if X and Y are in the form of cell, it only has size of 
%        (set-of-subspace-X x set-of-subspace-Y), where the similarity is
%        based on fixed subspace dimension X and Y
%       
%       If varargin == 'F':
%        C contains multi dimensional array similarity matrix with fixed
%        subspace dimension, and a number of cosine^2 canical angles, 
%        ranging from the first canonical angle, average of the first and 
%        second, up to the subspace dimension of X or Y (either of which with
%        lowest subspace dimension)
%             or
%        if X and Y are in the form of cell, it only has size of
%        (set-of-subspace-X x set-of-subspace-Y x 2). 2 here:
%           the first contains the first canonical angle
%           the second contains the average
%
% Ver 1.00, Last modified 2014/3/19
% Computer vison laboratory, University of Tsukuba
% http://www.cvlab.cs.tsukuba.ac.jp/

flgFull = false;
if nargin == 3
    if varargin{1} == 'F'
        flgFull = true;
    end
end

if (iscell(X) && iscell(Y))
    nSet1 = numel(X);
    nSet2 = numel(Y);
    switch(flgFull) 
        case false % average only
            C = zeros(nSet1,nSet2);
            for s1 = 1:nSet1
                for s2 = 1:nSet2
                    tmp=squeeze(cvlCanonicalAngles(X{s1},Y{s2}));
                    C(s1,s2) = tmp(end);
                end
            end
        case true % first canonical angle and the average
            C = zeros(nSet1,nSet2,2);
            for s1 = 1:nSet1
                for s2 = 1:nSet2
                    tmp=squeeze(cvlCanonicalAngles(X{s1},Y{s2},'F'))';
                    C(s1,s2,1) = tmp(1);
                    C(s1,s2,2) = tmp(end);
                end
            end
    end    
else
    X = X(:,:,:);
    Y = Y(:,:,:);    
    [~, nSubDim1,nSet1]  = size(X);
    [~, nSubDim2,nSet2]  = size(Y);
    switch(flgFull)
        case false % use trace of matrix to compute average
            B = reshape((X(:,:)'*Y(:,:)).^2,nSubDim1,nSet1,nSubDim2,nSet2);
            C = cumsum(cumsum(B,1),3);
             for S1 = 1:nSubDim1
                for S2 = 1:nSubDim2
                    C(S1,:,S2,:) = C(S1,:,S2,:)/min([S1,S2]);
                end
             end
            C = permute(C,[2,4,1,3]);
        case true % use SVD to compute the first and average
            B = reshape((X(:,:)'*Y(:,:)),nSubDim1,nSet1,nSubDim2,nSet2);
            B = permute(B,[1,3,2,4]);
            nSubDim = min([nSubDim1,nSubDim2]);
            C = zeros(nSet1,nSet2,nSubDim);
            for I1=1:nSet1
                for I2=1:nSet2
                    C(I1,I2,:) = cumsum(svd(B(:,:,I1,I2)).^2,1);
                end
            end
            for I=1:nSubDim
                C(:,:,I) = C(:,:,I)/I;
            end            
    end
end
