from pathlib import Path

import matplotlib.pyplot as plt
import pandas as pd


ROOT = Path(__file__).resolve().parent
CSV_PATH = ROOT / "scale_trends.csv"
OUT_PATH = ROOT / "fig6_8_scale_trends.png"

plt.rcParams["font.family"] = "Times New Roman"
plt.rcParams["axes.unicode_minus"] = False


def style_axes(ax: plt.Axes) -> None:
    ax.set_axisbelow(True)
    ax.grid(axis="y", linestyle="--", linewidth=0.7, color="#B8B8B8", alpha=0.45)
    ax.spines["top"].set_visible(False)
    ax.spines["right"].set_visible(False)
    ax.tick_params(direction="out", width=1.0, labelsize=12)


def metric_offset(metric: str) -> float:
    if metric == "qps":
        return 100
    if metric == "p99_latency_ms":
        return 2.0
    return 0.00045


def metric_format(metric: str) -> str:
    return "%.4f" if metric == "pr_auc" else "%.2f"


def main() -> None:
    df = pd.read_csv(CSV_PATH)
    scales = ["1M", "10M", "50M", "100M"]
    metrics = [
        ("qps", "QPS", (0, 4700)),
        ("p99_latency_ms", "Latency (ms)", (0, 140)),
        ("pr_auc", "PR-AUC", (0.885, 0.935)),
    ]
    line_styles = ["-", "--"]
    markers = ["o", "s"]

    fig, axes = plt.subplots(1, 3, figsize=(10.8, 4.2), dpi=220)

    for ax, (metric, ylabel, ylim) in zip(axes, metrics):
        label_column = "scheme_desc" if "scheme_desc" in df.columns else "scheme"
        for idx, (scheme, subset) in enumerate(df.groupby(label_column, sort=False)):
            subset = subset.reset_index(drop=True)
            ax.plot(
                range(len(subset)),
                subset[metric],
                color="black",
                linestyle=line_styles[idx],
                linewidth=1.5,
                marker=markers[idx],
                markersize=6.6,
                markerfacecolor="white",
                label=str(scheme),
            )
            for x, value in enumerate(subset[metric]):
                ax.text(x, value + metric_offset(metric), metric_format(metric) % value, ha="center", va="bottom", fontsize=9.2)

        ax.set_xticks(range(len(scales)), scales)
        ax.set_xlabel("Data Scale", fontsize=13)
        ax.set_ylabel(ylabel, fontsize=13)
        ax.set_ylim(*ylim)
        ax.legend(loc="best", frameon=False, fontsize=10.4)
        style_axes(ax)

    fig.tight_layout()
    fig.savefig(OUT_PATH, bbox_inches="tight")
    plt.close(fig)


if __name__ == "__main__":
    main()
