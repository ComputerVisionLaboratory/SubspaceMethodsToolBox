%% Load data
testDataUsage = TestDataUsage.SingleClass;
n = 2;
[trainData, testData, testLabels] = prepareData(testDataUsage, n);

%% Train model
numDimReferenceSubspace = 10;
numDimInputSubspace = 4;
indexOfEigsToKeep = 3;

model = CMSM(trainData,...
    numDimReferenceSubspace,...
    numDimInputSubspace,...
    indexOfEigsToKeep,...
    testLabels);

%% Evaluate model
modelEvaluation = model.evaluate(testData);
modelEvaluation.printResults();




