%% Load data
testDataUsage = TestDataUsage.Subsets;
n = 2;
[trainData, testData, testLabels] = prepareData(testDataUsage, n);

%% Train model
numDimReferenceSubspace = 10;
numDimInputSubspace = 4;
sigma = 1;

model = KMSM(trainData,...
    numDimReferenceSubspace,...
    numDimInputSubspace,...
    sigma,...
    testLabels);

%% Evaluate model
modelEvaluation = model.evaluate(testData);
modelEvaluation.printResults();