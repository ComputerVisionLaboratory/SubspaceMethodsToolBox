function labels = generateLabels(testing_data)
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
    
    % Generate labels
    labels = repmat(1:num_classes, num_sets, 1);
    labels = labels(:)';
    end
    