from pathlib import Path

import matplotlib.pyplot as plt
import numpy as np
import pandas as pd


ROOT = Path(__file__).resolve().parent
plt.rcParams["font.family"] = "Times New Roman"
plt.rcParams["axes.unicode_minus"] = False
STAGES = ["query_prep", "ann_recall", "pack_candidates", "pytod_score", "output"]
COLORS = ["#FFFFFF", "#DBDBDB", "#B9B9B9", "#949494", "#666666"]
HATCHES = ["", "//", "\\\\", "xx", ".."]
DATASETS = [
    (
        ROOT / "single_gpu_stage_breakdown_1m.csv",
        ROOT / "fig4_14_single_gpu_stage_breakdown_1m.png",
    ),
    (
        ROOT / "single_gpu_stage_breakdown_10m.csv",
        ROOT / "fig4_15_single_gpu_stage_breakdown_10m.png",
    ),
]


def render(csv_path: Path, out_path: Path) -> None:
    df = pd.read_csv(csv_path)
    x = np.arange(len(df))
    width = 0.66

    fig, ax = plt.subplots(figsize=(10.2, 5.6), dpi=220)
    bottom = np.zeros(len(df))

    for stage, color, hatch in zip(STAGES, COLORS, HATCHES):
        bars = ax.bar(
            x,
            df[stage].values,
            width,
            bottom=bottom,
            label=stage,
            color=color,
            edgecolor="black",
            linewidth=0.8,
            hatch=hatch,
        )
        for rect in bars:
            rect.set_linewidth(0.8)
        bottom += df[stage].values

    ax.set_axisbelow(True)
    ax.grid(axis="y", linestyle="--", linewidth=0.7, color="#B8B8B8", alpha=0.45)
    ax.spines["top"].set_visible(False)
    ax.spines["right"].set_visible(False)
    ax.tick_params(direction="out", width=1.0, labelsize=12)
    ax.set_xticks(x, df["scheme"].values)
    ax.set_xlabel("Schemes", fontsize=13)
    ax.set_ylabel("Latency (ms)", fontsize=13)
    ax.legend(
        ncols=3,
        loc="upper center",
        bbox_to_anchor=(0.5, 1.14),
        frameon=False,
        fontsize=10.4,
    )

    totals = df["latency_ms"].values
    for idx, total in enumerate(totals):
        ax.text(idx, total + totals.max() * 0.03, f"{total:.2f}", ha="center", va="bottom", fontsize=10.2)

    ax.set_ylim(0, totals.max() * 1.18)

    fig.tight_layout(rect=(0, 0, 1, 0.95))
    fig.savefig(out_path, bbox_inches="tight")
    plt.close(fig)


if __name__ == "__main__":
    for csv_path, out_path in DATASETS:
        render(csv_path, out_path)
