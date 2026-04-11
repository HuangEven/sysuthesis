from pathlib import Path

import matplotlib.pyplot as plt
import pandas as pd
from matplotlib import font_manager, rcParams


ROOT = Path(__file__).resolve().parent
CSV_PATH = ROOT / "initial_effectiveness_metrics.csv"
OUT_PATH = ROOT.parent.parent / "figures" / "fig_3_12_initial_effectiveness_across_datasets.png"


def pick_cjk_font() -> str:
    preferred = [
        "Songti SC",
        "STSong",
        "PingFang SC",
        "SimSun",
        "SimHei",
        "Noto Sans CJK SC",
        "Microsoft YaHei",
    ]
    available = {f.name for f in font_manager.fontManager.ttflist}
    for name in preferred:
        if name in available:
            return name
    return "DejaVu Sans"


FONT = pick_cjk_font()
rcParams["font.family"] = FONT
rcParams["axes.unicode_minus"] = False


df = pd.read_csv(CSV_PATH)

fig, axes = plt.subplots(1, 3, figsize=(16.2, 6.0))
fig.subplots_adjust(top=0.80, wspace=0.24, left=0.06, right=0.99, bottom=0.16)

grouped_specs = [
    ("pr_auc", "各数据集上的PR-AUC", "PR-AUC"),
    ("recall_at_k", "各数据集上的Recall@K", "Recall@K"),
]

legend_handles = None

for ax, (metric, title, ylabel) in zip(axes[:2], grouped_specs):
    subset = df[df["metric"] == metric].copy()
    labels = subset["dataset"].tolist()
    x = range(len(labels))
    width = 0.38

    bars1 = ax.bar(
        [i - width / 2 for i in x],
        subset["fusion_system"],
        width=width,
        color="#7A8088",
        edgecolor="white",
        linewidth=1.2,
        label="融合系统",
        zorder=3,
    )
    bars2 = ax.bar(
        [i + width / 2 for i in x],
        subset["baseline_system"],
        width=width,
        color="#35597A",
        edgecolor="white",
        linewidth=1.2,
        label="基线系统",
        zorder=3,
    )
    legend_handles = (bars1[0], bars2[0])

    ax.set_title(title, fontsize=16, pad=10)
    ax.set_ylabel(ylabel, fontsize=15)
    ax.set_xlabel("数据集", fontsize=15)
    ax.set_xticks(list(x))
    ax.set_xticklabels(labels, fontsize=12)
    ax.set_ylim(0, 0.33)
    ax.grid(axis="y", linestyle="--", alpha=0.18, zorder=0)
    ax.spines["top"].set_visible(False)
    ax.spines["right"].set_visible(False)
    ax.spines["left"].set_color("#cccccc")
    ax.spines["bottom"].set_color("#cccccc")
    ax.tick_params(axis="y", labelsize=12, color="#cccccc")
    ax.tick_params(axis="x", length=0, pad=10)

    for bars in (bars1, bars2):
        for bar in bars:
            h = bar.get_height()
            ax.text(
                bar.get_x() + bar.get_width() / 2,
                h + 0.003,
                f"{h:.2f}",
                ha="center",
                va="bottom",
                fontsize=11.5,
            )

axes[2].clear()
subset = df[df["metric"] == "topk_overlap"].copy()
labels = subset["dataset"].tolist()
x = range(len(labels))
bars = axes[2].bar(
    list(x),
    subset["single_value"],
    width=0.78,
    color="#4A875F",
    edgecolor="white",
    linewidth=1.2,
    zorder=3,
)
axes[2].set_title("各数据集上的Top-K重合度", fontsize=16, pad=10)
axes[2].set_ylabel("Top-K重合度", fontsize=15)
axes[2].set_xlabel("数据集", fontsize=15)
axes[2].set_xticks(list(x))
axes[2].set_xticklabels(labels, fontsize=12)
axes[2].set_ylim(0, 1.05)
axes[2].grid(axis="y", linestyle="--", alpha=0.18, zorder=0)
axes[2].spines["top"].set_visible(False)
axes[2].spines["right"].set_visible(False)
axes[2].spines["left"].set_color("#cccccc")
axes[2].spines["bottom"].set_color("#cccccc")
axes[2].tick_params(axis="y", labelsize=12, color="#cccccc")
axes[2].tick_params(axis="x", length=0, pad=10)

for bar in bars:
    h = bar.get_height()
    axes[2].text(
        bar.get_x() + bar.get_width() / 2,
        h + 0.01,
        f"{h:.2f}",
        ha="center",
        va="bottom",
        fontsize=11.5,
    )

fig.legend(
    legend_handles,
    ["融合系统", "基线系统"],
    title="系统类型",
    loc="upper center",
    ncol=2,
    frameon=False,
    fontsize=13,
    title_fontsize=13,
    bbox_to_anchor=(0.34, 1.02),
)

plt.savefig(OUT_PATH, dpi=220, bbox_inches="tight")
plt.close(fig)
