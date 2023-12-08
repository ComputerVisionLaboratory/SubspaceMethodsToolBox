function data = subsetTestData(testData, numSets)
    numDim = size(testData, 1); % Image dimensions
    numClasses = size(testData, 3); % Number of classes

    % Initialize the new test data structure
    numSamplesPerClass = size(testData, 2);
    numSamplesPerSet = numSamplesPerClass / numSets;
    data = reshape(testData, [numDim, numSamplesPerSet, numSets, numClasses]);
end