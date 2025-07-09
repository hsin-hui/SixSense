clear all

% 初始化參數
base_dir = './'; % 根目錄
output_dir = '/home/commmunicationlab/Desktop/roiExtraction/ROI/Analysis'; % 儲存結果的目錄
roi_ranges = [1:100]; % 要處理的 ROI 範圍
subject_range = 43:63; % 受試者編號範圍
output_prefix = 'Condition3'; % 輸出檔案的前綴

% 確保輸出目錄存在
if ~exist(output_dir, 'dir')
    mkdir(output_dir);
end

% 遍歷每個 ROI
for roi = roi_ranges
    disp(['Processing ROI: ', num2str(roi)]);
    
    % 定義該 ROI 的檔案後綴
    roi_file_suffix = sprintf('roi%03d_means.mat', roi);
    output_file = fullfile(output_dir, sprintf('%s_ROI%03d_movie.mat', output_prefix, roi)); % 儲存結果的檔案名稱
    
    % 初始化 one 矩陣
    one = [];
    subject_count = 0; % 計算實際處理的受試者數量
    
    % 遍歷每個受試者（限制在指定範圍內）
    for subj_id = subject_range
        % 定義檔案名稱模式，允許中間有任意字串
        subj_pattern = sprintf('sub-%02d*%s', subj_id, roi_file_suffix);
        matching_files = dir(fullfile(base_dir, subj_pattern));
        
        % 如果沒有匹配的檔案，跳過
        if isempty(matching_files)
            warning('File not found for subject %02d ROI %03d, skipping...', subj_id, roi);
            continue;
        end
        
        % 使用第一個匹配的檔案
        file_path = fullfile(matching_files(1).folder, matching_files(1).name);
        disp(['  Loading file: ', file_path]);
        
        % 載入檔案並檢查內容
        try
            load(file_path, 'averaged_matrix'); % 載入 averaged_matrix
        catch
            warning('  Could not load averaged_matrix from file: %s, skipping...', file_path);
            continue;
        end
        
        % 檢查 averaged_matrix 是否存在
        if ~exist('averaged_matrix', 'var')
            warning('  averaged_matrix not found in file: %s, skipping...', file_path);
            continue;
        end
        
        % 在第一次加載時動態設置 features 和 scenes 並初始化 one 矩陣
        if isempty(one)
            features = size(averaged_matrix, 1); % 確定體素數量
            scenes = size(averaged_matrix, 2); % 確定場景數量
            one = nan(features, scenes, length(subject_range)); % 初始化 one 矩陣
            disp(['  Features dynamically set to: ', num2str(features)]);
            disp(['  Scenes dynamically set to: ', num2str(scenes)]);
        end
        
        % 檢查 averaged_matrix 大小是否符合 one 的維度
        if size(averaged_matrix, 1) ~= features || size(averaged_matrix, 2) ~= scenes
            warning('  File %s dimensions do not match, skipping...', file_path);
            continue;
        end
        
        % 將數據加入 one 矩陣
        subject_count = subject_count + 1;
        one(:, :, subject_count) = averaged_matrix;
    end
    
    % 確保至少有一個有效檔案被處理
    if subject_count == 0
        warning('No valid files were processed for ROI %03d. Skipping...', roi);
        continue;
    end
    
    % 剪裁 one 矩陣到實際處理的受試者數量
    one = one(:, :, 1:subject_count);
    
    % 儲存結果
    save(output_file, 'one');
    disp(['Saved aggregated data for ROI ', num2str(roi), ' to: ', output_file]);
    disp(['Processed a total of ', num2str(subject_count), ' subjects for ROI ', num2str(roi)]);
end

disp('All ROIs processed successfully.');
