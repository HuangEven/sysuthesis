function plot_single_gpu_overview()
% 绘制图4-16：单卡性能综合对比图

root_dir = fileparts(mfilename('fullpath'));
csv_path = fullfile(root_dir, 'single_gpu_overview_metrics.csv');
out_path = fullfile(root_dir, 'fig4_16_single_gpu_overview.png');

tbl = readtable(csv_path, 'TextType', 'string');
metric_fields = {'qps', 'p99_ms', 'pci_transfer_count', 'gpu_util'};
metric_labels = {'QPS', 'Latency (ms)', 'PCIe Transfer Count', 'GPU Utilization (%)'};
metric_offsets = [90, 1.4, 0.14, 1.2];
metric_limits = [0 5200; 0 75; 0 7.0; 0 75];
scheme_colors = [
    1.00, 1.00, 1.00;
    0.82, 0.82, 0.82;
    0.64, 0.64, 0.64;
    0.42, 0.42, 0.42
];

fig = figure('Color', 'w', 'Position', [120, 120, 1120, 680]);
tiledlayout(fig, 2, 2, 'Padding', 'compact', 'TileSpacing', 'compact');

if any(strcmp('scheme_desc', tbl.Properties.VariableNames))
    display_labels = wrap_labels(tbl.scheme_desc);
else
    display_labels = wrap_labels(tbl.scheme);
end

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
    xticklabels(ax, display_labels);
    xtickangle(ax, 0);
    xlabel(ax, 'Execution scenarios', 'FontName', 'Times New Roman', 'FontSize', 13);
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
