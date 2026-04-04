function plot_single_gpu_overview()
% 绘制图4-16：单卡性能综合对比图

root_dir = fileparts(mfilename('fullpath'));
csv_path = fullfile(root_dir, 'single_gpu_overview_metrics.csv');
out_path = fullfile(root_dir, 'fig4_16_single_gpu_overview.png');

tbl = readtable(csv_path, 'TextType', 'string');
metrics = {'QPS↑', 'p99延迟↓', 'PCIe传输次数↓', 'GPU利用率↑'};

raw = [
    tbl.qps, ...
    tbl.p99_latency_ms, ...
    tbl.pcie_transfer_count, ...
    tbl.gpu_utilization_pct
];

norm_values = zeros(size(raw));
norm_values(:, 1) = raw(:, 1) ./ max(raw(:, 1));
norm_values(:, 2) = min(raw(:, 2)) ./ raw(:, 2);
norm_values(:, 3) = min(raw(:, 3)) ./ raw(:, 3);
norm_values(:, 4) = raw(:, 4) ./ max(raw(:, 4));

plot_values = norm_values.';
colors = [
    74, 111, 165;
    233, 138, 21;
    192, 80, 77;
    111, 168, 82
] / 255;

fig = figure('Color', 'w', 'Position', [120, 120, 1020, 560]);
ax = axes(fig);
hb = bar(ax, plot_values, 'grouped', 'BarWidth', 0.82);
hold(ax, 'on');

for i = 1:numel(hb)
    hb(i).FaceColor = colors(i, :);
    hb(i).EdgeColor = 'none';
end

ax.FontName = 'Times New Roman';
ax.FontSize = 12;
ax.Box = 'off';
ax.LineWidth = 1.0;
ax.YGrid = 'on';
ax.GridAlpha = 0.16;
ax.Layer = 'top';
ax.TickDir = 'out';

xticks(ax, 1:numel(metrics));
xticklabels(ax, metrics);
ylim(ax, [0, 1.18]);
ylabel(ax, '归一化性能得分（越高越好）', 'FontName', 'Songti SC', 'FontSize', 13);
legend(ax, tbl.scheme, 'Location', 'northoutside', 'Orientation', 'horizontal', 'NumColumns', 2, 'FontName', 'Songti SC', 'Box', 'off');

raw_labels = strings(size(raw));
raw_labels(:, 1) = compose('%.0f', raw(:, 1));
raw_labels(:, 2) = compose('%.0f ms', raw(:, 2));
raw_labels(:, 3) = compose('%.1f 次', raw(:, 3));
raw_labels(:, 4) = compose('%.0f%%', raw(:, 4));

for i = 1:numel(hb)
    x_points = hb(i).XEndPoints;
    y_points = hb(i).YEndPoints;
    for j = 1:numel(x_points)
        text(x_points(j), y_points(j) + 0.03, raw_labels(i, j), ...
            'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom', ...
            'FontName', 'Times New Roman', 'FontSize', 10.5, 'Rotation', 90);
    end
end

exportgraphics(fig, out_path, 'Resolution', 220);
close(fig);
end
