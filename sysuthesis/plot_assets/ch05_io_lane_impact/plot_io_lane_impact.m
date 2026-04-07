function plot_io_lane_impact()
% 绘制图5-18：合理/冲突 I/O 绑定对扩展性影响图

root_dir = fileparts(mfilename('fullpath'));
csv_path = fullfile(root_dir, 'io_lane_impact.csv');
out_path = fullfile(root_dir, 'fig5_18_io_lane_impact.png');

tbl = readtable(csv_path, 'TextType', 'string');
gpu_groups = unique(tbl.gpu_count, 'stable');
if any(strcmp('scheme_desc', tbl.Properties.VariableNames))
    schemes = unique(tbl.scheme_desc, 'stable');
    scheme_field = "scheme_desc";
else
    schemes = unique(tbl.scheme, 'stable');
    scheme_field = "scheme";
end

qps_values = zeros(numel(gpu_groups), numel(schemes));
p99_values = zeros(numel(gpu_groups), numel(schemes));

for i = 1:numel(gpu_groups)
    for j = 1:numel(schemes)
        mask = tbl.gpu_count == gpu_groups(i) & tbl.(scheme_field) == schemes(j);
        qps_values(i, j) = tbl.qps(mask);
        p99_values(i, j) = tbl.p99_ms(mask);
    end
end

fig = figure('Color', 'w', 'Position', [120, 120, 1040, 500]);
tiledlayout(fig, 1, 2, 'Padding', 'compact', 'TileSpacing', 'compact');

labels = compose('%d GPU', gpu_groups);
legend_labels = cellstr(schemes);

nexttile;
ax1 = gca;
hb1 = bar(ax1, qps_values, 'grouped', 'BarWidth', 0.72);
style_bar_group(hb1);
apply_axis_style(ax1);
set(ax1, 'XTickLabel', labels);
ylabel(ax1, 'QPS', 'FontName', 'Times New Roman', 'FontSize', 13);
xlabel(ax1, 'GPU Configuration', 'FontName', 'Times New Roman', 'FontSize', 13);
legend(ax1, legend_labels, 'Location', 'northwest', 'Box', 'off', 'FontName', 'Times New Roman');
ylim(ax1, [0, 52000]);
annotate_bars(ax1, hb1, qps_values, 220);

nexttile;
ax2 = gca;
hb2 = bar(ax2, p99_values, 'grouped', 'BarWidth', 0.72);
style_bar_group(hb2);
apply_axis_style(ax2);
set(ax2, 'XTickLabel', labels);
ylabel(ax2, 'Latency (ms)', 'FontName', 'Times New Roman', 'FontSize', 13);
xlabel(ax2, 'GPU Configuration', 'FontName', 'Times New Roman', 'FontSize', 13);
legend(ax2, legend_labels, 'Location', 'northwest', 'Box', 'off', 'FontName', 'Times New Roman');
ylim(ax2, [0, 60]);
annotate_bars(ax2, hb2, p99_values, 0.95);

exportgraphics(fig, out_path, 'Resolution', 220);
close(fig);
end

function style_bar_group(hb)
hb(1).FaceColor = [1, 1, 1];
hb(1).EdgeColor = [0, 0, 0];
hb(1).LineWidth = 1.2;

hb(2).FaceColor = [0.82, 0.82, 0.82];
hb(2).EdgeColor = [0, 0, 0];
hb(2).LineWidth = 1.2;
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

function annotate_bars(ax, hb, values, offset)
for i = 1:numel(hb)
    x_points = hb(i).XEndPoints;
    y_points = hb(i).YEndPoints;
    for j = 1:numel(x_points)
        text(ax, x_points(j), y_points(j) + offset, sprintf('%.2f', values(j, i)), ...
            'HorizontalAlignment', 'center', ...
            'VerticalAlignment', 'bottom', ...
            'FontName', 'Times New Roman', ...
            'FontSize', 9.8);
    end
end
end
