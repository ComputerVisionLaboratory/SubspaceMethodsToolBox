function Y = cvlNormalize(X, varargin)
% Function to normalize set of vectors
% Parameters:
%   X: a column vector or a set of column vectors in d x N matrix where
%      d is the number of variables and N is the number of the column vectors
%   varargin: if not specified, normalization is based on L2 norm,
%             otherwise, it is based on varargin. But varargin must be
%             a non zero real number
% Return value:
%  Y: a normalized column vector or a set of column vector with the same
%     size as X
%
% Ver 1.00, Last modified 2014/3/18
% Computer vison laboratory, University of Tsukuba
% http://www.cvlab.cs.tsukuba.ac.jp/

X=double(X);
Y = [];
if nargin == 1
    D = 2;    
    A = sum(abs(X).^D).^(1/D);
    [~, I] = find(A==0);
    A(I) = 1;
    Y = X./repmat(A,size(X,1),1);
elseif nargin == 2
    D = varargin{1};
    if (D~=0)
        A = sum(abs(X).^D).^(1/D);
        [~, I] = find(A==0);
        A(I) = 1;
        Y = X./repmat(A,size(X,1),1);
    end
end
end
