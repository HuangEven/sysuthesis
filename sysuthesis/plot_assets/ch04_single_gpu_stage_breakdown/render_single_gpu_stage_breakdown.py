from pathlib import Path

import matplotlib.pyplot as plt
import numpy as np
import pandas as pd


ROOT = Path(__file__).resolve().parent
plt.rcParams["font.sans-serif"] = ["Songti SC", "Arial Unicode MS", "Hiragino Sans GB"]
plt.rcParams["axes.unicode_minus"] = False
STAGES = ["query_prep", "ann_recall", "pack_candidates", "pytod_score", "output"]
COLORS = ["#4A6FA5", "#E98A15", "#C0504D", "#6FA852", "#8064A2"]
DATASETS = [
    (
        ROOT / "single_gpu_stage_breakdown_1m.csv",
        ROOT / "fig4_14_single_gpu_stage_breakdown_1m.png",
        "1M 数据规模下单卡各阶段耗时分解",
    ),
    (
        ROOT / "single_gpu_stage_breakdown_10m.csv",
        ROOT / "fig4_15_single_gpu_stage_breakdown_10m.png",
        "10M 数据规模下单卡各阶段耗时分解",
    ),
]


def render(csv_path: Path, out_path: Path, title: str) -> None:
    df = pd.read_csv(csv_path)
    x = np.arange(len(df))
    width = 0.66

    fig, ax = plt.subplots(figsize=(10.2, 5.6), dpi=220)
    bottom = np.zeros(len(df))

    for stage, color in zip(STAGES, COLORS):
        ax.bar(
            x,
            df[stage].values,
            width,
            bottom=bottom,
            label=stage,
            color=color,
            edgecolor="none",
        )
        bottom += df[stage].values

    ax.set_axisbelow(True)
    ax.grid(axis="y", alpha=0.18)
    ax.spines["top"].set_visible(False)
    ax.spines["right"].set_visible(False)
    ax.set_xticks(x, df["scheme"].values)
    ax.tick_params(axis="x", rotation=12)
    ax.set_ylabel("阶段耗时 / ms")
    ax.set_title(title, fontsize=15, fontweight="bold", pad=10)
    ax.legend(ncols=3, loc="upper center", bbox_to_anchor=(0.5, 1.20), frameon=False)

    totals = df["total_ms"].values
    for idx, total in enumerate(totals):
        ax.text(idx, total + totals.max() * 0.03, f"{total:.1f}", ha="center", va="bottom", fontsize=11, fontweight="bold")

    ax.text(
        0.35,
        df.loc[0, "query_prep"] + df.loc[0, "ann_recall"] + df.loc[0, "pack_candidates"] * 0.58,
        "pack_candidates 开销最高",
        color="#7A2626",
        fontsize=11.5,
        fontweight="bold",
    )
    ax.text(
        0.05,
        totals[0] - df.loc[0, "output"] * 0.45,
        "CPU-GPU 边界回传更重",
        color="#994F1B",
        fontsize=10.5,
    )
    ax.set_ylim(0, totals.max() * 1.18)

    fig.tight_layout(rect=(0, 0, 1, 0.92))
    fig.savefig(out_path, bbox_inches="tight")
    plt.close(fig)


if __name__ == "__main__":
    for csv_path, out_path, title in DATASETS:
        render(csv_path, out_path, title)
