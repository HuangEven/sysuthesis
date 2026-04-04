function plot_single_gpu_overview()
% 绘制图4-16：单卡性能综合对比图

root_dir = fileparts(mfilename('fullpath'));
csv_path = fullfile(root_dir, 'single_gpu_overview_metrics.csv');
out_path = fullfile(root_dir, 'fig4_16_single_gpu_overview.png');

tbl = readtable(csv_path, 'TextType', 'string');
metric_fields = {'qps', 'p99_ms', 'pci_transfer_count', 'gpu_util'};
metric_labels = {'QPS', 'Latency (ms)', 'PCIe Transfer Count', 'GPU Utilization (%)'};
metric_offsets = [120, 1.6, 0.16, 1.4];
metric_limits = [0 7000; 0 75; 0 7.2; 0 95];
scheme_colors = [
    1.00, 1.00, 1.00;
    0.82, 0.82, 0.82;
    0.64, 0.64, 0.64;
    0.42, 0.42, 0.42
];

fig = figure('Color', 'w', 'Position', [120, 120, 1040, 640]);
tiledlayout(fig, 2, 2, 'Padding', 'compact', 'TileSpacing', 'compact');

for i = 1:numel(metric_fields)
    ax = nexttile;
    values = tbl.(metric_fields{i});
    bars = bar(ax, values, 'BarWidth', 0.68, 'FaceColor', 'flat', 'EdgeColor', 'k', 'LineWidth', 0.9);
    bars.CData = scheme_colors;

    ax.FontName = 'Times New Roman';
    ax.FontSize = 12;
    ax.Box = 'off';
    ax.LineWidth = 1.0;
    ax.YGrid = 'on';
    ax.GridLineStyle = '--';
    ax.GridAlpha = 0.35;
    ax.Layer = 'top';
    ax.TickDir = 'out';

    xticks(ax, 1:height(tbl));
    xticklabels(ax, tbl.scheme);
    xtickangle(ax, 0);
    xlabel(ax, 'Schemes', 'FontName', 'Times New Roman', 'FontSize', 13);
    ylabel(ax, metric_labels{i}, 'FontName', 'Times New Roman', 'FontSize', 13);
    ylim(ax, metric_limits(i, :));

    for j = 1:numel(values)
        text(ax, j, values(j) + metric_offsets(i), sprintf('%.2f', values(j)), ...
            'HorizontalAlignment', 'center', ...
            'VerticalAlignment', 'bottom', ...
            'FontName', 'Times New Roman', ...
            'FontSize', 10.0);
    end
end

exportgraphics(fig, out_path, 'Resolution', 220);
close(fig);
end
