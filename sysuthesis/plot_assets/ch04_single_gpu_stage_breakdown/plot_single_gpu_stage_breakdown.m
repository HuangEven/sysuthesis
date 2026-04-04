function plot_single_gpu_stage_breakdown()
% 绘制图4-14与图4-15：单卡各阶段耗时分解图（1M / 10M）

root_dir = fileparts(mfilename('fullpath'));
datasets = {
    'single_gpu_stage_breakdown_1m.csv', ...
    'fig4_14_single_gpu_stage_breakdown_1m.png' ; ...
    'single_gpu_stage_breakdown_10m.csv', ...
    'fig4_15_single_gpu_stage_breakdown_10m.png'
};

stage_fields = {'query_prep', 'ann_recall', 'pack_candidates', 'pytod_score', 'output'};
stage_labels = {'query\_prep', 'ann\_recall', 'pack\_candidates', 'pytod\_score', 'output'};
colors = [
    1.00, 1.00, 1.00;
    0.86, 0.86, 0.86;
    0.72, 0.72, 0.72;
    0.58, 0.58, 0.58;
    0.38, 0.38, 0.38
];

for idx = 1:size(datasets, 1)
    csv_path = fullfile(root_dir, datasets{idx, 1});
    out_path = fullfile(root_dir, datasets{idx, 2});

    tbl = readtable(csv_path, 'TextType', 'string');
    values = tbl{:, stage_fields};

    fig = figure('Color', 'w', 'Position', [100, 100, 980, 520]);
    ax = axes(fig);
    hb = bar(ax, values, 'stacked', 'BarWidth', 0.66);
    hold(ax, 'on');

    for s = 1:numel(hb)
        hb(s).FaceColor = colors(s, :);
        hb(s).EdgeColor = 'k';
        hb(s).LineWidth = 0.8;
    end

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
    ylabel(ax, 'Latency (ms)', 'FontName', 'Times New Roman', 'FontSize', 13);
    legend(ax, stage_labels, ...
        'Location', 'northoutside', ...
        'Orientation', 'horizontal', ...
        'NumColumns', 3, ...
        'Box', 'off', ...
        'FontName', 'Times New Roman', ...
        'FontSize', 10.5);

    totals = tbl.latency_ms;
    for i = 1:numel(totals)
        text(i, totals(i) + max(totals) * 0.03, sprintf('%.2f', totals(i)), ...
            'HorizontalAlignment', 'center', 'FontName', 'Times New Roman', ...
            'FontSize', 10.8, 'FontWeight', 'normal');
    end

    ylim(ax, [0, max(totals) * 1.18]);
    exportgraphics(fig, out_path, 'Resolution', 220);
    close(fig);
end
