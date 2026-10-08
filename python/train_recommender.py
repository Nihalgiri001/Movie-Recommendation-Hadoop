"""
============================================================
Big Data Movie Recommender - Model Training Script
============================================================
Trains the movie recommendation models.

THIS SCRIPT MUST BE RUN MANUALLY.
It is NOT executed automatically by project setup or tests.

Models trained:
1. TF-IDF Vectorizer (on combined movie tags)
2. Cosine Similarity matrix
3. KNN model (n_neighbors=5)
4. Auxiliary models (SVM, Decision Tree, Gradient Boosting)
   - These are EXPERIMENTAL classifiers for genre prediction
   - They do NOT directly contribute to movie recommendations
   - They are included for academic demonstration purposes

Primary recommendation mechanism:
    TF-IDF → Cosine Similarity → KNN support → Counter voting

Usage:
    python3 python/train_recommender.py

Input:
    data/processed/movie_tags.tsv (from preprocessing.py)
    data/processed/movies.tsv
    data/processed/movie_genres.tsv

Output:
    models/tfidf_vectorizer.pkl
    models/cosine_similarity.pkl
    models/knn_model.pkl
    models/tfidf_matrix.pkl
    models/processed_movies.pkl
    models/svm_model.pkl          (auxiliary/experimental)
    models/decision_tree_model.pkl (auxiliary/experimental)
    models/gradient_boosting_model.pkl (auxiliary/experimental)
============================================================
"""

import os
import sys
import pickle
import time
import numpy as np
import pandas as pd
from sklearn.svm import SVC
from sklearn.tree import DecisionTreeClassifier
from sklearn.ensemble import GradientBoostingClassifier
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import LabelEncoder
from sklearn.metrics import classification_report

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from python.utils import (
    get_processed_dir,
    get_models_dir,
    print_separator,
    print_info,
    print_success,
    print_error,
    print_warning,
)
from python.tfidf_recommender import MovieRecommender


def load_processed_data():
    """Load all preprocessed data files."""
    processed_dir = get_processed_dir()

    movies_path = os.path.join(processed_dir, "movies.tsv")
    tags_path = os.path.join(processed_dir, "movie_tags.tsv")
    genres_path = os.path.join(processed_dir, "movie_genres.tsv")

    missing = []
    for name, path in [("movies.tsv", movies_path), ("movie_tags.tsv", tags_path),
                        ("movie_genres.tsv", genres_path)]:
        if not os.path.isfile(path):
            missing.append(name)

    if missing:
        print_error(
            f"Processed data files not found: {', '.join(missing)}\n"
            "Please run preprocessing first:\n"
            "  python3 python/preprocessing.py"
        )
        sys.exit(1)

    movies_df = pd.read_csv(movies_path, sep="\t")
    tags_df = pd.read_csv(tags_path, sep="\t")
    genres_df = pd.read_csv(genres_path, sep="\t")

    return movies_df, tags_df, genres_df


def train_primary_recommender(movies_df, tags_df):
    """
    Train the primary recommendation model.

    This is the CORE recommendation system using:
    - TF-IDF Vectorization
    - Cosine Similarity
    - KNN support

    Args:
        movies_df: Processed movies DataFrame
        tags_df: Movie tags DataFrame

    Returns:
        Trained MovieRecommender instance
    """
    print_separator("Training Primary Recommendation Model")

    # Merge movies with tags
    merged = pd.merge(
        movies_df,
        tags_df[["movie_id", "tags"]],
        on="movie_id",
        how="left",
    )
    merged["tags"] = merged["tags"].fillna("")

    # Add genres as a string for display
    merged["genres_str"] = ""  # Will be populated from genres_df if needed

    # Train the recommender
    recommender = MovieRecommender()
    start_time = time.time()
    recommender.fit(merged, tags_column="tags")
    elapsed = time.time() - start_time

    print_success(f"Primary model training completed in {elapsed:.2f} seconds")

    # Save models
    recommender.save_models()

    return recommender


def train_auxiliary_models(movies_df, tags_df, genres_df):
    """
    Train AUXILIARY classification models for academic demonstration.

    ============================================================
    IMPORTANT ACADEMIC NOTE:
    These models are EXPERIMENTAL genre classifiers.
    They do NOT directly contribute to the final movie
    recommendation ranking. The primary recommendation
    mechanism is TF-IDF + Cosine Similarity + KNN + Counter voting.

    These auxiliary models demonstrate that classification
    algorithms (SVM, Decision Tree, Gradient Boosting) can
    be applied to movie metadata for tasks such as genre
    prediction. They are included for educational purposes
    to show different ML techniques on the same dataset.
    ============================================================

    Args:
        movies_df: Processed movies DataFrame
        tags_df: Movie tags DataFrame
        genres_df: Movie genres DataFrame
    """
    print_separator("Training Auxiliary Models (Experimental)")
    print_warning(
        "These auxiliary models are for academic demonstration.\n"
        "         They do NOT directly contribute to the final recommendation ranking.\n"
        "         The primary recommendation uses: TF-IDF + Cosine Similarity + KNN + Counter voting."
    )

    models_dir = get_models_dir()

    # Prepare data: predict primary genre from movie features
    # Get primary genre for each movie (first genre)
    primary_genres = genres_df.drop_duplicates(subset="movie_id", keep="first")
    primary_genres = primary_genres.rename(columns={"genre": "primary_genre"})

    # Merge with movies
    merged = pd.merge(movies_df, primary_genres[["movie_id", "primary_genre"]], on="movie_id", how="inner")

    # Filter to genres with enough samples
    genre_counts = merged["primary_genre"].value_counts()
    valid_genres = genre_counts[genre_counts >= 10].index.tolist()
    merged = merged[merged["primary_genre"].isin(valid_genres)].copy()

    if len(merged) < 50:
        print_warning("Not enough data for auxiliary model training. Skipping.")
        return

    # Feature engineering for classification
    features = merged[["vote_average", "vote_count", "popularity", "runtime", "revenue"]].copy()
    features = features.fillna(0)

    # Encode labels
    label_encoder = LabelEncoder()
    labels = label_encoder.fit_transform(merged["primary_genre"])

    # Split data
    X_train, X_test, y_train, y_test = train_test_split(
        features, labels, test_size=0.2, random_state=42, stratify=labels
    )

    print_info(f"Training set: {len(X_train)} samples")
    print_info(f"Test set: {len(X_test)} samples")
    print_info(f"Genres: {len(valid_genres)}")

    # ---- SVM ----
    print_info("Training SVM (kernel='linear', probability=True)...")
    try:
        svm_model = SVC(kernel="linear", probability=True, random_state=42, max_iter=5000)
        svm_model.fit(X_train, y_train)
        svm_accuracy = svm_model.score(X_test, y_test)
        print_success(f"SVM accuracy: {svm_accuracy:.4f}")

        with open(os.path.join(models_dir, "svm_model.pkl"), "wb") as f:
            pickle.dump({"model": svm_model, "encoder": label_encoder}, f)
    except Exception as e:
        print_warning(f"SVM training failed: {e}")

    # ---- Decision Tree ----
    print_info("Training Decision Tree (random_state=42)...")
    try:
        dt_model = DecisionTreeClassifier(random_state=42, max_depth=10)
        dt_model.fit(X_train, y_train)
        dt_accuracy = dt_model.score(X_test, y_test)
        print_success(f"Decision Tree accuracy: {dt_accuracy:.4f}")

        with open(os.path.join(models_dir, "decision_tree_model.pkl"), "wb") as f:
            pickle.dump({"model": dt_model, "encoder": label_encoder}, f)
    except Exception as e:
        print_warning(f"Decision Tree training failed: {e}")

    # ---- Gradient Boosting ----
    print_info("Training Gradient Boosting (n_estimators=100, random_state=42)...")
    try:
        gb_model = GradientBoostingClassifier(
            n_estimators=100, random_state=42, max_depth=5
        )
        gb_model.fit(X_train, y_train)
        gb_accuracy = gb_model.score(X_test, y_test)
        print_success(f"Gradient Boosting accuracy: {gb_accuracy:.4f}")

        with open(os.path.join(models_dir, "gradient_boosting_model.pkl"), "wb") as f:
            pickle.dump({"model": gb_model, "encoder": label_encoder}, f)
    except Exception as e:
        print_warning(f"Gradient Boosting training failed: {e}")

    print_separator("Auxiliary Models Summary")
    print("  These models predict a movie's primary genre from its metadata.")
    print("  They are EXPERIMENTAL and do NOT affect recommendation ranking.")
    print("  Primary recommendation uses: TF-IDF + Cosine Similarity + KNN + Counter voting.")
    print()


def main():
    """Main training entry point."""
    print_separator("Big Data Movie Recommender - Model Training", char="*", width=60)
    print()
    print("  This script trains the recommendation models.")
    print("  Ensure preprocessing has been run first:")
    print("    python3 python/preprocessing.py")
    print()

    start_time = time.time()

    # Load data
    movies_df, tags_df, genres_df = load_processed_data()
    print_success(f"Loaded {len(movies_df)} movies, {len(tags_df)} tags, {len(genres_df)} genre mappings")

    # Train primary recommender (TF-IDF + Cosine Sim + KNN)
    recommender = train_primary_recommender(movies_df, tags_df)

    # Train auxiliary models (SVM, Decision Tree, Gradient Boosting)
    train_auxiliary_models(movies_df, tags_df, genres_df)

    # Quick sanity check
    print_separator("Sanity Check - Sample Recommendation")
    try:
        # Find a popular movie for testing
        test_movies = ["Avatar", "The Avengers", "Titanic", "Inception"]
        for test_movie in test_movies:
            try:
                results, matched_title = recommender.recommend(test_movie, n=5)
                print(f"\n  Input: '{test_movie}' → Matched: '{matched_title}'")
                print(f"  Top 5 recommendations:")
                for _, row in results.iterrows():
                    print(f"    {row['rank']}. {row['title']} (similarity: {row['similarity_score']})")
                break
            except ValueError:
                continue
    except Exception as e:
        print_warning(f"Sanity check skipped: {e}")

    total_time = time.time() - start_time
    print_separator("Training Complete")
    print(f"  Total training time: {total_time:.2f} seconds")
    print(f"  Models saved to: {get_models_dir()}")
    print()
    print("  Next steps:")
    print("    python3 python/recommendation_app.py --movie \"Batman\"")
    print()


if __name__ == "__main__":
    main()
