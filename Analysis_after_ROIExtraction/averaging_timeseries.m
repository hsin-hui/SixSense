% Averaging time series 應該要在 ROI Extraction 之前做才對，但最初版本的做反了

clear all

% 定義受試者資料夾
expdir = './'; % 根目錄，包含所有受試者資料夾

% 定義需要平均的列範圍
ranges = {
    374:457;
    613:837;
    843:915;
    924:968;
    1114:1329;
    1498:1548;
    1810:1827
};

% 搜尋該受試者資料夾中的所有 .mat 檔案
mat_files = dir(fullfile(expdir, '*.mat'));
    
    % 對每個 .mat 檔案進行處理
    for file_idx = 1:length(mat_files)
        mat_file = fullfile(mat_files(file_idx).name);
        disp(['Processing file: ' mat_files(file_idx).name]);
        
        % 載入 .mat 檔案
        load(mat_file, 'gdata'); % 假設每個檔案包含 'gdata'
        gdata=zscore(gdata(:,374:2269),0,2);% claire

        % 初始化新的矩陣，用於保存各時間區段的平均值
        num_rows = size(gdata, 1); % 確認行數
        num_ranges = length(ranges); % 確認區段數
        averaged_matrix = zeros(num_rows, num_ranges); % 初始化結果矩陣 -->
        % zscore shouldn't be done here
        
        % 對每個指定的列範圍進行處理
        for r = 1:num_ranges
            col_range = ranges{r};
            
            % 提取子矩陣並計算平均值
            submatrix = gdata(:, col_range);
            averaged_matrix(:, r) = mean(submatrix, 2,'includenan'); % 計算每行在該區段的平均值
        end
        
        % 將結果存為新的 .mat 檔案
        [~, file_name, ~] = fileparts(mat_files(file_idx).name); % 去掉檔案路徑與副檔名
        save_file = fullfile(expdir, [file_name '_means.mat']);
        save(save_file, 'averaged_matrix');
        disp(['Saved averaged matrix to: ' save_file]);
    end

disp('All subjects and their .mat files processed successfully.');
