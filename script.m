function plot_vr_combined(mode)
% Plot four combined figures (SUS / Coverage / Click Engagement / Revisit Ratio)
% Each figure overlays Sheet1 & Sheet2 with different colors and markers,
% shows two least-squares lines, and annotates Pearson r and N for both sheets.
%
% mode: 'initial'   -> y = VR Initial Score  (AB: P1; BA: P2)
%       'immediate' -> 同 'initial'（兼容旧调用）
%       'retention' -> y = VR Retention (P' - P) (AB: P1'-P1; BA: P2'-P2)

if nargin<1, mode = 'initial'; end
if strcmpi(mode,'immediate'), mode = 'initial'; end

excelFile = 'Data.xlsx';
sheets    = {'Sheet1','Sheet2'};
predList  = {'SUS Total (0–100)','Coverage','Click Engagement','Revisit Ratio'};
predLabel = {'SUS Total (0–100)','Coverage','Click Engagement','Revisit Ratio'};
yLabelInitial   = 'VR Initial Score (0–100)';
yLabelRetention = "VR Retention (P' − P)";

% Colors/markers for two sheets
c1 = [0 0.4470 0.7410]; m1 = 'o';   % Sheet1
c2 = [0.8500 0.3250 0.0980]; m2 = 's'; % Sheet2

% Read both sheets
S = cell(1,2);
for i = 1:2
    T = readtable(excelFile, 'Sheet', sheets{i}, 'VariableNamingRule','preserve');
    S{i}.name = sheets{i};
    S{i}.T    = T;

    % Sequence（文本列）
    seq = getColText(T, {'Sequence (AB/BA)','Sequence'});
    seq = upper(strtrim(seq));
    isAB = seq=="AB";  isBA = seq=="BA";

    % 分数列（数值化）
    P1  = getColNumeric(T, {'P1 Score (0-100)','P1 Score (0–100)'});
    P1p = getColNumeric(T, {"P1' Score (0-100)","P1’ Score (0-100)","P1' Score (0–100)","P1’ Score (0–100)"});
    P2  = getColNumeric(T, {'P2 Score (0-100)','P2 Score (0–100)'});
    P2p = getColNumeric(T, {"P2' Score (0-100)","P2’ Score (0-100)","P2' Score (0–100)","P2’ Score (0–100)"});

    % y variable
    switch lower(mode)
        case 'initial'
            y = nan(height(T),1);   y(isAB)=P1(isAB);  y(isBA)=P2(isBA);
            S{i}.yLabel = yLabelInitial;
            savePrefix = 'VR_Initial_';
        case 'retention'
            y = nan(height(T),1);   y(isAB)=P1p(isAB)-P1(isAB);  y(isBA)=P2p(isBA)-P2(isBA);
            S{i}.yLabel = yLabelRetention;
            savePrefix = 'VR_Retention_';
        otherwise
            error('Unknown mode: %s (use ''initial'' or ''retention'')', mode);
    end
    S{i}.y = y;
    S{i}.savePrefix = savePrefix;

    % predictors（数值化）
    S{i}.X{1} = getColNumeric(T, {'SUS Total (0–100)','SUS Total (0-100)','SUS Total'});
    S{i}.X{2} = getColNumeric(T, {'Coverage'});
    S{i}.X{3} = getColNumeric(T, {'Click Engagement'});
    S{i}.X{4} = getColNumeric(T, {'Revisit Ratio'});
end

% Make four combined figures
for k = 1:numel(predList)
    h = figure('Color','w','Units','inches','Position',[1 1 6.2 4.2]);
    hold on; grid on; box on;

    % Sheet1
    x1 = S{1}.X{k}; y1 = S{1}.y;
    v1 = ~isnan(x1) & ~isnan(y1);  x1=x1(v1); y1=y1(v1);
    s1 = scatter(x1, y1, 42, 'Marker', m1, 'MarkerEdgeColor', c1, ...
        'MarkerFaceColor', c1, 'MarkerFaceAlpha', 0.75, 'DisplayName','Sheet1');
    r1 = NaN;
    if numel(x1)>=2 && range(x1)>0
        C = corrcoef(x1,y1,'Rows','pairwise'); r1 = C(1,2);
        p1 = polyfit(x1,y1,1); xf = linspace(min(x1),max(x1),100);
        plot(xf, polyval(p1,xf), '-', 'Color', c1, 'LineWidth', 1.75, 'HandleVisibility','off');
    end

    % Sheet2
    x2 = S{2}.X{k}; y2 = S{2}.y;
    v2 = ~isnan(x2) & ~isnan(y2);  x2=x2(v2); y2=y2(v2);
    s2 = scatter(x2, y2, 42, 'Marker', m2, 'MarkerEdgeColor', c2, ...
        'MarkerFaceColor', c2, 'MarkerFaceAlpha', 0.75, 'DisplayName','Sheet2');
    r2 = NaN;
    if numel(x2)>=2 && range(x2)>0
        C = corrcoef(x2,y2,'Rows','pairwise'); r2 = C(1,2);
        p2 = polyfit(x2,y2,1); xf = linspace(min(x2),max(x2),100);
        plot(xf, polyval(p2,xf), '-', 'Color', c2, 'LineWidth', 1.75, 'HandleVisibility','off');
    end

    xlabel(predLabel{k}, 'Interpreter','none');
    ylabel(S{1}.yLabel, 'Interpreter','none');
    title(sprintf('%s vs %s', predLabel{k}, S{1}.yLabel), 'Interpreter','none');

    legText1 = sprintf('Sheet1  (r = %s,  N = %d)', fmtR(r1), numel(x1));
    legText2 = sprintf('Sheet2  (r = %s,  N = %d)', fmtR(r2), numel(x2));
    legend([s1 s2], {legText1, legText2}, 'Location','best', 'Box','off');

    % 统一坐标范围
    allx = [x1(:); x2(:)]; ally = [y1(:); y2(:)];
    if ~isempty(allx), xlim(padLim([min(allx) max(allx)], 0.04)); end
    if ~isempty(ally), ylim(padLim([min(ally) max(ally)], 0.06)); end
    set(gca,'LineWidth',0.8,'FontSize',11);

    % Save
    base = sprintf('%s%s', S{1}.savePrefix, strrep(predLabel{k},' ','_'));
    exportgraphics(h, [base '.pdf'], 'ContentType','vector');
    exportgraphics(h, [base '.png'], 'Resolution', 600);
    fprintf('Saved: %s.[pdf|png]\n', base);
end

fprintf('All combined figures generated for mode = %s.\n', mode);
end

%% ================= helpers =================
function v = getColNumeric(T, candidates)
% 返回 double 向量；若是文本/单元格，则尝试 str2double，失败给 NaN
    vn = findFirstVar(T, candidates);
    if isempty(vn), v = NaN(height(T),1); return; end
    vraw = T.(vn);
    if isnumeric(vraw) || islogical(vraw)
        v = double(vraw);
    elseif iscell(vraw)
        % 允许 cell 内有数字或字符串
        try
            v = cellfun(@(x) tryStr2Double(x), vraw);
        catch
            v = nan(height(T),1);
            for i=1:numel(vraw), v(i)=tryStr2Double(vraw{i}); end
        end
    elseif isstring(vraw) || ischar(vraw) || iscategorical(vraw)
        v = str2double(string(vraw));
    else
        v = str2double(string(vraw)); % 兜底
    end
end

function s = getColText(T, candidates)
% 返回 string 向量（用于 Sequence 等文本列）
    vn = findFirstVar(T, candidates);
    if isempty(vn), s = strings(height(T),1); return; end
    vraw = T.(vn);
    if isstring(vraw)
        s = vraw;
    elseif ischar(vraw)
        s = string(vraw);
    elseif iscell(vraw)
        s = string(vraw);
    elseif iscategorical(vraw)
        s = string(vraw);
    else
        s = string(vraw);
    end
end

function vn = findFirstVar(T, candidates)
% 忽略大小写 + contains 匹配；兼容 “– / -” 差异
    names = T.Properties.VariableNames;
    vn = '';
    for i = 1:numel(candidates)
        pat = candidates{i};
        pat = strrep(pat, '–', '-'); % 统一破折号/短横
        hit = find(contains(strrep(names,'–','-'), pat, 'IgnoreCase', true), 1);
        if ~isempty(hit), vn = names{hit}; return; end
    end
end

function x = tryStr2Double(a)
    if isnumeric(a) || islogical(a), x = double(a); return; end
    if isstring(a) || ischar(a),  x = str2double(string(a)); return; end
    if iscategorical(a),          x = str2double(string(a)); return; end
    x = NaN;
end

function s = fmtR(r)
    if isempty(r) || isnan(r), s = 'n/a'; else, s = sprintf('%.2f', r); end
end

function L = padLim(L, padFrac)
    if any(isnan(L)) || L(1)==L(2), return; end
    span = L(2)-L(1); pad = span*padFrac; L = [L(1)-pad, L(2)+pad];
end

% 生成合并图（初测）
%plot_vr_combined('initial');     % 或 plot_vr_combined('immediate')

% 生成合并图（保持度）
plot_vr_combined('retention');