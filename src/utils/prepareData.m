function [trainData, testData, testLabels] = prepareData(testDataUsage, varargin)
%PREPAREDATA Loads and prepares data for training and testing
% testDataUsage is used to specify how the test data will be used and it can be:
%   - TestDataUsage.WholeData: the whole test data is used to evaluate the model the resulting
%   testData is a 3d matrix numDimensions x numSamples x numClasses
%   - TestDataUsage.Subsets: the test data is divided into subsets the resulting testData is a 4d
%   matrix numDimensions x numSamplesPerSet x numSets x numClasses (varargin represents numSets) 
%   - TestDataUsage.SingleClass: only data from single class will be used, the resulting testData
%   is a 3d matrix numDimensions x numSamples x 1 (varargin represents classLabel)

load('TsukubaHandDigitsDataset24x24.mat', 'testData', 'trainData')
switch testDataUsage
    case TestDataUsage.SingleClass
        if nargin < 2
            error('Not enough arguments for TestDataUsage.SingleClass');
        end
        classLabel = varargin{1};
        assert(isnumeric(classLabel), 'classLabel must be an intiger value');
        assert(~isempty(classLabel), 'classLabel must be set for TestDataUsage.SingleClass');
        testData = testData(:, :, classLabel);
        testLabels = classLabel;
    case TestDataUsage.WholeData
        testLabels = generateLabels(testData);
    case TestDataUsage.Subsets
        % assert that there are more thatn two arguments and numSets is set
        if nargin < 2
            error('Not enough arguments for TestDataUsage.Subsets');
        end
        numSets = varargin{1};
        assert(isnumeric(numSets), 'classLabel must be an intiger value');
        assert(numSets > 0, 'numSets must be positive');
        assert(~isempty(numSets), 'numSets must be set for TestDataUsage.Subsets');
        
        testData = subsetTestData(testData, numSets);
        testLabels = generateLabels(testData);
end
end