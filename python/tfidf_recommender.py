"""
============================================================
Big Data Movie Recommender - TF-IDF Recommender Engine
============================================================
Core recommendation engine using TF-IDF vectorization,
cosine similarity, and KNN-based support.

This module provides:
- TF-IDF vectorization of movie tags
- Cosine similarity computation
- KNN-based neighbor finding
- Counter-based voting for final recommendations

Usage:
    from python.tfidf_recommender import MovieRecommender
    recommender = MovieRecommender()
    recommender.load_models()
    results = recommender.recommend("Batman", n=10)
============================================================
"""

import os
import sys
import pickle
import numpy as np
import pandas as pd
from collections import Counter
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.metrics.pairwise import cosine_similarity
from sklearn.neighbors import NearestNeighbors

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from python.utils import (
    get_models_dir,
    print_info,
    print_success,
    print_error,
    print_warning,
)


class MovieRecommender:
    """
    Content-based movie recommendation engine.

    The recommendation pipeline:
    1. TF-IDF vectorization of combined movie tags
    2. Cosine similarity for primary recommendations
    3. KNN for auxiliary recommendation support
    4. Counter-based voting/ranking to combine results
    """

    def __init__(self):
        self.tfidf_vectorizer = None
        self.tfidf_matrix = None
        self.cosine_sim = None
        self.knn_model = None
        self.movies_df = None
        self.is_loaded = False

    def fit(self, movies_df, tags_column="tags"):
        """
        Train the recommendation models on the movie dataset.

        Args:
            movies_df: DataFrame with at least 'title' and tags_column.
            tags_column: Name of the column containing combined tags.

        Returns:
            self
        """
        print_info("Training TF-IDF Vectorizer...")
        self.movies_df = movies_df.reset_index(drop=True).copy()

        # Ensure tags are strings
        self.movies_df[tags_column] = self.movies_df[tags_column].fillna("").astype(str)

        # ---- TF-IDF Vectorization ----
        # Adjust min_df for small datasets to avoid empty vocabulary
        n_docs = len(self.movies_df)
        min_df_val = 2 if n_docs >= 10 else 1

        self.tfidf_vectorizer = TfidfVectorizer(
            stop_words="english",
            max_features=10000,
            max_df=0.95,
            min_df=min_df_val,
        )
        self.tfidf_matrix = self.tfidf_vectorizer.fit_transform(
            self.movies_df[tags_column]
        )
        print_success(
            f"TF-IDF matrix shape: {self.tfidf_matrix.shape} "
            f"({self.tfidf_matrix.shape[0]} movies, "
            f"{self.tfidf_matrix.shape[1]} features)"
        )

        # ---- Cosine Similarity ----
        print_info("Computing cosine similarity matrix...")
        self.cosine_sim = cosine_similarity(self.tfidf_matrix, self.tfidf_matrix)
        print_success(f"Cosine similarity matrix shape: {self.cosine_sim.shape}")

        # ---- KNN Model ----
        print_info("Fitting KNN model (n_neighbors=5)...")
        self.knn_model = NearestNeighbors(
            n_neighbors=min(6, len(self.movies_df)),  # +1 because query itself is included
            metric="cosine",
            algorithm="brute",
        )
        self.knn_model.fit(self.tfidf_matrix)
        print_success("KNN model fitted")

        self.is_loaded = True
        return self

    def save_models(self, models_dir=None):
        """
        Save trained model artifacts to disk.

        Args:
            models_dir: Directory to save models. Defaults to models/.
        """
        if models_dir is None:
            models_dir = get_models_dir()

        os.makedirs(models_dir, exist_ok=True)

        artifacts = {
            "tfidf_vectorizer.pkl": self.tfidf_vectorizer,
            "cosine_similarity.pkl": self.cosine_sim,
            "knn_model.pkl": self.knn_model,
            "processed_movies.pkl": self.movies_df,
        }

        for filename, obj in artifacts.items():
            filepath = os.path.join(models_dir, filename)
            with open(filepath, "wb") as f:
                pickle.dump(obj, f)
            print_success(f"Saved: {filepath}")

        # Save TF-IDF matrix separately (needed for KNN queries)
        tfidf_path = os.path.join(models_dir, "tfidf_matrix.pkl")
        with open(tfidf_path, "wb") as f:
            pickle.dump(self.tfidf_matrix, f)
        print_success(f"Saved: {tfidf_path}")

    def load_models(self, models_dir=None):
        """
        Load trained model artifacts from disk.

        Args:
            models_dir: Directory containing models. Defaults to models/.

        Raises:
            FileNotFoundError: If model artifacts are missing.
        """
        if models_dir is None:
            models_dir = get_models_dir()

        required_files = [
            "tfidf_vectorizer.pkl",
            "cosine_similarity.pkl",
            "knn_model.pkl",
            "processed_movies.pkl",
            "tfidf_matrix.pkl",
        ]

        missing = [f for f in required_files if not os.path.isfile(os.path.join(models_dir, f))]
        if missing:
            raise FileNotFoundError(
                "Recommendation model has not been trained. "
                "Run the manual training command first:\n\n"
                "  python3 python/train_recommender.py\n\n"
                f"Missing: {', '.join(missing)}"
            )

        with open(os.path.join(models_dir, "tfidf_vectorizer.pkl"), "rb") as f:
            self.tfidf_vectorizer = pickle.load(f)
        with open(os.path.join(models_dir, "cosine_similarity.pkl"), "rb") as f:
            self.cosine_sim = pickle.load(f)
        with open(os.path.join(models_dir, "knn_model.pkl"), "rb") as f:
            self.knn_model = pickle.load(f)
        with open(os.path.join(models_dir, "processed_movies.pkl"), "rb") as f:
            self.movies_df = pickle.load(f)
        with open(os.path.join(models_dir, "tfidf_matrix.pkl"), "rb") as f:
            self.tfidf_matrix = pickle.load(f)

        self.is_loaded = True
        print_success("Models loaded successfully")

    def _find_movie_index(self, movie_title):
        """
        Find the index of a movie by title (case-insensitive partial match).

        Args:
            movie_title: Movie title to search for.

        Returns:
            int: Index of the movie in the DataFrame.

        Raises:
            ValueError: If movie is not found.
        """
        if not movie_title or not isinstance(movie_title, str):
            raise ValueError("Please provide a valid movie title.")

        title_lower = movie_title.strip().lower()
        titles_lower = self.movies_df["title"].str.lower().str.strip()

        # Try exact match first
        exact_matches = self.movies_df[titles_lower == title_lower]
        if len(exact_matches) > 0:
            return exact_matches.index[0]

        # Try partial match
        partial_matches = self.movies_df[titles_lower.str.contains(title_lower, na=False)]
        if len(partial_matches) > 0:
            if len(partial_matches) > 1:
                print_warning(
                    f"Multiple matches found for '{movie_title}': "
                    f"{partial_matches['title'].tolist()[:5]}. "
                    f"Using first match: '{partial_matches.iloc[0]['title']}'"
                )
            return partial_matches.index[0]

        raise ValueError(
            f"Movie '{movie_title}' not found in the dataset. "
            f"Please enter another title."
        )

    def _get_cosine_recommendations(self, movie_idx, n=10):
        """
        Get recommendations based on cosine similarity.

        Args:
            movie_idx: Index of the query movie.
            n: Number of recommendations.

        Returns:
            List of (index, similarity_score) tuples.
        """
        sim_scores = list(enumerate(self.cosine_sim[movie_idx]))
        # Sort by similarity (descending), exclude the movie itself
        sim_scores = sorted(sim_scores, key=lambda x: x[1], reverse=True)
        # Return top n+1 (to account for the movie itself)
        return [(idx, score) for idx, score in sim_scores[1 : n + 1]]

    def _get_knn_recommendations(self, movie_idx, n=5):
        """
        Get recommendations based on KNN.

        Args:
            movie_idx: Index of the query movie.
            n: Number of neighbors.

        Returns:
            List of (index, distance) tuples.
        """
        movie_vector = self.tfidf_matrix[movie_idx]
        n_neighbors = min(n + 1, self.tfidf_matrix.shape[0])
        distances, indices = self.knn_model.kneighbors(
            movie_vector, n_neighbors=n_neighbors
        )
        results = []
        for idx, dist in zip(indices[0], distances[0]):
            if idx != movie_idx:
                # Convert cosine distance to similarity
                similarity = 1 - dist
                results.append((idx, similarity))
        return results[:n]

    def recommend(self, movie_title, n=10):
        """
        Generate movie recommendations using combined cosine similarity
        and KNN with Counter-based voting.

        The recommendation pipeline:
        1. Find the movie index from the title
        2. Get cosine similarity recommendations
        3. Get KNN recommendations
        4. Combine using Counter-based voting/ranking
        5. Remove the input movie
        6. Return top N recommendations

        Args:
            movie_title: Title of the movie to get recommendations for.
            n: Number of recommendations to return (default: 10).

        Returns:
            DataFrame with recommended movies and their scores.

        Raises:
            ValueError: If movie is not found.
            RuntimeError: If models are not loaded.
        """
        if not self.is_loaded:
            raise RuntimeError(
                "Models not loaded. Call load_models() or fit() first."
            )

        # Step 1: Find movie index
        movie_idx = self._find_movie_index(movie_title)
        input_movie = self.movies_df.iloc[movie_idx]["title"]

        # Step 2: Get cosine similarity recommendations
        cosine_recs = self._get_cosine_recommendations(movie_idx, n=n * 2)

        # Step 3: Get KNN recommendations
        knn_recs = self._get_knn_recommendations(movie_idx, n=n)

        # Step 4: Combine using Counter-based voting
        # Each recommendation source votes for movie indices
        vote_counter = Counter()
        similarity_scores = {}

        # Cosine recommendations get weighted votes
        for rank, (idx, score) in enumerate(cosine_recs):
            vote_counter[idx] += (n * 2 - rank)  # Higher rank = more votes
            if idx not in similarity_scores:
                similarity_scores[idx] = score

        # KNN recommendations get weighted votes
        for rank, (idx, score) in enumerate(knn_recs):
            vote_counter[idx] += (n - rank)
            if idx not in similarity_scores:
                similarity_scores[idx] = score
            else:
                # Keep the higher similarity score
                similarity_scores[idx] = max(similarity_scores[idx], score)

        # Step 5: Remove input movie
        if movie_idx in vote_counter:
            del vote_counter[movie_idx]

        # Step 6: Get top N recommendations
        top_indices = [idx for idx, _ in vote_counter.most_common(n)]

        # Build results DataFrame
        results = []
        for rank, idx in enumerate(top_indices, 1):
            movie = self.movies_df.iloc[idx]
            results.append(
                {
                    "rank": rank,
                    "title": movie["title"],
                    "similarity_score": round(similarity_scores.get(idx, 0.0), 4),
                    "vote_average": movie.get("vote_average", 0.0),
                    "popularity": movie.get("popularity", 0.0),
                    "release_year": movie.get("release_year", ""),
                    "genres": movie.get("genres_str", ""),
                }
            )

        return pd.DataFrame(results), input_movie
