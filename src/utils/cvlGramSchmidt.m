function eigen_v = cvlGramSchmidt(data, n)
% Function to apply orthogonalization based on Gram Schmidt
% Parameters:
%   data: set of column vectors
%   n: optional
%      if specified: n is the number of the orthogonal vectors to obtain
% Return values:
%   eigen_v: an orthogonal matrix
%
% Ver 1.00, Last modified 2014/3/20
% Computer vison laboratory, University of Tsukuba
% http://www.cvlab.cs.tsukuba.ac.jp/

if(nargin < 2)
    eigen_v = orth(data);
else
    dim = size(data,1);
    eigen_v = zeros(dim, n);
    eigen_v(:,1) = data(:,1) ./ norm(data(:,1));
    for I=2:n;
        v = data(:,I);
        for J=1:I-1;
            v = v - (eigen_v(:,J)'*data(:,I))*eigen_v(:,J);
        end;
        eigen_v(:,I) = v ./ norm(v);
    end;
end

