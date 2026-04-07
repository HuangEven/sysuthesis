from pathlib import Path
from textwrap import fill

import matplotlib.pyplot as plt
import pandas as pd


ROOT = Path(__file__).resolve().parent
CSV_PATH = ROOT / "single_multi_benefit_summary.csv"
OUT_PATH = ROOT / "fig6_7_single_multi_summary.png"

plt.rcParams["font.family"] = "Times New Roman"
plt.rcParams["axes.unicode_minus"] = False


def scenario_labels(df: pd.DataFrame) -> list[str]:
    labels = []
    for value in df["scheme"].tolist():
        mapping = {
            "Original baseline": "Original\npipeline",
            "Single-GPU optimized": "Single-GPU\noptimized",
            "2-GPU replicated": "2-GPU\nreplicated",
            "4-GPU replicated": "4-GPU\nreplicated",
        }
        labels.append(mapping.get(str(value), fill(str(value), width=14, break_long_words=False)))
    return labels


def style_axes(ax: plt.Axes) -> None:
    ax.set_axisbelow(True)
    ax.grid(axis="y", linestyle="--", linewidth=0.7, color="#B8B8B8", alpha=0.45)
    ax.spines["top"].set_visible(False)
    ax.spines["right"].set_visible(False)
    ax.tick_params(direction="out", width=1.0, labelsize=12)


def main() -> None:
    df = pd.read_csv(CSV_PATH)
    labels = scenario_labels(df)
    metrics = [
        ("qps", "QPS", (0, 15000), 220, "white"),
        ("p99_latency_ms", "Latency (ms)", (0, 75), 1.0, "#D1D1D1"),
        ("cpu_util", "CPU Utilization (%)", (0, 70), 0.9, "#A6A6A6"),
    ]

    fig, axes = plt.subplots(1, 3, figsize=(11.4, 4.6), dpi=220)

    for ax, (column, ylabel, ylim, offset, color) in zip(axes, metrics):
        bars = ax.bar(range(len(df)), df[column], color=color, edgecolor="black", linewidth=1.2)
        ax.set_xticks(range(len(df)), labels)
        ax.set_xlabel("Validation scenarios", fontsize=12.5)
        ax.set_ylabel(ylabel, fontsize=13)
        ax.set_ylim(*ylim)
        style_axes(ax)
        ax.tick_params(axis="x", labelsize=11.2)
        for rect, value in zip(bars, df[column]):
            ax.text(rect.get_x() + rect.get_width() / 2, value + offset, f"{value:.2f}", ha="center", va="bottom", fontsize=9.4)

    fig.tight_layout()
    fig.savefig(OUT_PATH, bbox_inches="tight")
    plt.close(fig)


if __name__ == "__main__":
    main()
