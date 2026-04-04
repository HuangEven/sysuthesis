function plot_single_gpu_stage_breakdown()
% 绘制图4-14与图4-15：单卡各阶段耗时分解图（1M / 10M）

root_dir = fileparts(mfilename('fullpath'));
datasets = {
    'single_gpu_stage_breakdown_1m.csv', ...
    'fig4_14_single_gpu_stage_breakdown_1m.png' ; ...
    'single_gpu_stage_breakdown_10m.csv', ...
    'fig4_15_single_gpu_stage_breakdown_10m.png'
};

stage_labels = {'query\_prep', 'ann\_recall', 'pack\_candidates', 'pytod\_score', 'output'};
colors = [
    74, 111, 165;
    233, 138, 21;
    192, 80, 77;
    111, 168, 82;
    128, 100, 162
] / 255;

for idx = 1:size(datasets, 1)
    csv_path = fullfile(root_dir, datasets{idx, 1});
    out_path = fullfile(root_dir, datasets{idx, 2});

    tbl = readtable(csv_path, 'TextType', 'string');
    values = tbl{:, stage_labels};

    fig = figure('Color', 'w', 'Position', [100, 100, 980, 520]);
    ax = axes(fig);
    hb = bar(ax, values, 'stacked', 'BarWidth', 0.66);
    hold(ax, 'on');

    for s = 1:numel(hb)
        hb(s).FaceColor = colors(s, :);
        hb(s).EdgeColor = 'none';
    end

    ax.FontName = 'Times New Roman';
    ax.FontSize = 12;
    ax.Box = 'off';
    ax.LineWidth = 1.0;
    ax.YGrid = 'on';
    ax.GridAlpha = 0.18;
    ax.Layer = 'top';
    ax.TickDir = 'out';

    xticks(ax, 1:height(tbl));
    xticklabels(ax, tbl.scheme);
    xtickangle(ax, 12);
    ylabel(ax, '阶段耗时 / ms', 'FontName', 'Songti SC', 'FontSize', 13);
    legend(ax, stage_labels, 'Location', 'northoutside', 'Orientation', 'horizontal', 'NumColumns', 3, 'Box', 'off');

    totals = sum(values, 2);
    for i = 1:numel(totals)
        text(i, totals(i) + max(totals) * 0.03, sprintf('%.1f', totals(i)), ...
            'HorizontalAlignment', 'center', 'FontName', 'Times New Roman', ...
            'FontSize', 12, 'FontWeight', 'bold');
    end

    ylim(ax, [0, max(totals) * 1.18]);
    exportgraphics(fig, out_path, 'Resolution', 220);
    close(fig);
end
