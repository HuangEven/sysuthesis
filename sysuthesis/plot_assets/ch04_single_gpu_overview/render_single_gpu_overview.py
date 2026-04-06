from pathlib import Path
from textwrap import fill

import matplotlib.pyplot as plt
import pandas as pd


ROOT = Path(__file__).resolve().parent
CSV_PATH = ROOT / "single_gpu_overview_metrics.csv"
OUT_PATH = ROOT / "fig4_16_single_gpu_overview.png"
plt.rcParams["font.family"] = "Times New Roman"
plt.rcParams["axes.unicode_minus"] = False

SCHEME_COLORS = ["#FFFFFF", "#D1D1D1", "#A8A8A8", "#6E6E6E"]


def wrapped_labels(values: pd.Series, width: int = 16) -> list[str]:
    return [fill(str(item), width=width, break_long_words=False) for item in values]


def style_axes(ax: plt.Axes) -> None:
    ax.set_axisbelow(True)
    ax.grid(axis="y", linestyle="--", linewidth=0.7, color="#B8B8B8", alpha=0.45)
    ax.spines["top"].set_visible(False)
    ax.spines["right"].set_visible(False)
    ax.tick_params(direction="out", width=1.0, labelsize=12)


def main() -> None:
    df = pd.read_csv(CSV_PATH)
    metrics = [
        ("qps", "QPS", (0, 7000), 120.0),
        ("p99_ms", "Latency (ms)", (0, 75), 1.6),
        ("pci_transfer_count", "PCIe Transfer Count", (0, 7.2), 0.16),
        ("gpu_util", "GPU Utilization (%)", (0, 95), 1.4),
    ]

    fig, axes = plt.subplots(2, 2, figsize=(11.2, 6.8), dpi=220)
    axes = axes.flatten()
    display = df["scheme_desc"] if "scheme_desc" in df.columns else df["scheme"]
    tick_labels = wrapped_labels(display)

    for ax, (column, ylabel, ylim, offset) in zip(axes, metrics):
        bars = ax.bar(
            range(len(df)),
            df[column].to_numpy(dtype=float),
            color=SCHEME_COLORS,
            edgecolor="black",
            linewidth=0.9,
            width=0.68,
        )
        ax.set_xticks(range(len(df)), tick_labels)
        ax.set_xlabel("Execution scenarios", fontsize=13)
        ax.set_ylabel(ylabel, fontsize=13)
        ax.set_ylim(*ylim)
        style_axes(ax)
        for rect, value in zip(bars, df[column].to_numpy(dtype=float)):
            ax.text(
                rect.get_x() + rect.get_width() / 2,
                value + offset,
                f"{value:.2f}",
                ha="center",
                va="bottom",
                fontsize=10.0,
            )

    fig.tight_layout()
    fig.savefig(OUT_PATH, bbox_inches="tight")
    plt.close(fig)


if __name__ == "__main__":
    main()
