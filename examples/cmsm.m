%% Load Data
clear;
clc;
% load('TsukubaHandDigitsDataset.mat')
% Check if the variable 'trainData' and 'testData' do not exist in the workspace
if ~(exist('trainData', 'var') == 1 && exist('testData', 'var') == 1)
    % If they don't exist, load the data from the .mat file
    load('TsukubaHandDigitsDataset24x24.mat');
end
% you can use the following code to convert the test data format from 3d to 4d
% testData = subsetTestData(testData, 4);
specific_class = 1;
class_num = 6;
%% to accomodate for MATLAB indexing
specific_class = specific_class + 1;
training_data = trainData;
% testing_data = testData;
testing_data = testData(:, :, specific_class);
size_of_test_data = size(testing_data);
dim = size_of_test_data(1);
del_subspace_dim = 3;

% get number of elements of size_of_test_data
array_size = numel(size_of_test_data);

if array_size == 4
    % do nothing
    num_samples_per_set = size_of_test_data(2);
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
tic;
num_dim_reference_subspaces = 10;
num_dim_input_subpaces = 5;

reference_subspaces = cvlBasisVector(training_data, num_dim_reference_subspaces);
input_subspaces = cvlBasisVector(testing_data, num_dim_input_subpaces);

save('reference_subspaces.mat', 'reference_subspaces');
% reference_subspaces = reference_subspaces(:, :, 1);
% Generalizated difference subspace(Constraint Subspace)
P = zeros(dim, dim);
for I=1:class_num
    P = P + reference_subspaces(:,:,I)*reference_subspaces(:,:,I)';
end
[B, C] = eig(P);
C = diag(C);
[~, index] = sort(C,'descend');
B = B(:,index); C = C(index);
difference = B(:,del_subspace_dim+1:rank(P))';

difference_subspace = zeros(size(difference,1), num_dim_reference_subspaces, size(reference_subspaces,3));
for I=1:size(reference_subspaces,3)
    difference_subspace(:,:,I) = orth(difference*reference_subspaces(:,:,I));
end

% process input difference subspace
if  array_size == 4
    input_difference_subspace = zeros(size(difference,1), num_dim_input_subpaces, num_sets, num_classes);
for I=1:num_classes
    for J=1:num_sets
        input_difference_subspace(:,:,J,I) = orth(difference*input_subspaces(:,:,J,I));
    end
end
elseif array_size == 3
    input_difference_subspace = zeros(size(difference,1), num_dim_input_subpaces, num_classes);
    for I=1:num_classes
        input_difference_subspace(:,:,I) = orth(difference*input_subspaces(:,:,I));
    end
else
        input_difference_subspace = orth(difference*input_subspaces);
end

reference_subspaces= difference_subspace;
input_subspaces = input_difference_subspace;

reference_subspaces = reference_subspaces(:, :, 1:3);

tic;
%% Recognition Phase
% convert reference and input subspace to cells
reference_subspaces = mat2cell(reference_subspaces, size(reference_subspaces, 1), size(reference_subspaces, 2), ones(1, size(reference_subspaces, 3)));
input_subspaces = mat2cell(input_subspaces, size(input_subspaces, 1), size(input_subspaces, 2), ones(1, size(input_subspaces, 3)));
similarities = cvlCanonicalAngles(reference_subspaces, input_subspaces);
similarities = similarities(:, :, end, end);
% End timing and display the elapsed time
elapsedTime = toc;
fprintf('The code block executed in %.5f seconds.\n', elapsedTime);
model_evaluation = ModelEvaluation(similarities, generateLabels(num_classes, num_sets, specific_class));

displayModelResults('Contained Mutual Subspace Methods', model_evaluation);

%% Print preditions
disp(model_evaluation.predicted_labels);
disp(model_evaluation.true_labels);
disp(similarities);
plotSimilarityMatrix(similarities, 'CMSM')
% disp(similarities)
% plotSimilarities(similarities)
