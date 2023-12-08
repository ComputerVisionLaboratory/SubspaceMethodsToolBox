classdef cvlKOMSM
% Class for applying kernel orthogonal MSM (KOMSM)
% Gaussian kernel is used
%
% List of function:
%   cvlKOMSM: initialization
%   TransformS: generate subspaces projected to generalized difference
%       subspace
%   TransformV:
%
%   TransformU:
%
%   Transform: transform data by projecting them to orthogonal generalized
%       subspace
%   For the detail parameters and return values of each function, please
%       read the comments in the beginning of each function
%
% Ver 1.00, Last modified 2014/3/20
% Computer vison laboratory, University of Tsukuba
% http://www.cvlab.cs.tsukuba.ac.jp/
    properties (SetAccess = public)
        nSampleNum;   % number of samples for each data set, in the form of cell
        nClass;  % number of set (class)
        nSubDim1; % dimension of each dictionary subspace, in the form of row vector
        nEnergy; % only used to store cumulative energy ratio if used
        nOrthDim; % dimension of orthogonal generalized subspace
        nSigma;  % Gaussian kernel bandwidth parameter
        
        X1;     % sample data, in the form of cell
        eigVec; % eigenvectors obtained from KPCA, in the form of cell
        eigVal; % eigenvalues obtained from KPCA, in the form of cell
        eigRat; % cumulative ratio of the eigenvalues, in the form of cell
        
        kMat;    % kernel Gram matrix for orthogonalization
        O;       % orthogonal basis of generalized subspace
        W;       % eigenvalues of kMat

        nAlpha;  % smallest value of eigenvalues to keep for whitening transform matrix, default set to 1
        nBeta;   % a value to avoid division by zero, by default it is just set to zero        
    end% properties
    
    methods
        function OB = cvlKOMSM(X1, nSubDim1,nSigma, varargin)
        % Initialization: generate kernel orthogonal projection matrix
        % Parameters:
        %   X1: sample data in the form of multidimensional array matrix
        %       it has to be in the following format:
        %       1st-order: dimensionality of the feature vector
        %       2nd-order: the number of sample
        %       3rd-order: the number of set (or class)
        %       or 
        %       in the form of cell {1,the-number-of-set} with 2D
        %       matrix: containing set of column vectors. Use cell
        %       format if each set has different number of data
        % 
        %   nSubDim1: parameter to set the subspace dimension
        %             if nSubDim1 < 1, subspace dimension is based on
        %             the cumulative ratio of eigenvalues
        %             if nSubDim1 > 1, nSubDim1 is directly used as the 
        %             subspace dimension
        %  nSigma: parameter for Gaussian kernel bandwidth
        %  varargin: two optional tuning parameters:
        %   varargin{1}: to set the smallest value of eigenvalues to keep for
        %                constructing whitening transform matrix, by default = 1
        %   varargin{2}: small value to avoid division by zero, by default = 0
            if nargin == 3
                OB.nAlpha = 1;
                OB.nBeta  = 0;
            elseif nargin == 4
                OB.nAlpha = varargin{1};
                OB.nBeta  = 0;                
            elseif nargin == 5
                OB.nAlpha = varargin{1};
                OB.nBeta  = varargin{2};                
            end
            
            OB.nSigma = nSigma;
            if (iscell(X1))
                OB.X1 = X1;
                OB.nClass = numel(OB.X1);
                OB.nSampleNum = cell(1,OB.nClass);
                for i=1:OB.nClass
                    OB.nSampleNum{i} = size(OB.X1{i},2);
                end
            else % convert into cell
                OB.nClass = size(X1,3);
                OB.X1 = cell(1,OB.nClass);
                OB.nSampleNum = cell(1,OB.nClass);
                for i=1:OB.nClass
                    OB.X1{i} = X1(:,:,i);
                    OB.nSampleNum{i} = size(OB.X1{i},2);
                end                
            end
            
            if (nSubDim1 < 1)
                OB.nEnergy = nSubDim1;
                OB.nSubDim1 = zeros(1,OB.nClass);
            else                
                OB.nEnergy = 1;
                OB.nSubDim1 = repmat(nSubDim1,1,OB.nClass);  
            end

            OB.eigVec = cell(1,OB.nClass);
            OB.eigVal = cell(1,OB.nClass);
            OB.eigRat = cell(1,OB.nClass);            
            if OB.nEnergy < 1
                for I=1:OB.nClass
                    [OB.eigVec{I}, OB.eigVal{I}, OB.eigRat{I}] = ...
                        cvlKPCA(OB.X1{I},OB.nEnergy,OB.nSigma,'R'); 
                    OB.nSubDim1(I) = size(OB.eigVec{I},2);
                end
            else
                for I=1:OB.nClass
                    [OB.eigVec{I}, OB.eigVal{I}, OB.eigRat{I}] = ...
                        cvlKPCA(OB.X1{I},OB.nSubDim1(I),OB.nSigma,'R');
                end
            end
          
            % build kernel Gram matrix for orthogonalization
            OBDn = cell(OB.nClass,OB.nClass);
            for I1 = 1:OB.nClass
                for I2 = I1:OB.nClass
                    K = exp(-cvlL2Distance(OB.X1{I1},OB.X1{I2})/nSigma);
                    if I1 == I2
                        OBDn{I1,I2} = eye(OB.nSubDim1(I1),OB.nSubDim1(I1));
                    else
                        OBDn{I1,I2} = OB.eigVec{I1}'*K* OB.eigVec{I2};
                        OBDn{I2,I1} = OBDn{I1,I2}';
                    end
                end
            end
            OB.kMat = zeros(sum(OB.nSubDim1),sum(OB.nSubDim1));
            for I2=1:OB.nClass
                for I1=1:OB.nClass
                    for lp = 1:OB.nSubDim1(I2);
                        fr1 = sum(OB.nSubDim1(1:I1-1)) + 1;
                        to1 = sum(OB.nSubDim1(1:I1));
                        idx2 = sum(OB.nSubDim1(1:I2-1)) + lp;
                        OB.kMat(fr1:to1,idx2) = OBDn{I1,I2}(:,lp);
                    end
                end
            end
            
            [B, OB.W] = eig(OB.kMat);          
            OB.W = diag(OB.W/trace(OB.W));
            [OB.W, ind] = sort(OB.W,'descend');
            B=B(:,ind);
            OB.nOrthDim = find(cumsum(OB.W)/sum(OB.W)>=OB.nAlpha, 1 );
            B=B(:,1:OB.nOrthDim);
            OB.W = OB.W(1:OB.nOrthDim);                    
            OB.O = diag(1./(OB.W+OB.nBeta))*B';
        end
        
        function [basisVect, eigVal2, eigRat2, eigVec2] = TransformS(OB, X2,nSubDim2)
        % Function to generate subspaces which are projected to the 
        % orthogonal subspace: apply KPCA, then project to
        % orthogonal subspace, finally apply orthogonalization 
        % using Gram Schmidt 
        % Parameters:
        %   X2: input data in the form of cell or multidimensional
        %       matrix (similar format as initialization)
        %   nSubDim2: if nSubDim2 > 1, it specifies dimension of the
        %       subspace, otherwise it defines the cumulative ratio of
        %       the eigenvalues to decide the subspace dimension.
        % Return values:
        %   basisVect: set of basis vectors obtained. The output
        %       will always be in the form of cell if there are more than
        %       one set of data in X2
        %   eigVal2, eigRat2, eigVec2: eigenvalues, cumulative ratio,
        %       and eigenvectors obtained from kernel PCA in the form of
        %       cell if there are more than one set of data in X2
            if (iscell(X2))
                nSet2 = numel(X2);
                eigVec2 = cell(1,nSet2);
                eigVal2 = cell(1,nSet2);
                eigRat2 = cell(1,nSet2);
                basisVect = cell(1,nSet2);
                for i=1:nSet2
                    [basisVect{i}, eigVal2{i}, eigRat2{i}, eigVec2{i}] = ...
                        OB.TransformS(X2{i},nSubDim2, nSubDim3);
                end
            else
                X2=X2(:,:,:);
                [~, nNum2,nSet2] = size(X2);
                eigVec2 = cell(1,nSet2);
                eigVal2 = cell(1,nSet2);
                eigRat2 = cell(1,nSet2);
                for i=1:nSet2
                    [eigVec2{i}, eigVal2{i}, eigRat2{i}] = ...
                        cvlKPCA(X2(:,:,i),nSubDim2,OB.nSigma,'R');
                end                
                basisVect = cell(1,nSet2);
                for i = 1:nSet2
                    a = cell(1,OB.nClass);
                    for j = 1:OB.nClass
                        Z = exp(-cvlL2Distance(OB.X1{j},X2(:,:,i))/OB.nSigma);
                        a{j} = OB.eigVec{j}' * Z;
                    end
                    aFinal = zeros(sum(OB.nSubDim1),nNum2);
                    for rr=1:nNum2
                        for j=1:OB.nClass
                            f1 = 1+ sum(OB.nSubDim1(1:j-1));
                            t1 = sum(OB.nSubDim1(1:j));
                            aFinal(f1:t1,rr) = a{j}(:,rr);
                        end
                    end
                    basisVect{i} = cvlGramSchmidt(OB.O*aFinal*eigVec2{i});
                end
                if (nSet2==1)
                    basisVect = basisVect{1};
                    eigVec2 = eigVec2{1};
                    eigVal2 = eigVal2{1};
                    eigRat2 = eigRat2{1};
                end
            end
        end
        
        
        function [eigVec2, eigVal2, eigRat2, transformedData] = TransformV(OB, X2, nSubDim2)
        % Function to transform the data using the kernel orthogonal subspace, then
        % linear PCA is applied to the projected data
        % Parameters:
        %   X2: data in the form of multidimensional array matrix or cell
        %   nSubDim2: the dimension for PCA, or the cumulative ratio of the
        %       eigenvalues when applying PCA
        % Return values:
        %   eigVal2, eigRat2, eigVec2: eigenvalues, cumulative ratio,
        %       and eigenvectors obtained from PCA, in the form of cell if
        %       there are more than one set of data in X2
        %   transformedData: transformed data is in the formed of cell if 
        %       there are more than one set of data in X2
            if (iscell(X2))
                nSet2 = numel(X2);
                transformedData = cell(1,nSet2);
                for i=1:nSet2
                    transformedData{i} = OB.TransformV(X2{i});
                end
            else
                X2=X2(:,:,:);
                [~, nNum2,nSet2] = size(X2);
                transformedData = cell(1,nSet2);
                for J=1:nSet2
                    a = cell(1,OB.nClass);
                    for I = 1:OB.nClass
                        Z = exp(-orzL2Distance(OB.X1{I},X2(:,:,J))/OB.nSigma);
                        a{I} = OB.eigVec{I}' * Z;
                    end
                    aFinal=zeros(sum(OB.nSubDim1),nNum2);
                    for rr=1:nNum2
                        for I=1:OB.nClass
                            f1 = 1+ sum(OB.nSubDim1(1:I-1));
                            t1 = sum(OB.nSubDim1(1:I));
                            aFinal(f1:t1,rr) = a{I}(:,rr);
                        end
                    end
                    transformedData{J} = OB.O*aFinal;
                end
                eigVec2 = cell(1,nSet2);
                eigVal2 = cell(1,nSet2);
                eigRat2 = cell(1,nSet2);
                for J=1:nSet2
                    [~, eigVec2{J}, eigVal2{J}, eigRat2{J}] = cvlPCA(transformedData{J},nSubDim2,'R');
                end
                if (nSet2==1)
                    transformedData = transformedData{1};
                    eigVec2 = eigVec2{1};
                    eigVal2 = eigVal2{1};
                    eigRat2 = eigRat2{1};
                end
            end
            
            
        end
                
        function [eigVec2, eigVal2, eigRat2, transformedData] = TransformU(OB, X2, nSubDim2)
        % Function to transform the data using the kernel orthogonal subspace, 
        % then the projected data is L2 norm normalized, finally PCA is 
        % applied to the projected data
        % Parameters:
        %   X2: data in the form of multidimensional array matrix or cell
        %   nSubDim2: the dimension for PCA, or the cumulative ratio of the
        %       eigenvalues when applying PCA
        % Return values:
        %   eigVal2, eigRat2, eigVec2: eigenvalues, cumulative ratio,
        %       and eigenvectors obtained from PCA, in the form of cell if
        %       there are more than one set of data in X2
        %   transformedData: transformed data is in the formed of cell if 
        %       there are more than one set of data in X2
            if (iscell(X2))
                nSet2 = numel(X2);
                transformedData = cell(1,nSet2);
                for i=1:nSet2
                    transformedData{i} = OB.TransformV(X2{i});
                end
            else
                X2=X2(:,:,:);
                [~, nNum2,nSet2] = size(X2);
                transformedData = cell(1,nSet2);
                for J=1:nSet2
                    a = cell(1,OB.nClass);
                    for I = 1:OB.nClass
                        Z = exp(-orzL2Distance(OB.X1{I},X2(:,:,J))/OB.nSigma);
                        a{I} = OB.eigVec{I}' * Z;
                    end
                    aFinal=zeros(sum(OB.nSubDim1),nNum2);
                    for rr=1:nNum2
                        for I=1:OB.nClass
                            f1 = 1+ sum(OB.nSubDim1(1:I-1));
                            t1 = sum(OB.nSubDim1(1:I));
                            aFinal(f1:t1,rr) = a{I}(:,rr);
                        end
                    end
                    transformedData{J} = cvlNormalize(OB.O*aFinal); 
                end
                eigVec2 = cell(1,nSet2);
                eigVal2 = cell(1,nSet2);
                eigRat2 = cell(1,nSet2);
                
                for J=1:nSet2
                    [~, eigVec2{J}, eigVal2{J}, eigRat2{J}] = cvlPCA(transformedData{J},nSubDim2,'R');
                end
                if (nSet2==1)
                    transformedData = transformedData{1};
                    eigVec2 = eigVec2{1};
                    eigVal2 = eigVal2{1};
                    eigRat2 = eigRat2{1};
                end
            end
            
        end
  
        function [transformedData] = Transform(OB, X2)
        % Function to project the data X2 to the orthogonal subspace
        % Parameters:
        %   X2: input data in the form of cell or multidimensional
        %       matrix (similar format as initialization)
        % Return values:
        %   transformedData: always in the form of cell if there are more 
        %       than one set of data in X2
            if (iscell(X2))
                nSet2 = numel(X2);
                transformedData = cell(1,nSet2);
                for i=1:nSet2
                    transformedData{i} = OB.Transform(X2{i});
                end
            else
                X2=X2(:,:,:);
                [~, nNum2,nSet2] = size(X2);
                transformedData = cell(1,nSet2);
                for J=1:nSet2
                    a = cell(1,OB.nClass);
                    for I = 1:OB.nClass
                        Z = exp(-orzL2Distance(OB.X1{I},X2(:,:,J))/OB.nSigma);
                        a{I} = OB.eigVec{I}' * Z;
                    end
                    aFinal=zeros(sum(OB.nSubDim1),nNum2);
                    for rr=1:nNum2
                        for I=1:OB.nClass
                            f1 = 1+ sum(OB.nSubDim1(1:I-1));
                            t1 = sum(OB.nSubDim1(1:I));
                            aFinal(f1:t1,rr) = a{I}(:,rr);
                        end
                    end
                    transformedData{J} = OB.O*aFinal;
                end
                if (nSet2==1)
                    transformedData = transformedData{1};
                end
            end
        end
        
    end% methods
end% classdef
