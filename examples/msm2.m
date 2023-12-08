% testDataUsage = TestDataUsage.WholeData;
testDataUsage = TestDataUsage.Subsets;
numSets = 2;
[trainData, testData, testLabels] = prepareData(testDataUsage, numSets);

numDimReferenceSubspace = 10;
numDimInputSubspace = 4;

model = MSM(trainData,...
    numDimReferenceSubspace,...
    numDimInputSubspace,...
    testLabels);

modelEvaluation = model.evaluate(testData);
modelEvaluation.printResults();




