-- ============================================================
-- Big Data Movie Recommender - Load Data into Hive
-- ============================================================
-- Loads preprocessed TSV data into Hive tables.
--
-- The data can be loaded from either:
--   A) Local filesystem (the processed TSV files)
--   B) HDFS (if already uploaded)
--
-- Environment: [HIVE]
-- Execute inside Cloudera VM:
--   hive -f hive/load_data.sql
--
-- Prerequisites:
--   1. Run create_database.sql
--   2. Run create_tables.sql
--   3. Run python3 python/preprocessing.py (to generate TSV files)
-- ============================================================

USE movie_recommender;

-- ============================================================
-- Option A: Load from local filesystem
-- ============================================================
-- Adjust the path to match where your project is cloned.
-- The path below assumes the project is in the home directory.
-- ============================================================

-- Load movies data from local filesystem
-- NOTE: Replace the path with your actual project location if different
LOAD DATA LOCAL INPATH 'data/processed/movies.tsv'
OVERWRITE INTO TABLE movies;

-- Load genre mapping from local filesystem
LOAD DATA LOCAL INPATH 'data/processed/movie_genres.tsv'
OVERWRITE INTO TABLE movie_genres;

-- ============================================================
-- Option B: Load from HDFS (uncomment if data is already in HDFS)
-- ============================================================
-- Replace <USERNAME> with your Cloudera username or use a variable
--
-- LOAD DATA INPATH '/user/<USERNAME>/movie_recommender/processed/movies/movies.tsv'
-- OVERWRITE INTO TABLE movies;
--
-- LOAD DATA INPATH '/user/<USERNAME>/movie_recommender/processed/genres/movie_genres.tsv'
-- OVERWRITE INTO TABLE movie_genres;
-- ============================================================

-- ============================================================
-- Verify loaded data
-- ============================================================

-- Check row counts
SELECT 'movies' AS table_name, COUNT(*) AS row_count FROM movies
UNION ALL
SELECT 'movie_genres' AS table_name, COUNT(*) AS row_count FROM movie_genres;

-- Preview data
SELECT * FROM movies LIMIT 5;
SELECT * FROM movie_genres LIMIT 10;
