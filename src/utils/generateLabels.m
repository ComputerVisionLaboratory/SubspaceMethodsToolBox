function labels = generateLabels(numClasses, numSets, specific_class)
         % Check if numSets is provided, otherwise default to numClasses
    if nargin < 2
        numSets = 1;
    end


    % Special case when numClasses is 1
    if numClasses == 1
    if  nargin > 2 
        labels = specific_class;
        return;
    end
        labels = 1;
        return;
    end

    % Generate labels
    labels = repmat(1:numClasses, numSets, 1);
    labels = labels(:)';
    end
    