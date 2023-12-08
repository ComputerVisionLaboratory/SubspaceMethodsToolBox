function plotSimilarities(similarities)
    figure;
bar(similarities, 'FaceColor', 'b');
hold on;

% Highlight the class with the highest similarity
[~, maxIndex] = max(similarities);
bar(maxIndex, similarities(maxIndex), 'FaceColor', 'r');

% Add labels and title
xlabel('Class');
ylabel('Similarity Score');
title('Similarities with Highlighted Maximum');

% Correct the x-axis tick labels to start from 0
xticks(1:length(similarities));
xticklabels(arrayfun(@num2str, 0:length(similarities)-1, 'UniformOutput', false));

% Add a legend to explain the colors
legend({'Other Classes', 'Highest Similarity Class'}, 'Location', 'best');

hold off;