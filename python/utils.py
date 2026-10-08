"""
============================================================
Big Data Movie Recommender - Utility Functions
============================================================
Common utility functions used across the project.
============================================================
"""

import os
import sys


def get_project_root():
    """
    Determine the project root directory dynamically.
    Works regardless of where the script is called from.

    Returns:
        str: Absolute path to the project root directory.
    """
    # This file lives in <project_root>/python/
    current_dir = os.path.dirname(os.path.abspath(__file__))
    project_root = os.path.dirname(current_dir)
    return project_root


def get_data_dir():
    """Get the path to the data directory."""
    return os.path.join(get_project_root(), "data")


def get_processed_dir():
    """Get the path to the processed data directory."""
    processed_dir = os.path.join(get_data_dir(), "processed")
    os.makedirs(processed_dir, exist_ok=True)
    return processed_dir


def get_output_dir():
    """Get the path to the output directory."""
    output_dir = os.path.join(get_project_root(), "output")
    os.makedirs(output_dir, exist_ok=True)
    return output_dir


def get_models_dir():
    """Get the path to the models directory."""
    models_dir = os.path.join(get_project_root(), "models")
    os.makedirs(models_dir, exist_ok=True)
    return models_dir


def check_dataset_exists():
    """
    Verify that the required TMDB dataset files exist.

    Returns:
        tuple: (movies_path, credits_path) if both files exist.

    Raises:
        FileNotFoundError: If either dataset file is missing.
    """
    data_dir = get_data_dir()
    movies_path = os.path.join(data_dir, "tmdb_5000_movies.csv")
    credits_path = os.path.join(data_dir, "tmdb_5000_credits.csv")

    missing = []
    if not os.path.isfile(movies_path):
        missing.append("tmdb_5000_movies.csv")
    if not os.path.isfile(credits_path):
        missing.append("tmdb_5000_credits.csv")

    if missing:
        raise FileNotFoundError(
            f"TMDB dataset not found. Please place the following files in "
            f"'{data_dir}':\n"
            + "\n".join(f"  - {f}" for f in missing)
            + "\n\nDownload from: https://www.kaggle.com/datasets/tmdb/tmdb-movie-metadata"
        )

    return movies_path, credits_path


def check_models_exist():
    """
    Check that trained model artifacts exist.

    Returns:
        dict: Paths to model files.

    Raises:
        FileNotFoundError: If required model artifacts are missing.
    """
    models_dir = get_models_dir()
    required_models = {
        "tfidf_vectorizer": os.path.join(models_dir, "tfidf_vectorizer.pkl"),
        "cosine_similarity": os.path.join(models_dir, "cosine_similarity.pkl"),
        "knn_model": os.path.join(models_dir, "knn_model.pkl"),
        "processed_movies": os.path.join(models_dir, "processed_movies.pkl"),
    }

    missing = []
    for name, path in required_models.items():
        if not os.path.isfile(path):
            missing.append(name)

    if missing:
        raise FileNotFoundError(
            "Recommendation model has not been trained. "
            "Run the manual training command first:\n\n"
            "  python3 python/train_recommender.py\n\n"
            f"Missing model artifacts: {', '.join(missing)}"
        )

    return required_models


def print_separator(title="", char="=", width=60):
    """Print a formatted separator line."""
    if title:
        print(f"\n{char * width}")
        print(f"  {title}")
        print(f"{char * width}")
    else:
        print(char * width)


def print_info(message):
    """Print an info message."""
    print(f"[INFO] {message}")


def print_success(message):
    """Print a success message."""
    print(f"[OK]   {message}")


def print_error(message):
    """Print an error message."""
    print(f"[ERR]  {message}", file=sys.stderr)


def print_warning(message):
    """Print a warning message."""
    print(f"[WARN] {message}")
