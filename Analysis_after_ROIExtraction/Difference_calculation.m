% Load the two matrices
load('Whole_results_C1vsC2_fisher_transformed.mat', 'results'); % Replace with the filename for the first matrix
data_matrix1 = results; % Rename to avoid conflict
clear results;

load('Whole_results_C2vsC3_fisher_transformed.mat', 'results'); % Replace with the filename for the second matrix
data_matrix2 = results; % Rename to avoid conflict
clear results;

% Extract r-values (ignoring the last column)
r_values1 = data_matrix1(:, 1:end-1); % Remove the last column (p-values)
r_values2 = data_matrix2(:, 1:end-1); % Remove the last column (p-values)

% Ensure the number of rows (ROIs) matches
if size(r_values1, 1) ~= size(r_values2, 1)
    error('The number of ROIs in the two matrices does not match.');
end

% Get ROI indices (assuming ROIs are numbered sequentially starting from 1)
roi_indices = (1:size(r_values1, 1))';

% Average r-values across participants for each ROI
mean_r1 = mean(r_values1, 2, 'omitnan'); % Mean for matrix1 across columns
mean_r2 = mean(r_values2, 2, 'omitnan'); % Mean for matrix2 across columns

% Calculate the difference between the two averaged matrices
difference_r = mean_r2 - mean_r1;

% Combine ROI indices and difference values
roitable = [roi_indices, difference_r];

% Save the difference result
save('roitable.mat', 'roitable');

disp('Difference between r-values has been calculated and saved to roitable.mat.');