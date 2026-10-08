"""
============================================================
Big Data Movie Recommender - Recommendation Application
============================================================
Command-line application for generating movie recommendations.

Usage:
    python3 python/recommendation_app.py --movie "Batman"
    python3 python/recommendation_app.py --movie "The Dark Knight" --n 5
    python3 python/recommendation_app.py --interactive

Prerequisites:
    1. Run preprocessing: python3 python/preprocessing.py
    2. Run training:      python3 python/train_recommender.py
============================================================
"""

import os
import sys
import argparse

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from python.tfidf_recommender import MovieRecommender
from python.utils import (
    print_separator,
    print_info,
    print_success,
    print_error,
)


def display_recommendations(results_df, input_movie):
    """
    Display recommendations in a formatted table.

    Args:
        results_df: DataFrame with recommendation results.
        input_movie: The matched input movie title.
    """
    print_separator(f"Recommendations for: {input_movie}")
    print()

    if results_df.empty:
        print("  No recommendations found.")
        return

    # Print header
    header = f"{'Rank':<6}{'Movie Title':<45}{'Similarity':<12}{'Rating':<8}{'Year':<6}"
    print(f"  {header}")
    print(f"  {'-' * len(header)}")

    # Print each recommendation
    for _, row in results_df.iterrows():
        title = str(row["title"])[:42]
        sim = f"{row['similarity_score']:.4f}"
        rating = f"{row['vote_average']:.1f}" if row.get("vote_average") else "N/A"
        year = str(row.get("release_year", ""))[:4]

        print(f"  {row['rank']:<6}{title:<45}{sim:<12}{rating:<8}{year:<6}")

    print()
    print(f"  Total recommendations: {len(results_df)}")
    print_separator()


def interactive_mode(recommender):
    """
    Run the recommender in interactive mode.

    Args:
        recommender: Loaded MovieRecommender instance.
    """
    print_separator("Interactive Movie Recommendation System")
    print("  Enter a movie title to get recommendations.")
    print("  Type 'quit' or 'exit' to stop.")
    print()

    while True:
        try:
            movie_title = input("  Enter movie title: ").strip()
        except (EOFError, KeyboardInterrupt):
            print("\n\n  Goodbye!")
            break

        if not movie_title:
            continue

        if movie_title.lower() in ("quit", "exit", "q"):
            print("\n  Goodbye!")
            break

        try:
            n = 10
            # Check if user specified count
            if " -n " in movie_title:
                parts = movie_title.split(" -n ")
                movie_title = parts[0].strip()
                try:
                    n = int(parts[1].strip())
                except ValueError:
                    pass

            results, matched_title = recommender.recommend(movie_title, n=n)
            display_recommendations(results, matched_title)
        except ValueError as e:
            print_error(str(e))
        except Exception as e:
            print_error(f"An error occurred: {e}")


def main():
    """Main entry point for the recommendation application."""
    parser = argparse.ArgumentParser(
        description="Big Data Movie Recommender - Get movie recommendations",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  python3 python/recommendation_app.py --movie "Batman"
  python3 python/recommendation_app.py --movie "The Dark Knight" --n 5
  python3 python/recommendation_app.py --interactive
        """,
    )

    parser.add_argument(
        "--movie", "-m",
        type=str,
        help="Movie title to get recommendations for",
    )
    parser.add_argument(
        "--n", "-n",
        type=int,
        default=10,
        help="Number of recommendations (default: 10)",
    )
    parser.add_argument(
        "--interactive", "-i",
        action="store_true",
        help="Run in interactive mode",
    )
    parser.add_argument(
        "--models-dir",
        type=str,
        default=None,
        help="Path to models directory (default: models/)",
    )

    args = parser.parse_args()

    # Load the recommender
    print_info("Loading recommendation models...")
    recommender = MovieRecommender()

    try:
        recommender.load_models(models_dir=args.models_dir)
    except FileNotFoundError as e:
        print_error(str(e))
        sys.exit(1)

    if args.interactive:
        interactive_mode(recommender)
    elif args.movie:
        try:
            results, matched_title = recommender.recommend(args.movie, n=args.n)
            display_recommendations(results, matched_title)
        except ValueError as e:
            print_error(str(e))
            sys.exit(1)
    else:
        parser.print_help()
        print()
        print_error("Please specify --movie <title> or --interactive")
        sys.exit(1)


if __name__ == "__main__":
    main()
