"""
============================================================
Big Data Movie Recommender - Data Preprocessing
============================================================
Preprocesses the TMDB 5000 Movie Dataset for use with Hadoop
ecosystem components.

This script:
1. Loads tmdb_5000_movies.csv and tmdb_5000_credits.csv
2. Merges them on the correct movie identifier
3. Parses nested JSON-like fields (genres, keywords, cast)
4. Extracts and cleans required features
5. Generates a combined 'tags' field for recommendation
6. Saves Hadoop-friendly TSV files

Input:
    data/tmdb_5000_movies.csv
    data/tmdb_5000_credits.csv

Output:
    data/processed/movies.tsv
    data/processed/movie_genres.tsv
    data/processed/movie_tags.tsv

Usage:
    python3 python/preprocessing.py
============================================================
"""

import os
import sys
import ast
import pandas as pd
import numpy as np

# Add project root to path for imports
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from python.utils import (
    check_dataset_exists,
    get_processed_dir,
    print_separator,
    print_info,
    print_success,
    print_error,
    print_warning,
)


def safe_literal_eval(val):
    """
    Safely evaluate a string representation of a Python literal.
    Handles JSON-like fields in the TMDB dataset.

    Args:
        val: String to evaluate.

    Returns:
        Evaluated Python object, or empty list on failure.
    """
    if pd.isna(val) or val == "" or val is None:
        return []
    try:
        return ast.literal_eval(str(val))
    except (ValueError, SyntaxError):
        return []


def extract_names(obj_list, max_items=None):
    """
    Extract 'name' field from a list of dictionaries.

    Args:
        obj_list: List of dicts with 'name' key.
        max_items: Maximum number of items to extract (None = all).

    Returns:
        List of name strings.
    """
    if not isinstance(obj_list, list):
        return []
    names = []
    for item in obj_list:
        if isinstance(item, dict) and "name" in item:
            names.append(str(item["name"]).strip())
            if max_items and len(names) >= max_items:
                break
    return names


def extract_cast_names(cast_list, max_cast=5):
    """
    Extract actor names from the cast list.

    Args:
        cast_list: List of cast member dicts.
        max_cast: Maximum number of cast members to extract.

    Returns:
        List of actor name strings.
    """
    if not isinstance(cast_list, list):
        return []
    names = []
    for member in cast_list:
        if isinstance(member, dict) and "name" in member:
            names.append(str(member["name"]).strip())
            if len(names) >= max_cast:
                break
    return names


def extract_director(crew_list):
    """
    Extract the director name from the crew list.

    Args:
        crew_list: List of crew member dicts.

    Returns:
        Director name string or empty string.
    """
    if not isinstance(crew_list, list):
        return ""
    for member in crew_list:
        if isinstance(member, dict) and member.get("job") == "Director":
            return str(member.get("name", "")).strip()
    return ""


def extract_year(date_str):
    """
    Extract year from a date string (YYYY-MM-DD format).

    Args:
        date_str: Date string.

    Returns:
        Year as string, or empty string on failure.
    """
    if pd.isna(date_str) or not isinstance(date_str, str):
        return ""
    try:
        return str(date_str.split("-")[0])
    except (IndexError, AttributeError):
        return ""


def clean_text(text):
    """
    Clean text for TSV output: remove tabs, newlines, and excessive spaces.

    Args:
        text: Input string.

    Returns:
        Cleaned string.
    """
    if pd.isna(text) or text is None:
        return ""
    text = str(text)
    text = text.replace("\t", " ").replace("\n", " ").replace("\r", " ")
    # Collapse multiple spaces
    text = " ".join(text.split())
    return text.strip()


def create_tags(row):
    """
    Create a combined 'tags' field from overview, genres, keywords, and cast.
    This field is used for TF-IDF vectorization in the recommendation system.

    Args:
        row: DataFrame row.

    Returns:
        Combined tags string.
    """
    parts = []

    # Add overview
    overview = clean_text(row.get("overview", ""))
    if overview:
        parts.append(overview)

    # Add genres
    genres = row.get("genres_list", [])
    if genres:
        parts.append(" ".join(genres))

    # Add keywords
    keywords = row.get("keywords_list", [])
    if keywords:
        parts.append(" ".join(keywords))

    # Add cast
    cast = row.get("cast_list", [])
    if cast:
        # Replace spaces in names with empty string for better matching
        parts.append(" ".join(name.replace(" ", "") for name in cast))

    # Add director
    director = row.get("director", "")
    if director:
        parts.append(director.replace(" ", ""))

    return " ".join(parts).lower().strip()


def preprocess():
    """
    Main preprocessing function.
    Loads, merges, cleans, and transforms the TMDB dataset
    into Hadoop-friendly TSV files.
    """
    print_separator("TMDB Data Preprocessing")

    # ---- Step 1: Verify dataset exists ----
    print_info("Checking dataset files...")
    try:
        movies_path, credits_path = check_dataset_exists()
    except FileNotFoundError as e:
        print_error(str(e))
        sys.exit(1)
    print_success(f"Movies file: {movies_path}")
    print_success(f"Credits file: {credits_path}")

    # ---- Step 2: Load datasets ----
    print_info("Loading datasets...")
    movies_df = pd.read_csv(movies_path)
    credits_df = pd.read_csv(credits_path)
    print_success(f"Movies loaded: {len(movies_df)} records")
    print_success(f"Credits loaded: {len(credits_df)} records")

    # ---- Step 3: Examine and prepare merge keys ----
    print_info("Preparing merge keys...")

    # The movies CSV uses 'id' and the credits CSV uses 'movie_id'
    if "movie_id" in credits_df.columns:
        credits_df = credits_df.rename(columns={"movie_id": "id"})
        print_info("Renamed credits 'movie_id' to 'id' for merge")
    elif "id" not in credits_df.columns:
        print_error("Credits dataset has no 'id' or 'movie_id' column. Cannot merge.")
        sys.exit(1)

    # Check for duplicates
    movies_dupes = movies_df["id"].duplicated().sum()
    credits_dupes = credits_df["id"].duplicated().sum()
    if movies_dupes > 0:
        print_warning(f"Found {movies_dupes} duplicate movie IDs in movies dataset")
        movies_df = movies_df.drop_duplicates(subset="id", keep="first")
    if credits_dupes > 0:
        print_warning(f"Found {credits_dupes} duplicate movie IDs in credits dataset")
        credits_df = credits_df.drop_duplicates(subset="id", keep="first")

    # ---- Step 4: Merge datasets ----
    print_info("Merging datasets on movie ID...")
    df = pd.merge(movies_df, credits_df, on="id", how="left")
    print_success(f"Merged dataset: {len(df)} records")

    # Handle title column conflicts from merge
    if "title_x" in df.columns:
        df["title"] = df["title_x"]
        df = df.drop(columns=["title_x", "title_y"], errors="ignore")

    # ---- Step 5: Parse nested JSON-like fields ----
    print_info("Parsing nested fields (genres, keywords, cast, crew)...")

    df["genres_list"] = df["genres"].apply(safe_literal_eval).apply(extract_names)
    df["keywords_list"] = df["keywords"].apply(safe_literal_eval).apply(extract_names)
    df["cast_list"] = df["cast"].apply(safe_literal_eval).apply(
        lambda x: extract_cast_names(x, max_cast=5)
    )
    df["director"] = df["crew"].apply(safe_literal_eval).apply(extract_director)

    print_success("Parsed genres, keywords, cast, and director")

    # ---- Step 6: Extract year ----
    df["release_year"] = df["release_date"].apply(extract_year)

    # ---- Step 7: Handle missing values ----
    print_info("Handling missing values...")
    missing_report = {
        "title": df["title"].isna().sum(),
        "overview": df["overview"].isna().sum(),
        "genres": (df["genres_list"].apply(len) == 0).sum(),
        "keywords": (df["keywords_list"].apply(len) == 0).sum(),
        "cast": (df["cast_list"].apply(len) == 0).sum(),
        "release_date": df["release_date"].isna().sum(),
        "vote_average": df["vote_average"].isna().sum(),
    }
    for field, count in missing_report.items():
        if count > 0:
            print_warning(f"Missing/empty {field}: {count} records")

    # Fill missing overviews with empty string
    df["overview"] = df["overview"].fillna("")

    # Fill missing numeric fields
    df["vote_average"] = df["vote_average"].fillna(0.0)
    df["vote_count"] = df["vote_count"].fillna(0).astype(int)
    df["popularity"] = df["popularity"].fillna(0.0)
    df["runtime"] = df["runtime"].fillna(0.0)
    df["revenue"] = df["revenue"].fillna(0).astype(int)

    # Drop records with missing titles
    before = len(df)
    df = df.dropna(subset=["title"])
    dropped = before - len(df)
    if dropped > 0:
        print_warning(f"Dropped {dropped} records with missing titles")

    # ---- Step 8: Generate tags ----
    print_info("Generating combined tags field...")
    df["tags"] = df.apply(create_tags, axis=1)

    empty_tags = (df["tags"].str.strip() == "").sum()
    if empty_tags > 0:
        print_warning(f"{empty_tags} movies have empty tags")

    # ---- Step 9: Clean text fields for TSV output ----
    print_info("Cleaning text fields for Hadoop-friendly output...")
    df["title_clean"] = df["title"].apply(clean_text)
    df["overview_clean"] = df["overview"].apply(clean_text)
    df["original_language"] = df["original_language"].fillna("unknown")

    # ---- Step 10: Create output DataFrames and save TSV files ----
    processed_dir = get_processed_dir()
    print_info(f"Saving processed files to: {processed_dir}")

    # --- movies.tsv ---
    movies_tsv = df[
        [
            "id",
            "title_clean",
            "overview_clean",
            "release_date",
            "release_year",
            "vote_average",
            "vote_count",
            "popularity",
            "original_language",
            "runtime",
            "revenue",
        ]
    ].copy()
    movies_tsv.columns = [
        "movie_id",
        "title",
        "overview",
        "release_date",
        "release_year",
        "vote_average",
        "vote_count",
        "popularity",
        "original_language",
        "runtime",
        "revenue",
    ]
    movies_tsv_path = os.path.join(processed_dir, "movies.tsv")
    movies_tsv.to_csv(movies_tsv_path, sep="\t", index=False, header=True)
    print_success(f"Saved movies.tsv ({len(movies_tsv)} records)")

    # --- movie_genres.tsv ---
    genre_rows = []
    for _, row in df.iterrows():
        movie_id = row["id"]
        for genre in row["genres_list"]:
            genre_rows.append({"movie_id": movie_id, "genre": clean_text(genre)})

    genres_df = pd.DataFrame(genre_rows)
    genres_tsv_path = os.path.join(processed_dir, "movie_genres.tsv")
    genres_df.to_csv(genres_tsv_path, sep="\t", index=False, header=True)
    print_success(f"Saved movie_genres.tsv ({len(genres_df)} records)")

    # --- movie_tags.tsv ---
    tags_tsv = df[["id", "title_clean", "tags"]].copy()
    tags_tsv.columns = ["movie_id", "title", "tags"]
    tags_tsv_path = os.path.join(processed_dir, "movie_tags.tsv")
    tags_tsv.to_csv(tags_tsv_path, sep="\t", index=False, header=True)
    print_success(f"Saved movie_tags.tsv ({len(tags_tsv)} records)")

    # ---- Summary ----
    print_separator("Preprocessing Summary")
    print(f"  Total movies processed : {len(df)}")
    print(f"  Total genre mappings   : {len(genres_df)}")
    print(f"  Unique genres          : {genres_df['genre'].nunique()}")
    print(f"  Year range             : {df['release_year'].min()} - {df['release_year'].max()}")
    print(f"  Languages              : {df['original_language'].nunique()}")
    print(f"  Movies with tags       : {(df['tags'].str.strip() != '').sum()}")
    print()
    print(f"  Output directory       : {processed_dir}")
    print(f"  Files created:")
    print(f"    - movies.tsv         : Movie metadata")
    print(f"    - movie_genres.tsv   : Movie-genre mapping")
    print(f"    - movie_tags.tsv     : Combined tags for recommendation")
    print_separator()


if __name__ == "__main__":
    preprocess()
