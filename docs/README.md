# Mutual Subspace Methods Repository

Welcome to the Mutual Subspace Methods Repository! Here, we host a comprehensive collection of mutual subspace methods and their respective implementations, aiming to provide resources and examples for researchers and practitioners interested in subspace methods.

## Overview
Mutual Subspace Methods (MSMs) are a category of algorithms used for pattern recognition and classification. They operate by mapping data into subspaces and measuring the similarity between these subspaces. This repository includes various MSMs and their kernelized versions, providing implementations and examples to facilitate understanding and application.

## Available Methods
In this repository, you will find implementations for the following methods:

- [x] Mutual Subspace Method (MSM)
- [x] Constrained Mutual Subspace Method (CMSM)
- [ ] Orthogonal Mutual Subspace Method (OMSM)
- [x] Kernel Mutual Subspace Method (KMSM)
- [ ] Kernel Constrained Mutual Subspace Method (KCMSM)
- [ ] Kernel Orthogonal Mutual Subspace Method (KOMSM)
- [ ] Random Fourier Features MSM (RFFMSM)
- [ ] K-means KOMSM
- [ ] RFF + K-means KOMSM

## Sample Implementation
Below, we provide a sample MATLAB implementation for the Mutual Subspace Method (MSM). The implementation demonstrates how to compute the similarity between two subspaces and calculate the classification accuracy.

```matlab
load("data/CVLABFace2.mat")
training_data = X1;
testing_data = X2;

[~, num_samples, ~] = size(training_data);
[num_dim, num_samples_per_set, num_sets, num_classes] = size(testing_data);

num_dim_reference_subspaces = 20;
num_dim_input_subpaces = 5;

reference_subspaces = computeBasisVectors(training_data, num_dim_reference_subspaces);
input_subspaces = computeBasisVectors(testing_data, num_dim_input_subpaces);
similarities = computeSubspacesSimilarities(reference_subspaces, input_subspaces);

model_evaluation = ModelEvaluation(similarities(:, :, end, end), generateLabels(size(testing_data, 3), num_classes));

displayModelResults('Mutual Subspace Methods', model_evaluation);
```

Each example implementation for the methods listed above can be found in files named `example_(name_of_the_method).m`.

## Datasets
The repository includes examples and implementations that utilize the following datasets:

1. **CVLabFace**: A simple sample dataset consisting of 270 samples, designed to provide a straightforward example for implementation and testing.
2. **TsukubaHand24x24**: A comprehensive dataset created by the Computer Vision Lab of the University of Tsukuba. It contains more than 1.4 million images, offering a rich resource for testing and validating mutual subspace methods.

## Further Reading and References
To gain a deeper understanding of Mutual Subspace Methods and their applications, we recommend exploring the following papers and resources:

### Basics and Fundamentals
- [Subspace Methods](http://www.cvlab.cs.tsukuba.ac.jp/~kfukui/english/epapers/subspace_method.pdf): A comprehensive guide to subspace methods, providing the theoretical background and practical applications.

### Specific Methods
- [Comparison between Constrained Mutual Subspace Method and Orthogonal Mutual Subspace Method](https://www.cs.tsukuba.ac.jp/internal/techreport/data/CS-TR-06-7.pdf): A detailed comparison between CMSM and OMSM.
- [Face Recognition with the Multiple Constrained Mutual Subspace Method](http://www.cvlab.cs.tsukuba.ac.jp/~kfukui/english/epapers/AVBPA05.pdf): An application of CMSM in face recognition.
- [Hand Shape Recognition based on Kernel Orthogonal Mutual Subspace Method](http://www.cvlab.cs.tsukuba.ac.jp/~kfukui/english/epapers/MVA2009.pdf): Discussing the application of KOMSM in hand shape recognition.

## Contribution and Collaboration
We welcome contributions and collaborations from the community! Feel free to fork the repository, make your changes, and submit a pull request. If you have any questions or suggestions, feel free to open an issue or contact the maintainers.

Let's work together to enhance the understanding and application of Mutual Subspace Methods!