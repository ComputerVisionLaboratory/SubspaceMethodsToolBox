%% Load data
testDataUsage = TestDataUsage.WholeData;
[trainData, testData, testLabels] = prepareData(testDataUsage);

%% Train model
numDimReferenceSubspace = 10;
numDimInputSubspace = 4;

model = MSM(trainData,...
    numDimReferenceSubspace,...
    numDimInputSubspace,...
    testLabels);

%% Evaluate model
modelEvaluation = model.evaluate(testData);
modelEvaluation.printResults();




