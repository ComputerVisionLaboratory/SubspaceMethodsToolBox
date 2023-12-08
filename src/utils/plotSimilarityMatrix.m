function plotSimilarityMatrix(similarityMatrix, model)
[numRows, numCols] = size(similarityMatrix);
% Plot the similarity matrix
figure;
imagesc(similarityMatrix); % Create a heatmap from the matrix
colorbar; % Add a colorbar to indicate the scale
title( model);
xlabel('Subspace Label');
ylabel('Subspace Label');
axis square; % Make the plot square to ensure aspect ratio is 1:1

ax = gca; % Get current axis
ax.XTickLabel = 0:(numCols-1); % Label X-axis ticks starting from 0
ax.YTickLabel = 0:(numRows-1); % Label Y-axis ticks starting from 0

% Get the number of rows and columns
[numRows, numCols] = size(similarityMatrix);

% Loop over each element and add text
for i = 1:numRows
    for j = 1:numCols
        % Place the text in the middle of each cell
        text(j, i, num2str(similarityMatrix(i, j), 2), ...
            'HorizontalAlignment', 'center', ...
            'VerticalAlignment', 'middle', ...
            'Color', 'white', ...
            'FontSize', 7);
    end
end
end
