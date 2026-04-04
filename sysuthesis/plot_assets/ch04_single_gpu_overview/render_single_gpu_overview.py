from pathlib import Path

import matplotlib.pyplot as plt
import numpy as np
import pandas as pd


ROOT = Path(__file__).resolve().parent
CSV_PATH = ROOT / "single_gpu_overview_metrics.csv"
OUT_PATH = ROOT / "fig4_16_single_gpu_overview.png"
plt.rcParams["font.sans-serif"] = ["Songti SC", "Arial Unicode MS", "Hiragino Sans GB"]
plt.rcParams["axes.unicode_minus"] = False


def main() -> None:
    df = pd.read_csv(CSV_PATH)
    metrics = ["QPS↑", "p99延迟↓", "PCIe传输次数↓", "GPU利用率↑"]
    colors = ["#4A6FA5", "#E98A15", "#C0504D", "#6FA852"]

    raw = np.column_stack(
        [
            df["qps"].to_numpy(dtype=float),
            df["p99_latency_ms"].to_numpy(dtype=float),
            df["pcie_transfer_count"].to_numpy(dtype=float),
            df["gpu_utilization_pct"].to_numpy(dtype=float),
        ]
    )

    normalized = np.column_stack(
        [
            raw[:, 0] / raw[:, 0].max(),
            raw[:, 1].min() / raw[:, 1],
            raw[:, 2].min() / raw[:, 2],
            raw[:, 3] / raw[:, 3].max(),
        ]
    )

    values = normalized.T
    x = np.arange(len(metrics))
    width = 0.18

    fig, ax = plt.subplots(figsize=(10.4, 5.8), dpi=220)
    offsets = np.linspace(-1.5 * width, 1.5 * width, len(df))
    bars = []

    for idx, (scheme, color, offset) in enumerate(zip(df["scheme"], colors, offsets)):
        bar = ax.bar(x + offset, values[:, idx], width, label=scheme, color=color, edgecolor="none")
        bars.append(bar)

    ax.set_axisbelow(True)
    ax.grid(axis="y", alpha=0.16)
    ax.spines["top"].set_visible(False)
    ax.spines["right"].set_visible(False)
    ax.set_xticks(x, metrics)
    ax.set_ylim(0, 1.18)
    ax.set_ylabel("归一化性能得分（越高越好）")
    ax.legend(ncols=2, loc="upper center", bbox_to_anchor=(0.5, 1.14), frameon=False)

    raw_labels = np.column_stack(
        [
            [f"{v:.0f}" for v in raw[:, 0]],
            [f"{v:.0f} ms" for v in raw[:, 1]],
            [f"{v:.1f} 次" for v in raw[:, 2]],
            [f"{v:.0f}%" for v in raw[:, 3]],
        ]
    )

    for scheme_idx, bar_container in enumerate(bars):
        for metric_idx, rect in enumerate(bar_container):
            ax.text(
                rect.get_x() + rect.get_width() / 2,
                rect.get_height() + 0.03,
                raw_labels[scheme_idx, metric_idx],
                ha="center",
                va="bottom",
                rotation=90,
                fontsize=9.8,
            )

    fig.tight_layout(rect=(0, 0, 1, 0.95))
    fig.savefig(OUT_PATH, bbox_inches="tight")
    plt.close(fig)


if __name__ == "__main__":
    main()
