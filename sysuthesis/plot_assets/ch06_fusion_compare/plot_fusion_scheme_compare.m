function plot_fusion_scheme_compare()
% 绘制图6-4至图6-6：融合系统与基线系统总体对比

root_dir = fileparts(mfilename('fullpath'));
csv_path = fullfile(root_dir, 'fusion_scheme_compare.csv');
tbl = readtable(csv_path, 'TextType', 'string');
if any(strcmp('scheme_desc', tbl.Properties.VariableNames))
    scheme_labels = wrap_labels(tbl.scheme_desc);
    legend_labels = cellstr(tbl.scheme_desc);
else
    scheme_labels = wrap_labels(tbl.scheme);
    legend_labels = cellstr(tbl.scheme);
end

% 图6-4：PR-AUC 对比
fig1 = figure('Color', 'w', 'Position', [120, 120, 760, 500]);
ax1 = axes(fig1);
bar(ax1, tbl.pr_auc, 'FaceColor', [1 1 1], 'EdgeColor', [0 0 0], 'LineWidth', 1.2);
apply_axis_style(ax1);
xticks(ax1, 1:height(tbl));
xticklabels(ax1, scheme_labels);
xlabel(ax1, 'Validation scenarios', 'FontName', 'Times New Roman', 'FontSize', 13);
ylabel(ax1, 'PR-AUC', 'FontName', 'Times New Roman', 'FontSize', 13);
ylim(ax1, [0.82, 0.94]);
annotate_single_series(ax1, tbl.pr_auc, 0.004, '%.4f');
exportgraphics(fig1, fullfile(root_dir, 'fig6_4_fusion_accuracy.png'), 'Resolution', 220);
close(fig1);

% 图6-5：QPS 对比
fig2 = figure('Color', 'w', 'Position', [120, 120, 760, 500]);
ax2 = axes(fig2);
bar(ax2, tbl.qps, 'FaceColor', [0.82 0.82 0.82], 'EdgeColor', [0 0 0], 'LineWidth', 1.2);
apply_axis_style(ax2);
xticks(ax2, 1:height(tbl));
xticklabels(ax2, scheme_labels);
xlabel(ax2, 'Validation scenarios', 'FontName', 'Times New Roman', 'FontSize', 13);
ylabel(ax2, 'QPS', 'FontName', 'Times New Roman', 'FontSize', 13);
ylim(ax2, [0, 5200]);
annotate_single_series(ax2, tbl.qps, 140, '%.2f');
exportgraphics(fig2, fullfile(root_dir, 'fig6_5_fusion_qps.png'), 'Resolution', 220);
close(fig2);

% 图6-6：效果-性能折中散点图
fig3 = figure('Color', 'w', 'Position', [120, 120, 780, 520]);
ax3 = axes(fig3);
hold(ax3, 'on');
markers = {'o', 's', '^', 'd'};
line_styles = {'-', '--', '-.', ':'};
for i = 1:height(tbl)
    plot(ax3, tbl.qps(i), tbl.pr_auc(i), ...
        'Color', 'k', ...
        'LineStyle', line_styles{i}, ...
        'Marker', markers{i}, ...
        'MarkerSize', 7.5, ...
        'MarkerFaceColor', 'w', ...
        'LineWidth', 1.4, ...
        'DisplayName', legend_labels{i});
        [xoff, yoff, halign] = tradeoff_label_offset(i);
        text(tbl.qps(i) + xoff, tbl.pr_auc(i) + yoff, sprintf('%.4f / %.2f', tbl.pr_auc(i), tbl.qps(i)), ...
            'FontName', 'Times New Roman', 'FontSize', 9.6, 'HorizontalAlignment', halign);
end

function labels = wrap_labels(values)
labels = cell(size(values));
for i = 1:numel(values)
    words = split(string(values(i)));
    if numel(words) <= 2
        labels{i} = char(join(words, newline));
    else
        mid = ceil(numel(words) / 2);
        labels{i} = char(join(words(1:mid), " ") + newline + join(words(mid+1:end), " "));
    end
end
end
apply_axis_style(ax3);
xlabel(ax3, 'QPS', 'FontName', 'Times New Roman', 'FontSize', 13);
ylabel(ax3, 'PR-AUC', 'FontName', 'Times New Roman', 'FontSize', 13);
xlim(ax3, [2500, 4800]);
ylim(ax3, [0.83, 0.936]);
legend(ax3, 'Location', 'southwest', 'Box', 'off', 'FontName', 'Times New Roman');
exportgraphics(fig3, fullfile(root_dir, 'fig6_6_fusion_tradeoff.png'), 'Resolution', 220);
close(fig3);
end

function apply_axis_style(ax)
ax.FontName = 'Times New Roman';
ax.FontSize = 12;
ax.LineWidth = 1.0;
ax.Box = 'off';
ax.TickDir = 'out';
ax.Layer = 'top';
ax.YGrid = 'on';
ax.GridColor = [0.72, 0.72, 0.72];
ax.GridAlpha = 0.35;
end

function annotate_single_series(ax, values, offset, format_spec)
for i = 1:numel(values)
    text(ax, i, values(i) + offset, sprintf(format_spec, values(i)), ...
        'HorizontalAlignment', 'center', ...
        'VerticalAlignment', 'bottom', ...
        'FontName', 'Times New Roman', ...
        'FontSize', 9.8);
end
end

function [xoff, yoff, halign] = tradeoff_label_offset(index)
switch index
    case 1
        xoff = 70; yoff = 0.0009; halign = 'left';
    case 2
        xoff = -70; yoff = 0.0006; halign = 'right';
    case 3
        xoff = 70; yoff = 0.0009; halign = 'left';
    otherwise
        xoff = 70; yoff = 0.0009; halign = 'left';
end
end
