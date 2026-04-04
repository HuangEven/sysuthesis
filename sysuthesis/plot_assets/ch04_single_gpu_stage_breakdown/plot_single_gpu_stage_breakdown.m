function plot_single_gpu_stage_breakdown()
% 绘制图4-14与图4-15：单卡各阶段耗时分解图（1M / 10M）

root_dir = fileparts(mfilename('fullpath'));
datasets = {
    'single_gpu_stage_breakdown_1m.csv', ...
    'fig4_14_single_gpu_stage_breakdown_1m.png', ...
    '1M 数据规模下单卡各阶段耗时分解' ; ...
    'single_gpu_stage_breakdown_10m.csv', ...
    'fig4_15_single_gpu_stage_breakdown_10m.png', ...
    '10M 数据规模下单卡各阶段耗时分解'
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
    fig_title = datasets{idx, 3};

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
    title(ax, fig_title, 'FontName', 'Songti SC', 'FontSize', 15, 'FontWeight', 'bold');
    legend(ax, stage_labels, 'Location', 'northoutside', 'Orientation', 'horizontal', 'NumColumns', 3);

    totals = sum(values, 2);
    for i = 1:numel(totals)
        text(i, totals(i) + max(totals) * 0.03, sprintf('%.1f', totals(i)), ...
            'HorizontalAlignment', 'center', 'FontName', 'Times New Roman', ...
            'FontSize', 12, 'FontWeight', 'bold');
    end

    text(1.05, values(1, 1) + values(1, 2) + values(1, 3) / 2, ...
        '\leftarrow pack\_candidates 开销最高', ...
        'Color', [0.55, 0.16, 0.16], 'FontName', 'Songti SC', 'FontSize', 12, ...
        'FontWeight', 'bold');

    text(1.02, totals(1) - values(1, 5) / 2, ...
        'CPU\leftrightarrowGPU 边界回传更重', ...
        'Color', [0.60, 0.24, 0.12], 'FontName', 'Songti SC', 'FontSize', 11);

    ylim(ax, [0, max(totals) * 1.18]);
    exportgraphics(fig, out_path, 'Resolution', 220);
    close(fig);
end
