classdef KMSM
    properties
        name = 'Kernel Mutual Subspace Method';
        trainData;
        referenceSubspaces;
        numDimInputSubspace;
        numDimReferenceSubspace;
        sigma;
        trueTestLabels;
    end

    methods
        function obj = KMSM(trainData, numDimReferenceSubspace, numDimInputSubspace, sigma, labels)
            obj.trainData = cvlNormalize(trainData);
            obj.sigma = sigma;
            obj.numDimReferenceSubspace = numDimReferenceSubspace;
            obj.numDimInputSubspace = numDimInputSubspace;
            obj.trueTestLabels = labels;
            obj.referenceSubspaces = cvlKernelBasisVector(obj.trainData,...
                                         obj.numDimReferenceSubspace,...
                                         obj.sigma);
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
            testData = cvlNormalize(testData);
            inputSubspace = cvlKernelBasisVector(testData,...
                                               obj.numDimInputSubspace,...
                                               obj.sigma);
            similarities = cvlKernelCanonicalAngles(obj.trainData,...
            obj.referenceSubspaces,...
            testData,...
             inputSubspace,...
             obj.sigma);
            scores = similarities(:, :, end, end);
        end
    end
end
