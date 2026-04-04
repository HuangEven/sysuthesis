function plot_qps_vs_gpu_scaling()
% 绘制图5-15：QPS 随 GPU 数量扩展曲线

root_dir = fileparts(mfilename('fullpath'));
csv_path = fullfile(root_dir, 'gpu_scaling_qps.csv');
out_path = fullfile(root_dir, 'fig5_15_qps_vs_gpu.png');

tbl = readtable(csv_path, 'TextType', 'string');
schemes = unique(tbl.scheme, 'stable');

fig = figure('Color', 'w', 'Position', [120, 120, 860, 520]);
ax = axes(fig);
hold(ax, 'on');

line_styles = {'-', '--', '-.', ':'};
markers = {'o', 's', '^', 'd'};

for i = 1:numel(schemes)
    mask = tbl.scheme == schemes(i);
    x = tbl.gpu_count(mask);
    y = tbl.qps(mask);

    plot(ax, x, y, ...
        'Color', 'k', ...
        'LineStyle', line_styles{min(i, numel(line_styles))}, ...
        'LineWidth', 1.6, ...
        'Marker', markers{min(i, numel(markers))}, ...
        'MarkerSize', 7, ...
        'MarkerFaceColor', 'w', ...
        'DisplayName', schemes(i));

    for j = 1:numel(x)
        text(x(j), y(j) + 350, sprintf('%.2f', y(j)), ...
            'HorizontalAlignment', 'center', ...
            'VerticalAlignment', 'bottom', ...
            'FontName', 'Times New Roman', ...
            'FontSize', 10);
    end
end

ax.FontName = 'Times New Roman';
ax.FontSize = 12;
ax.LineWidth = 1.0;
ax.Box = 'off';
ax.TickDir = 'out';
ax.Layer = 'top';
ax.XGrid = 'on';
ax.YGrid = 'on';
ax.GridColor = [0.72, 0.72, 0.72];
ax.GridAlpha = 0.35;

xlim(ax, [0.8, 4.2]);
xticks(ax, [1, 2, 4]);
ylim(ax, [11000, 50000]);

xlabel(ax, 'Number of GPUs', 'FontName', 'Times New Roman', 'FontSize', 13);
ylabel(ax, 'QPS', 'FontName', 'Times New Roman', 'FontSize', 13);
legend(ax, 'Location', 'northwest', 'Box', 'off', 'FontName', 'Times New Roman');

exportgraphics(fig, out_path, 'Resolution', 220);
close(fig);
end
