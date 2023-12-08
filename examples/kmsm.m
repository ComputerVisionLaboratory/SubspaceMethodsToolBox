%% Load Data
clear;
clc;
load('TsukubaHandDigitsDataset24x24.mat')
% Check if the variable 'trainData' and 'testData' do not exist in the workspace
% if ~(exist('trainData', 'var') == 1 && exist('testData', 'var') == 1)
%     % If they don't exist, load the data from the .mat file
%     load('TsukubaHandDigitsDataset24x24.mat');
% end
% you can use the following code to convert the test data format from 3d to 4d
testData = subsetTestData(testData, 2);
% specific_class = 5;
%% to accomodate for MATLAB indexing
% specific_class = specific_class + 1;
training_data = cvlNormalize(trainData);
testing_data = cvlNormalize(testData);
% testing_data = testData(:, :, specific_class);
size_of_test_data = size(testing_data);

% get number of elements of size_of_test_data
array_size = numel(size_of_test_data);

if array_size == 4
    % do nothing
    num_sets = size_of_test_data(3);
    num_classes = size_of_test_data(4);
elseif array_size == 3
    num_sets = 1;
    num_classes = size_of_test_data(3);
else
    num_classes = 1;
    num_sets = 1;
end

%% Train Model
num_dim_reference_subspaces = 10;
num_dim_input_subpaces = 5;
sigma = 1;

reference_subspaces = cvlKernelBasisVector(training_data, num_dim_reference_subspaces, sigma);
input_subspaces = cvlKernelBasisVector(testing_data, num_dim_input_subpaces, sigma);
% save('reference_subspaces.mat', 'reference_subspaces');
% reference_subspaces = reference_subspaces(:, :, 1);
tic;
%% Recognition Phase
similarities = cvlKernelCanonicalAngles(training_data,reference_subspaces,...
    testing_data, input_subspaces, sigma);
similarities = similarities(:, :, end, end);
% End timing and display the elapsed time
elapsedTime = toc;
fprintf('The code block executed in %.5f seconds.\n', elapsedTime);
model_evaluation = ModelEvaluation(similarities, generateLabels(num_classes, num_sets));

displayModelResults('Kernel Mutual Subspace Methods', model_evaluation);

%% Print preditions
% disp(model_evaluation.predicted_labels);
% disp(model_evaluation.true_labels);
% disp(similarities)
% plotSimilarities(similarities)