function plot_scale_trends()
% 绘制图6-8：不同规模下系统表现趋势图

root_dir = fileparts(mfilename('fullpath'));
csv_path = fullfile(root_dir, 'scale_trends.csv');
out_path = fullfile(root_dir, 'fig6_8_scale_trends.png');

tbl = readtable(csv_path, 'TextType', 'string');
if any(strcmp('scheme_desc', tbl.Properties.VariableNames))
    schemes = unique(tbl.scheme_desc, 'stable');
    scheme_field = "scheme_desc";
else
    schemes = unique(tbl.scheme, 'stable');
    scheme_field = "scheme";
end
scale_labels = {'1M', '10M', '50M', '100M'};
metrics = {'qps', 'p99_latency_ms', 'pr_auc'};
ylabels = {'QPS', 'Latency (ms)', 'PR-AUC'};
y_lims = [0 10500; 0 115; 0.918 0.9345];
markers = {'o', 's'};
line_styles = {'-', '--'};

fig = figure('Color', 'w', 'Position', [120, 120, 1080, 420]);
tiledlayout(fig, 1, 3, 'Padding', 'compact', 'TileSpacing', 'compact');

for m = 1:numel(metrics)
    ax = nexttile;
    hold(ax, 'on');
    for s = 1:numel(schemes)
        subset = tbl(tbl.(scheme_field) == schemes(s), :);
        plot(ax, 1:height(subset), subset.(metrics{m}), ...
            'Color', 'k', ...
            'LineStyle', line_styles{s}, ...
            'LineWidth', 1.5, ...
            'Marker', markers{s}, ...
            'MarkerSize', 6.8, ...
            'MarkerFaceColor', 'w', ...
            'DisplayName', schemes{s});
        for j = 1:height(subset)
            offset = metric_offset(metrics{m});
            text(ax, j, subset.(metrics{m})(j) + offset, sprintf(metric_format(metrics{m}), subset.(metrics{m})(j)), ...
                'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom', ...
                'FontName', 'Times New Roman', 'FontSize', 9.3);
        end
    end
    apply_axis_style(ax);
    xticks(ax, 1:4);
    xticklabels(ax, scale_labels);
    xlabel(ax, 'Data Scale', 'FontName', 'Times New Roman', 'FontSize', 13);
    ylabel(ax, ylabels{m}, 'FontName', 'Times New Roman', 'FontSize', 13);
    ylim(ax, y_lims(m, :));
    legend(ax, 'Location', 'best', 'Box', 'off', 'FontName', 'Times New Roman');
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

function offset = metric_offset(metric)
switch metric
    case 'qps'
        offset = 220;
    case 'p99_latency_ms'
        offset = 2.4;
    otherwise
        offset = 0.00035;
end
end

function format_spec = metric_format(metric)
switch metric
    case 'qps'
        format_spec = '%.2f';
    case 'p99_latency_ms'
        format_spec = '%.2f';
    otherwise
        format_spec = '%.4f';
end
end
