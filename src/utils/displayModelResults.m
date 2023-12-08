function displayModelResults(model_name, model_evaluation)
% This function displays the model evaluation results.
%
% Parameters:
% - model_name: Name of the model being evaluated.
% - model_evaluation: Object of ModelEvaluation class containing evaluation results.

% Assertions to check input types
assert(ischar(model_name) || isstring(model_name), 'The model name should be a string.');
assert(isa(model_evaluation, 'ModelEvaluation'), 'The model_evaluation should be an instance of the ModelEvaluation class.');

% Display the model name
fprintf('\nModel: %s\n', model_name);

% Display the results
disp('---------- Model Evaluation Results ----------');
fprintf('Model Accuracy: %.2f%%\n', model_evaluation.accuracy * 100); % Display as percentage
fprintf('Model Error Rate: %.2f%%\n', model_evaluation.error_rate * 100); % Display as percentage
fprintf('Equal Error Rate (EER): %.2f%%\n', model_evaluation.equal_error_rate * 100); % Display as percentage
fprintf('Classification Threshold: %.2f\n', model_evaluation.classification_threshold);
disp('----------------------------------------------');
end
