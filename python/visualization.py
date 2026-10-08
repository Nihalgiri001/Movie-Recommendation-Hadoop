"""
============================================================
Big Data Movie Recommender - Visualization
============================================================
Generates visualizations from movie analytics data.

All charts are generated from actual data, never fabricated.

Usage:
    python3 python/visualization.py

Output:
    output/genre_distribution.png
    output/movies_per_year.png
    output/avg_rating_by_genre.png
    output/popularity_distribution.png
    output/top_rated_movies.png
    output/rating_distribution.png

Prerequisites:
    Run preprocessing first: python3 python/preprocessing.py
============================================================
"""

import os
import sys
import pandas as pd
import numpy as np
import matplotlib
matplotlib.use("Agg")  # Non-interactive backend for server/VM use
import matplotlib.pyplot as plt
import seaborn as sns

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from python.utils import (
    get_processed_dir,
    get_output_dir,
    print_separator,
    print_info,
    print_success,
    print_error,
)


# Set style
sns.set_theme(style="whitegrid")
plt.rcParams["figure.figsize"] = (12, 6)
plt.rcParams["figure.dpi"] = 150


def load_data():
    """Load preprocessed data for visualization."""
    processed_dir = get_processed_dir()

    movies_path = os.path.join(processed_dir, "movies.tsv")
    genres_path = os.path.join(processed_dir, "movie_genres.tsv")

    if not os.path.isfile(movies_path) or not os.path.isfile(genres_path):
        print_error(
            "Processed data not found. Please run preprocessing first:\n"
            "  python3 python/preprocessing.py"
        )
        sys.exit(1)

    movies_df = pd.read_csv(movies_path, sep="\t")
    genres_df = pd.read_csv(genres_path, sep="\t")

    return movies_df, genres_df


def plot_genre_distribution(genres_df, output_dir):
    """
    Chart 1: Movie Count by Genre (Bar Chart)
    Shows the distribution of movies across different genres.
    """
    print_info("Generating genre distribution chart...")

    genre_counts = genres_df["genre"].value_counts().head(20)

    fig, ax = plt.subplots(figsize=(14, 7))
    colors = sns.color_palette("viridis", len(genre_counts))
    bars = ax.barh(genre_counts.index[::-1], genre_counts.values[::-1], color=colors[::-1])

    ax.set_xlabel("Number of Movies", fontsize=12)
    ax.set_ylabel("Genre", fontsize=12)
    ax.set_title("Movie Count by Genre (TMDB 5000 Dataset)", fontsize=14, fontweight="bold")

    # Add count labels
    for bar, count in zip(bars, genre_counts.values[::-1]):
        ax.text(bar.get_width() + 5, bar.get_y() + bar.get_height() / 2,
                str(count), va="center", fontsize=9)

    plt.tight_layout()
    path = os.path.join(output_dir, "genre_distribution.png")
    plt.savefig(path, bbox_inches="tight")
    plt.close()
    print_success(f"Saved: {path}")


def plot_movies_per_year(movies_df, output_dir):
    """
    Chart 2: Movies Released Per Year (Line Chart)
    Shows the trend of movie releases over time.
    """
    print_info("Generating movies per year chart...")

    df = movies_df[movies_df["release_year"].notna()].copy()
    df["release_year"] = pd.to_numeric(df["release_year"], errors="coerce")
    df = df[df["release_year"] > 1900]

    year_counts = df["release_year"].value_counts().sort_index()

    fig, ax = plt.subplots(figsize=(14, 6))
    ax.fill_between(year_counts.index, year_counts.values, alpha=0.3, color="steelblue")
    ax.plot(year_counts.index, year_counts.values, color="steelblue", linewidth=2)

    ax.set_xlabel("Year", fontsize=12)
    ax.set_ylabel("Number of Movies", fontsize=12)
    ax.set_title("Movies Released Per Year (TMDB 5000 Dataset)", fontsize=14, fontweight="bold")

    plt.tight_layout()
    path = os.path.join(output_dir, "movies_per_year.png")
    plt.savefig(path, bbox_inches="tight")
    plt.close()
    print_success(f"Saved: {path}")


def plot_avg_rating_by_genre(movies_df, genres_df, output_dir):
    """
    Chart 3: Average Rating by Genre (Bar Chart)
    Shows which genres have the highest average ratings.
    """
    print_info("Generating average rating by genre chart...")

    merged = pd.merge(genres_df, movies_df[["movie_id", "vote_average"]], on="movie_id")
    avg_by_genre = merged.groupby("genre")["vote_average"].mean().sort_values(ascending=True)

    fig, ax = plt.subplots(figsize=(12, 7))
    colors = sns.color_palette("coolwarm", len(avg_by_genre))
    bars = ax.barh(avg_by_genre.index, avg_by_genre.values, color=colors)

    ax.set_xlabel("Average Rating", fontsize=12)
    ax.set_ylabel("Genre", fontsize=12)
    ax.set_title("Average Movie Rating by Genre", fontsize=14, fontweight="bold")

    for bar, val in zip(bars, avg_by_genre.values):
        ax.text(bar.get_width() + 0.02, bar.get_y() + bar.get_height() / 2,
                f"{val:.2f}", va="center", fontsize=9)

    plt.tight_layout()
    path = os.path.join(output_dir, "avg_rating_by_genre.png")
    plt.savefig(path, bbox_inches="tight")
    plt.close()
    print_success(f"Saved: {path}")


def plot_popularity_distribution(movies_df, output_dir):
    """
    Chart 4: Popularity Distribution (Histogram)
    Shows the distribution of movie popularity scores.
    """
    print_info("Generating popularity distribution chart...")

    fig, ax = plt.subplots(figsize=(12, 6))

    # Cap extreme outliers for better visualization
    popularity = movies_df["popularity"].dropna()
    cap = popularity.quantile(0.95)
    popularity_capped = popularity[popularity <= cap]

    ax.hist(popularity_capped, bins=50, color="coral", edgecolor="white", alpha=0.8)

    ax.set_xlabel("Popularity Score", fontsize=12)
    ax.set_ylabel("Number of Movies", fontsize=12)
    ax.set_title("Movie Popularity Distribution (95th percentile)", fontsize=14, fontweight="bold")

    plt.tight_layout()
    path = os.path.join(output_dir, "popularity_distribution.png")
    plt.savefig(path, bbox_inches="tight")
    plt.close()
    print_success(f"Saved: {path}")


def plot_top_rated_movies(movies_df, output_dir):
    """
    Chart 5: Top Rated Movies (Horizontal Bar Chart)
    Shows the highest-rated movies with minimum vote threshold.
    """
    print_info("Generating top rated movies chart...")

    # Filter movies with at least 100 votes for meaningful ratings
    df = movies_df[movies_df["vote_count"] >= 100].copy()
    top = df.nlargest(20, "vote_average")

    fig, ax = plt.subplots(figsize=(14, 8))
    colors = sns.color_palette("YlOrRd_r", len(top))
    bars = ax.barh(
        range(len(top)),
        top["vote_average"].values,
        color=colors,
    )

    ax.set_yticks(range(len(top)))
    ax.set_yticklabels([t[:40] for t in top["title"].values], fontsize=9)
    ax.set_xlabel("Vote Average", fontsize=12)
    ax.set_title("Top 20 Rated Movies (min. 100 votes)", fontsize=14, fontweight="bold")
    ax.invert_yaxis()

    for bar, val in zip(bars, top["vote_average"].values):
        ax.text(bar.get_width() + 0.05, bar.get_y() + bar.get_height() / 2,
                f"{val:.1f}", va="center", fontsize=9)

    plt.tight_layout()
    path = os.path.join(output_dir, "top_rated_movies.png")
    plt.savefig(path, bbox_inches="tight")
    plt.close()
    print_success(f"Saved: {path}")


def plot_rating_distribution(movies_df, output_dir):
    """
    Chart 6: Rating Distribution (Histogram + KDE)
    Shows how movie ratings are distributed.
    """
    print_info("Generating rating distribution chart...")

    fig, ax = plt.subplots(figsize=(12, 6))

    ratings = movies_df[movies_df["vote_average"] > 0]["vote_average"]
    ax.hist(ratings, bins=30, color="mediumpurple", edgecolor="white",
            alpha=0.7, density=True, label="Distribution")

    # Add KDE
    try:
        ratings.plot.kde(ax=ax, color="darkviolet", linewidth=2, label="Density")
    except Exception:
        pass

    ax.set_xlabel("Rating", fontsize=12)
    ax.set_ylabel("Density", fontsize=12)
    ax.set_title("Movie Rating Distribution", fontsize=14, fontweight="bold")
    ax.legend()

    plt.tight_layout()
    path = os.path.join(output_dir, "rating_distribution.png")
    plt.savefig(path, bbox_inches="tight")
    plt.close()
    print_success(f"Saved: {path}")


def main():
    """Generate all visualizations."""
    print_separator("Big Data Movie Recommender - Visualization")

    movies_df, genres_df = load_data()
    output_dir = get_output_dir()

    print_info(f"Generating charts from {len(movies_df)} movies...")
    print_info(f"Output directory: {output_dir}")
    print()

    plot_genre_distribution(genres_df, output_dir)
    plot_movies_per_year(movies_df, output_dir)
    plot_avg_rating_by_genre(movies_df, genres_df, output_dir)
    plot_popularity_distribution(movies_df, output_dir)
    plot_top_rated_movies(movies_df, output_dir)
    plot_rating_distribution(movies_df, output_dir)

    print_separator("Visualization Complete")
    print(f"  All charts saved to: {output_dir}")
    print(f"  Charts generated: 6")
    print()


if __name__ == "__main__":
    main()
