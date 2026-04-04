function plot_single_multi_benefit_summary()
% 绘制图6-7：单卡优化与多 GPU 扩展收益图

root_dir = fileparts(mfilename('fullpath'));
csv_path = fullfile(root_dir, 'single_multi_benefit_summary.csv');
out_path = fullfile(root_dir, 'fig6_7_single_multi_summary.png');

tbl = readtable(csv_path, 'TextType', 'string');
labels = {'Orig.', 'Single', '2 GPU', '4 GPU'};
metrics = {'QPS', 'Latency (ms)', 'CPU Utilization (%)'};
values = [tbl.qps, tbl.p99_latency_ms, tbl.cpu_util];
offsets = [850, 1.2, 1.0];
y_lims = [0 52000; 0 75; 0 70];

fig = figure('Color', 'w', 'Position', [120, 120, 1080, 420]);
tiledlayout(fig, 1, 3, 'Padding', 'compact', 'TileSpacing', 'compact');

for i = 1:3
    ax = nexttile;
    if i == 1
        face_color = [1 1 1];
    elseif i == 2
        face_color = [0.82 0.82 0.82];
    else
        face_color = [0.65 0.65 0.65];
    end
    bars = bar(ax, values(:, i), 'FaceColor', face_color, 'EdgeColor', [0 0 0], 'LineWidth', 1.2);
    apply_axis_style(ax);
    xticks(ax, 1:height(tbl));
    xticklabels(ax, labels);
    xlabel(ax, 'Schemes', 'FontName', 'Times New Roman', 'FontSize', 13);
    ylabel(ax, metrics{i}, 'FontName', 'Times New Roman', 'FontSize', 13);
    ylim(ax, y_lims(i, :));
    for j = 1:numel(bars.YData)
        text(ax, j, bars.YData(j) + offsets(i), sprintf('%.2f', bars.YData(j)), ...
            'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom', ...
            'FontName', 'Times New Roman', 'FontSize', 9.6);
    end
end

exportgraphics(fig, out_path, 'Resolution', 220);
close(fig);
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
