% Example MATLAB Code for Fisher Transformation

% Input matrix (rows: 100 ROIs, columns: subjects' r-values + p-values)
% Assuming the input matrix is named `data_matrix`
% The last column is assumed to be the p-values
load('Whole_results_C1vsC2.mat'); % Replace with your actual file if necessary
% Assuming the matrix is now loaded into `results`

% Extract r-values (all columns except the last one)
r_values = results(:, (1:end-1));

% Perform Fisher transformation on r-values
z_values = 0.5 * log((1 + r_values) ./ (1 - r_values));

% Combine transformed z-values with the last column (p-values)
results(:, 1:end-1) = z_values;

% Save the transformed matrix
save('Whole_results_C1vsC2_fisher_transformed.mat', 'results');

disp('Fisher transformation completed and saved');
