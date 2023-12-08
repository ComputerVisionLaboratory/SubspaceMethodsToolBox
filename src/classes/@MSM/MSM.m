classdef MSM
    properties
        name = 'Mutual Subspace Method';
        trainData;
        referenceSubspaces;
        numDimInputSubspace;
        numDimReferenceSubspace;
        trueTestLabels;
    end

    methods
        function obj = MSM(trainData, numDimReferenceSubspace, numDimInputSubspace, labels)
            obj.trainData = trainData;
            obj.numDimReferenceSubspace = numDimReferenceSubspace;
            obj.numDimInputSubspace = numDimInputSubspace;
            obj.trueTestLabels = labels;
            subspaces = cvlBasisVector(obj.trainData,...
                                         obj.numDimReferenceSubspace);
            obj.referenceSubspaces = subspaces;
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
            inputSubspace = cvlBasisVector(testData,...
                                               obj.numDimInputSubspace);
            similarities = cvlCanonicalAngles(obj.referenceSubspaces,...
             inputSubspace);
            scores = similarities(:, :, end, end);
        end
    end
end
