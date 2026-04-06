from pathlib import Path
from textwrap import fill

import matplotlib.pyplot as plt
import pandas as pd


ROOT = Path(__file__).resolve().parent
CSV_PATH = ROOT / "fusion_scheme_compare.csv"

plt.rcParams["font.family"] = "Times New Roman"
plt.rcParams["axes.unicode_minus"] = False


def wrapped_labels(values: pd.Series, width: int = 16) -> list[str]:
    return [fill(str(item), width=width, break_long_words=False) for item in values]


def apply_axis_style(ax: plt.Axes) -> None:
    ax.set_axisbelow(True)
    ax.grid(axis="y", linestyle="--", linewidth=0.7, color="#B8B8B8", alpha=0.45)
    ax.spines["top"].set_visible(False)
    ax.spines["right"].set_visible(False)
    ax.tick_params(direction="out", width=1.0, labelsize=12)


def render_accuracy(df: pd.DataFrame) -> None:
    display = df["scheme_desc"] if "scheme_desc" in df.columns else df["scheme"]
    labels = wrapped_labels(display)
    fig, ax = plt.subplots(figsize=(7.6, 5.0), dpi=220)
    bars = ax.bar(range(len(df)), df["pr_auc"], color="white", edgecolor="black", linewidth=1.2)
    ax.set_xticks(range(len(df)), labels)
    ax.set_xlabel("Validation scenarios", fontsize=13)
    ax.set_ylabel("PR-AUC", fontsize=13)
    ax.set_ylim(0.75, 0.96)
    apply_axis_style(ax)
    for rect, value in zip(bars, df["pr_auc"]):
        ax.text(rect.get_x() + rect.get_width() / 2, value + 0.006, f"{value:.4f}", ha="center", va="bottom", fontsize=9.6)
    fig.tight_layout()
    fig.savefig(ROOT / "fig6_4_fusion_accuracy.png", bbox_inches="tight")
    plt.close(fig)


def render_qps(df: pd.DataFrame) -> None:
    display = df["scheme_desc"] if "scheme_desc" in df.columns else df["scheme"]
    labels = wrapped_labels(display)
    fig, ax = plt.subplots(figsize=(7.6, 5.0), dpi=220)
    bars = ax.bar(range(len(df)), df["qps"], color="#D1D1D1", edgecolor="black", linewidth=1.2)
    ax.set_xticks(range(len(df)), labels)
    ax.set_xlabel("Validation scenarios", fontsize=13)
    ax.set_ylabel("QPS", fontsize=13)
    ax.set_ylim(0, 10800)
    apply_axis_style(ax)
    for rect, value in zip(bars, df["qps"]):
        ax.text(rect.get_x() + rect.get_width() / 2, value + 260, f"{value:.2f}", ha="center", va="bottom", fontsize=9.6)
    fig.tight_layout()
    fig.savefig(ROOT / "fig6_5_fusion_qps.png", bbox_inches="tight")
    plt.close(fig)


def render_tradeoff(df: pd.DataFrame) -> None:
    markers = ["o", "s", "^", "d"]
    line_styles = ["-", "--", "-.", ":"]
    fig, ax = plt.subplots(figsize=(7.8, 5.2), dpi=220)
    for idx, row in df.iterrows():
        ax.plot(
            [row["qps"]],
            [row["pr_auc"]],
            color="black",
            linestyle=line_styles[idx],
            marker=markers[idx],
            markersize=7.5,
            markerfacecolor="white",
            linewidth=1.4,
            label=row["scheme_desc"] if "scheme_desc" in df.columns else row["scheme"],
        )
        ax.text(row["qps"] + 120, row["pr_auc"] + 0.0012, f"{row['pr_auc']:.4f} / {row['qps']:.2f}", fontsize=9.2)
    ax.set_xlabel("QPS", fontsize=13)
    ax.set_ylabel("PR-AUC", fontsize=13)
    ax.set_xlim(1000, 10400)
    ax.set_ylim(0.79, 0.945)
    apply_axis_style(ax)
    ax.legend(loc="lower right", frameon=False, fontsize=10.5)
    fig.tight_layout()
    fig.savefig(ROOT / "fig6_6_fusion_tradeoff.png", bbox_inches="tight")
    plt.close(fig)


def main() -> None:
    df = pd.read_csv(CSV_PATH)
    render_accuracy(df)
    render_qps(df)
    render_tradeoff(df)


if __name__ == "__main__":
    main()
