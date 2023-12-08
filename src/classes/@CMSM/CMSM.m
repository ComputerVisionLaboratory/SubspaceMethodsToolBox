classdef CMSM
    properties
        name = 'Constrained Mutual Subspace Method';
        trainData;
        generalizedDifferenceSubspace; % GDS
        referenceSubspaces;
        numDimInputSubspace;
        numDimReferenceSubspace;
        trueTestLabels;
    end
    
    methods
        function obj = CMSM(trainData, numDimReferenceSubspace, numDimInputSubspace, indexOfEigsToKeep, labels)
            numDim = size(trainData, 1);
            numClasses = size(trainData, 3);
            obj.trainData = trainData;
            obj.numDimReferenceSubspace = numDimReferenceSubspace;
            obj.numDimInputSubspace = numDimInputSubspace;
            obj.trueTestLabels = labels;
            subspaces = cvlBasisVector(obj.trainData,...
                obj.numDimReferenceSubspace);
            P = zeros(numDim, numDim);
            for I=1:numClasses
                P = P + subspaces(:,:,I)*subspaces(:,:,I)';
            end
            [B, C] = eig(P);
            C = diag(C);
            [~, index] = sort(C,'descend');
            B = B(:,index);
            GDS = B(:,indexOfEigsToKeep+1:rank(P))';
            
            differenceSubspaces = zeros(size(GDS,1), numDimReferenceSubspace, numClasses);
            for I=1:numClasses
                differenceSubspaces(:,:,I) = orth(GDS*subspaces(:,:,I));
            end
            obj.generalizedDifferenceSubspace = GDS;
            obj.referenceSubspaces = differenceSubspaces;
        end
        
        
        % Returns the predicted labels for the test data
        function prediction = predict(obj, testData)
            similarityScores = obj.getSimilarityScores(testData);
            eval = ModelEvaluation(similarityScores, obj.trueTestLabels, obj.name);
            prediction = eval.predicted_labels;
        end
        
        % Returns the similarity scores for the test data (same as probabilities)
        function probabilities = predictProb(obj, testData)
            probabilities = obj.getSimilarityScores(testData);
        end
        
        % Returns the evaluation object for the test data
        function eval = evaluate(obj, testData)
            similarityScores = obj.getSimilarityScores(testData);
            eval = ModelEvaluation(similarityScores, obj.trueTestLabels, obj.name);
        end
    end
    
    methods (Access = private)
        function scores = getSimilarityScores(obj, testData)
            testDatasize = size(testData);
            testDatasizeNumElements = numel(testDatasize);
            
            if testDatasizeNumElements == 4
                numSets = testDatasize(3);
                numClasses = testDatasize(4);
            elseif testDatasizeNumElements == 3
                numSets = 1;
                numClasses = testDatasize(3);
            end
            
            subspace = cvlBasisVector(testData,...
                obj.numDimInputSubspace);
            GDSnumDim = size(obj.generalizedDifferenceSubspace, 1);
            if  testDatasizeNumElements == 4
                differenceSubspace = zeros(GDSnumDim,...
                    obj.numDimInputSubspace,...
                    numSets,...
                    numClasses);
                
                for I=1:numClasses
                    for J=1:numSets
                        differenceSubspace(:,:,J,I) = orth(obj.generalizedDifferenceSubspace*subspace(:,:,J,I));
                    end
                end
            elseif testDatasizeNumElements == 3
                differenceSubspace = zeros(GDSnumDim, obj.numDimInputSubspace, numClasses);
                for I=1:numClasses
                    differenceSubspace(:,:,I) = orth(obj.generalizedDifferenceSubspace*subspace(:,:,I));
                end
            else
                differenceSubspace = orth(obj.generalizedDifferenceSubspace*subspace);
            end
            inputSubspace = differenceSubspace;
            similarities = cvlCanonicalAngles(obj.referenceSubspaces,...
                inputSubspace);
            scores = similarities(:, :, end, end);
        end
    end
end
