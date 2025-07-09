% Load the two matrices
load('Whole_results_C1vsC2_fisher_transformed.mat', 'results'); % Replace with the filename for the first matrix
data_matrix1 = results; % Rename to avoid conflict
clear results;

load('Whole_results_C2vsC3_fisher_transformed.mat', 'results'); % Replace with the filename for the second matrix
data_matrix2 = results; % Rename to avoid conflict
clear results;

% Extract r-values and p-values
r_values1 = data_matrix1(:, 1:end-1); % Extract r-values from matrix1
r_values2 = data_matrix2(:, 1:end-1); % Extract r-values from matrix2
p_values1 = data_matrix1(:, end);     % Extract p-values from matrix1
p_values2 = data_matrix2(:, end);     % Extract p-values from matrix2

% Ensure the number of rows (ROIs) matches
if size(r_values1, 1) ~= size(r_values2, 1)
    error('The number of ROIs in the two matrices does not match.');
end

% Get ROI indices (assuming ROIs are numbered sequentially starting from 1)
roi_indices = (1:size(r_values1, 1))';

% Create a logical mask for p-value filtering
valid_mask = (p_values1 < 0.01) & (p_values2 < 0.01);

% Filter r-values using the mask
filtered_r_values1 = r_values1(valid_mask, :);
filtered_r_values2 = r_values2(valid_mask, :);
filtered_roi_indices = roi_indices(valid_mask);

% Average r-values across participants for each ROI
mean_r1 = mean(filtered_r_values1, 2, 'omitnan'); % Mean for matrix1 across columns
mean_r2 = mean(filtered_r_values2, 2, 'omitnan'); % Mean for matrix2 across columns

% Calculate the difference between the two averaged matrices
difference_r = mean_r2 - mean_r1;

% Combine filtered ROI indices and difference values
roitable = [filtered_roi_indices, difference_r];

% Save the difference result
save('roitable.mat', 'roitable');

disp('Difference between r-values has been calculated and saved to roitable.mat.');
