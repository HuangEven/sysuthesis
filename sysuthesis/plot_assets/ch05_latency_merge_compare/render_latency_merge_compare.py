from pathlib import Path

import matplotlib.pyplot as plt
import numpy as np
import pandas as pd


ROOT = Path(__file__).resolve().parent
CSV_PATH = ROOT / "latency_merge_compare.csv"
OUT_PATH = ROOT / "fig5_16_latency_merge_compare.png"

plt.rcParams["font.family"] = "Times New Roman"
plt.rcParams["axes.unicode_minus"] = False


def main() -> None:
    df = pd.read_csv(CSV_PATH)
    plot_values = df[["avg_latency_ms", "p99_latency_ms"]].to_numpy(dtype=float)

    x = np.arange(len(df))
    width = 0.32

    fig, ax = plt.subplots(figsize=(9.0, 5.2), dpi=220)
    bars_avg = ax.bar(
        x - width / 2,
        plot_values[:, 0],
        width,
        label="Average",
        color="white",
        edgecolor="black",
        linewidth=1.2,
    )
    bars_p99 = ax.bar(
        x + width / 2,
        plot_values[:, 1],
        width,
        label="p99",
        color="#D1D1D1",
        edgecolor="black",
        linewidth=1.2,
    )

    ax.set_xticks(x, df["scheme"])
    ax.set_ylim(0, 32)
    ax.set_xlabel("Schemes", fontsize=13)
    ax.set_ylabel("Latency (ms)", fontsize=13)
    ax.set_axisbelow(True)
    ax.grid(axis="y", linestyle="--", linewidth=0.7, color="#B8B8B8", alpha=0.45)
    ax.spines["top"].set_visible(False)
    ax.spines["right"].set_visible(False)
    ax.tick_params(direction="out", width=1.0, labelsize=12)
    ax.legend(loc="upper left", frameon=False, fontsize=11)

    for bars in (bars_avg, bars_p99):
        for rect in bars:
            height = rect.get_height()
            ax.text(
                rect.get_x() + rect.get_width() / 2,
                height + 0.55,
                f"{height:.2f}",
                ha="center",
                va="bottom",
                fontsize=9.8,
            )

    fig.tight_layout()
    fig.savefig(OUT_PATH, bbox_inches="tight")
    plt.close(fig)


if __name__ == "__main__":
    main()
