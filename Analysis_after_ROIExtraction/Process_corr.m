% 初始化結果矩陣
results_diag_sub = [];
results_pval_scn = [];

% 定義 ROI 範圍
roiRange = [001:100];

% 迴圈處理每個 ROI
for roiNum = roiRange
    % 格式化 ROI 編號為三位數
    roiStr = sprintf('%03d', roiNum);
    
    % 構建檔案名稱
    condition2File = sprintf('Condition2_ROI%s_movie.mat', roiStr);
    condition1File = sprintf('Condition1_ROI%s_movie.mat', roiStr);
    
    try
        % 載入 Condition2 檔案
        load(condition2File, 'one');
        avgofothers = one; % 將資料存為 avgofothers
        
        % 載入 Condition1 檔案
        load(condition1File, 'one');
        
        % 呼叫函數進行計算
        [diag_sub, pval_scn] = corr_one2avgofothers(one, avgofothers, 1, 0, 'a');
        
        % 將結果存到矩陣中
        results_diag_sub = [results_diag_sub; diag_sub];
        results_pval_scn = [results_pval_scn; pval_scn];
        
        fprintf('ROI%s 處理完成。\n', roiStr);
    catch ME
        % 如果檔案載入或處理失敗，顯示錯誤訊息
        fprintf('ROI%s 處理失敗：%s\n', roiStr, ME.message);
    end
end

% 將結果存為矩陣
results = [results_diag_sub, results_pval_scn];

% 儲存結果到檔案
save('Whole_results_C1vsC2.mat', 'results');

disp('所有 ROI 處理完成！');
