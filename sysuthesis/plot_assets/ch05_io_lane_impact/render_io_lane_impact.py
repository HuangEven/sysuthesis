from pathlib import Path

import matplotlib.pyplot as plt
import numpy as np
import pandas as pd


ROOT = Path(__file__).resolve().parent
CSV_PATH = ROOT / "io_lane_impact.csv"
OUT_PATH = ROOT / "fig5_18_io_lane_impact.png"

plt.rcParams["font.family"] = "Times New Roman"
plt.rcParams["axes.unicode_minus"] = False


def build_matrix(df: pd.DataFrame, value_col: str) -> tuple[list[int], list[str], np.ndarray]:
    gpu_groups = list(dict.fromkeys(df["gpu_count"].tolist()))
    label_column = "scheme_desc" if "scheme_desc" in df.columns else "scheme"
    schemes = list(dict.fromkeys(df[label_column].tolist()))
    matrix = np.zeros((len(gpu_groups), len(schemes)))

    for i, gpu_count in enumerate(gpu_groups):
        for j, scheme in enumerate(schemes):
            row = df[(df["gpu_count"] == gpu_count) & (df[label_column] == scheme)].iloc[0]
            matrix[i, j] = float(row[value_col])

    return gpu_groups, schemes, matrix


def style_axes(ax: plt.Axes) -> None:
    ax.set_axisbelow(True)
    ax.grid(axis="y", linestyle="--", linewidth=0.7, color="#B8B8B8", alpha=0.45)
    ax.spines["top"].set_visible(False)
    ax.spines["right"].set_visible(False)
    ax.tick_params(direction="out", width=1.0, labelsize=12)


def main() -> None:
    df = pd.read_csv(CSV_PATH)
    gpu_groups, schemes, qps_values = build_matrix(df, "qps")
    _, _, p99_values = build_matrix(df, "p99_ms")

    x = np.arange(len(gpu_groups))
    width = 0.28

    fig, axes = plt.subplots(1, 2, figsize=(10.4, 5.0), dpi=220)
    colors = ["white", "#D1D1D1"]

    for ax, values, ylabel, ylim, offset in [
        (axes[0], qps_values, "QPS", (0, 52000), 650),
        (axes[1], p99_values, "Latency (ms)", (0, 48), 0.85),
    ]:
        for idx, scheme in enumerate(schemes):
            bars = ax.bar(
                x + (idx - 0.5) * width,
                values[:, idx],
                width,
                label=scheme,
                color=colors[idx],
                edgecolor="black",
                linewidth=1.2,
            )
            for rect in bars:
                height = rect.get_height()
                ax.text(
                    rect.get_x() + rect.get_width() / 2,
                    height + offset,
                    f"{height:.2f}",
                    ha="center",
                    va="bottom",
                    fontsize=9.5,
                )

        ax.set_xticks(x, [f"{v} GPU" for v in gpu_groups])
        ax.set_xlabel("GPU Configuration", fontsize=13)
        ax.set_ylabel(ylabel, fontsize=13)
        ax.set_ylim(*ylim)
        ax.legend(loc="upper left", frameon=False, fontsize=10.5)
        style_axes(ax)

    fig.tight_layout()
    fig.savefig(OUT_PATH, bbox_inches="tight")
    plt.close(fig)


if __name__ == "__main__":
    main()
