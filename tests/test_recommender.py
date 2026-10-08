"""
============================================================
Big Data Movie Recommender - Tests
============================================================
Lightweight tests for the recommendation system.

These tests do NOT perform expensive model training.
They test structural correctness and logic only.

Usage:
    python3 -m pytest tests/test_recommender.py -v

Or without pytest:
    python3 tests/test_recommender.py
============================================================
"""

import os
import sys
import unittest

# Add project root to path
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))


class TestUtils(unittest.TestCase):
    """Test utility functions."""

    def test_get_project_root(self):
        """Project root should be a valid directory."""
        from python.utils import get_project_root
        root = get_project_root()
        self.assertTrue(os.path.isdir(root))

    def test_get_data_dir(self):
        """Data directory path should end with 'data'."""
        from python.utils import get_data_dir
        data_dir = get_data_dir()
        self.assertTrue(data_dir.endswith("data"))

    def test_get_models_dir(self):
        """Models directory should be created if it doesn't exist."""
        from python.utils import get_models_dir
        models_dir = get_models_dir()
        self.assertTrue(os.path.isdir(models_dir))

    def test_get_output_dir(self):
        """Output directory should be created if it doesn't exist."""
        from python.utils import get_output_dir
        output_dir = get_output_dir()
        self.assertTrue(os.path.isdir(output_dir))


class TestPreprocessing(unittest.TestCase):
    """Test preprocessing functions (without requiring the actual dataset)."""

    def test_safe_literal_eval_valid(self):
        """safe_literal_eval should parse valid Python literals."""
        from python.preprocessing import safe_literal_eval
        result = safe_literal_eval("[{'id': 1, 'name': 'Action'}]")
        self.assertIsInstance(result, list)
        self.assertEqual(len(result), 1)
        self.assertEqual(result[0]["name"], "Action")

    def test_safe_literal_eval_empty(self):
        """safe_literal_eval should return empty list for empty/None input."""
        from python.preprocessing import safe_literal_eval
        self.assertEqual(safe_literal_eval(None), [])
        self.assertEqual(safe_literal_eval(""), [])

    def test_safe_literal_eval_invalid(self):
        """safe_literal_eval should return empty list for malformed input."""
        from python.preprocessing import safe_literal_eval
        self.assertEqual(safe_literal_eval("{invalid json}"), [])

    def test_extract_names(self):
        """extract_names should pull 'name' fields from dicts."""
        from python.preprocessing import extract_names
        data = [{"id": 1, "name": "Action"}, {"id": 2, "name": "Comedy"}]
        result = extract_names(data)
        self.assertEqual(result, ["Action", "Comedy"])

    def test_extract_names_max_items(self):
        """extract_names should respect max_items limit."""
        from python.preprocessing import extract_names
        data = [{"name": "A"}, {"name": "B"}, {"name": "C"}]
        result = extract_names(data, max_items=2)
        self.assertEqual(len(result), 2)

    def test_extract_names_empty(self):
        """extract_names should handle empty/invalid input."""
        from python.preprocessing import extract_names
        self.assertEqual(extract_names([]), [])
        self.assertEqual(extract_names(None), [])
        self.assertEqual(extract_names("not a list"), [])

    def test_extract_cast_names(self):
        """extract_cast_names should extract actor names up to limit."""
        from python.preprocessing import extract_cast_names
        cast = [{"name": "Actor1"}, {"name": "Actor2"}, {"name": "Actor3"}]
        result = extract_cast_names(cast, max_cast=2)
        self.assertEqual(len(result), 2)
        self.assertEqual(result[0], "Actor1")

    def test_extract_director(self):
        """extract_director should find the Director from crew list."""
        from python.preprocessing import extract_director
        crew = [
            {"name": "Writer1", "job": "Writer"},
            {"name": "Director1", "job": "Director"},
            {"name": "Producer1", "job": "Producer"},
        ]
        result = extract_director(crew)
        self.assertEqual(result, "Director1")

    def test_extract_director_none(self):
        """extract_director should return empty string if no director."""
        from python.preprocessing import extract_director
        crew = [{"name": "Writer1", "job": "Writer"}]
        self.assertEqual(extract_director(crew), "")
        self.assertEqual(extract_director([]), "")
        self.assertEqual(extract_director(None), "")

    def test_extract_year(self):
        """extract_year should extract year from YYYY-MM-DD format."""
        from python.preprocessing import extract_year
        self.assertEqual(extract_year("2020-01-15"), "2020")
        self.assertEqual(extract_year("1999-12-31"), "1999")

    def test_extract_year_invalid(self):
        """extract_year should handle invalid dates gracefully."""
        from python.preprocessing import extract_year
        self.assertEqual(extract_year(None), "")
        self.assertEqual(extract_year(""), "")

    def test_clean_text(self):
        """clean_text should remove tabs, newlines, and collapse spaces."""
        from python.preprocessing import clean_text
        self.assertEqual(clean_text("hello\tworld"), "hello world")
        self.assertEqual(clean_text("hello\nworld"), "hello world")
        self.assertEqual(clean_text("hello   world"), "hello world")
        self.assertEqual(clean_text(None), "")


class TestRecommenderStructure(unittest.TestCase):
    """Test recommender class structure (without requiring trained models)."""

    def test_recommender_init(self):
        """MovieRecommender should initialize with correct defaults."""
        from python.tfidf_recommender import MovieRecommender
        rec = MovieRecommender()
        self.assertFalse(rec.is_loaded)
        self.assertIsNone(rec.tfidf_vectorizer)
        self.assertIsNone(rec.cosine_sim)
        self.assertIsNone(rec.knn_model)
        self.assertIsNone(rec.movies_df)

    def test_recommender_unloaded_error(self):
        """Recommending without loading models should raise RuntimeError."""
        from python.tfidf_recommender import MovieRecommender
        rec = MovieRecommender()
        with self.assertRaises(RuntimeError):
            rec.recommend("Batman", n=5)

    def test_recommender_load_missing_models(self):
        """Loading from a nonexistent directory should raise FileNotFoundError."""
        from python.tfidf_recommender import MovieRecommender
        rec = MovieRecommender()
        with self.assertRaises(FileNotFoundError):
            rec.load_models(models_dir="/nonexistent/path")

    def test_recommender_fit_and_recommend(self):
        """Test fit and recommend with minimal synthetic data."""
        import pandas as pd
        from python.tfidf_recommender import MovieRecommender

        # Create minimal test dataset
        test_data = pd.DataFrame({
            "title": ["Batman", "Superman", "Spider-Man", "Iron Man",
                      "Wonder Woman", "Captain America", "Thor", "Hulk"],
            "tags": [
                "dark knight gotham city bruce wayne superhero action",
                "man steel krypton clark kent superhero action flying",
                "web slinger new york peter parker superhero action",
                "tony stark genius billionaire superhero armor technology",
                "amazon warrior diana prince superhero action mythology",
                "steve rogers shield superhero patriot action soldier",
                "asgard god thunder superhero action norse mythology",
                "bruce banner gamma radiation superhero strength anger",
            ],
            "vote_average": [8.0, 7.0, 7.5, 7.8, 7.2, 7.6, 7.1, 6.5],
            "popularity": [80, 70, 75, 78, 72, 76, 71, 65],
            "release_year": ["2008", "2013", "2002", "2008",
                           "2017", "2011", "2011", "2003"],
            "genres_str": ["Action", "Action", "Action", "Action",
                         "Action", "Action", "Action", "Action"],
        })

        rec = MovieRecommender()
        rec.fit(test_data, tags_column="tags")

        # Test recommendation
        results, matched = rec.recommend("Batman", n=5)
        self.assertEqual(matched, "Batman")
        self.assertGreater(len(results), 0)
        self.assertLessEqual(len(results), 5)

        # Verify Batman is not in its own recommendations
        recommended_titles = results["title"].tolist()
        self.assertNotIn("Batman", recommended_titles)

    def test_recommender_movie_not_found(self):
        """Recommending a nonexistent movie should raise ValueError."""
        import pandas as pd
        from python.tfidf_recommender import MovieRecommender

        test_data = pd.DataFrame({
            "title": ["Movie A", "Movie B", "Movie C"],
            "tags": ["tag1 tag2", "tag3 tag4", "tag5 tag6"],
            "vote_average": [7.0, 7.5, 8.0],
            "popularity": [50, 60, 70],
            "release_year": ["2020", "2021", "2022"],
            "genres_str": ["Action", "Comedy", "Drama"],
        })

        rec = MovieRecommender()
        rec.fit(test_data, tags_column="tags")

        with self.assertRaises(ValueError):
            rec.recommend("Nonexistent Movie XYZ", n=5)

    def test_recommender_empty_title(self):
        """Empty title should raise ValueError."""
        import pandas as pd
        from python.tfidf_recommender import MovieRecommender

        test_data = pd.DataFrame({
            "title": ["Movie A", "Movie B"],
            "tags": ["tag1", "tag2"],
            "vote_average": [7.0, 7.5],
            "popularity": [50, 60],
            "release_year": ["2020", "2021"],
            "genres_str": ["Action", "Comedy"],
        })

        rec = MovieRecommender()
        rec.fit(test_data, tags_column="tags")

        with self.assertRaises(ValueError):
            rec.recommend("", n=5)

    def test_recommendation_count(self):
        """Should return the requested number of recommendations (or fewer if not enough data)."""
        import pandas as pd
        from python.tfidf_recommender import MovieRecommender

        test_data = pd.DataFrame({
            "title": [f"Movie {i}" for i in range(20)],
            "tags": [f"tag{i} description{i} genre{i%5}" for i in range(20)],
            "vote_average": [5.0 + (i % 5) for i in range(20)],
            "popularity": [30 + i * 3 for i in range(20)],
            "release_year": [str(2000 + i) for i in range(20)],
            "genres_str": [f"Genre{i%3}" for i in range(20)],
        })

        rec = MovieRecommender()
        rec.fit(test_data, tags_column="tags")

        results, _ = rec.recommend("Movie 0", n=10)
        self.assertLessEqual(len(results), 10)
        self.assertGreater(len(results), 0)


class TestProjectStructure(unittest.TestCase):
    """Test that the project structure is correct."""

    def setUp(self):
        """Get project root."""
        from python.utils import get_project_root
        self.root = get_project_root()

    def test_required_directories_exist(self):
        """All required directories should exist."""
        required_dirs = [
            "data", "hdfs", "mapreduce", "hive",
            "pig", "sqoop", "mahout", "python",
            "tests", "output", "models", "config",
        ]
        for d in required_dirs:
            dir_path = os.path.join(self.root, d)
            self.assertTrue(
                os.path.isdir(dir_path),
                f"Required directory missing: {d}"
            )

    def test_required_python_files_exist(self):
        """All required Python files should exist."""
        required_files = [
            "python/utils.py",
            "python/preprocessing.py",
            "python/tfidf_recommender.py",
            "python/train_recommender.py",
            "python/recommendation_app.py",
            "python/visualization.py",
        ]
        for f in required_files:
            filepath = os.path.join(self.root, f)
            self.assertTrue(
                os.path.isfile(filepath),
                f"Required file missing: {f}"
            )

    def test_gitignore_exists(self):
        """The .gitignore file should exist."""
        self.assertTrue(os.path.isfile(os.path.join(self.root, ".gitignore")))

    def test_requirements_exists(self):
        """requirements.txt should exist."""
        self.assertTrue(os.path.isfile(os.path.join(self.root, "requirements.txt")))


if __name__ == "__main__":
    unittest.main(verbosity=2)
