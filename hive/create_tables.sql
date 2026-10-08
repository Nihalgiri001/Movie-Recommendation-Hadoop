-- ============================================================
-- Big Data Movie Recommender - Create Hive Tables
-- ============================================================
-- Creates tables for movie data in the movie_recommender database.
--
-- Environment: [HIVE]
-- Execute inside Cloudera VM:
--   hive -f hive/create_tables.sql
--
-- Tables created:
--   1. movies       - Movie metadata
--   2. movie_genres - Movie-genre mapping
-- ============================================================

USE movie_recommender;

-- ============================================================
-- Table 1: movies
-- ============================================================
-- Stores movie metadata from the preprocessed movies.tsv
-- ============================================================

DROP TABLE IF EXISTS movies;

CREATE TABLE movies (
    movie_id        INT         COMMENT 'Unique movie identifier',
    title           STRING      COMMENT 'Movie title',
    overview        STRING      COMMENT 'Movie plot overview',
    release_date    STRING      COMMENT 'Release date (YYYY-MM-DD)',
    release_year    STRING      COMMENT 'Release year',
    vote_average    DOUBLE      COMMENT 'Average rating (0-10)',
    vote_count      INT         COMMENT 'Number of votes',
    popularity      DOUBLE      COMMENT 'Popularity score',
    original_language STRING    COMMENT 'Original language code',
    runtime         DOUBLE      COMMENT 'Runtime in minutes',
    revenue         BIGINT      COMMENT 'Revenue in USD'
)
COMMENT 'TMDB 5000 Movie Dataset - Movie Metadata'
ROW FORMAT DELIMITED
    FIELDS TERMINATED BY '\t'
STORED AS TEXTFILE
TBLPROPERTIES ('skip.header.line.count'='1');

-- ============================================================
-- Table 2: movie_genres
-- ============================================================
-- Stores the movie-genre mapping (one row per movie-genre pair)
-- ============================================================

DROP TABLE IF EXISTS movie_genres;

CREATE TABLE movie_genres (
    movie_id    INT         COMMENT 'Movie identifier (FK to movies)',
    genre       STRING      COMMENT 'Genre name'
)
COMMENT 'TMDB 5000 Movie Dataset - Movie Genre Mapping'
ROW FORMAT DELIMITED
    FIELDS TERMINATED BY '\t'
STORED AS TEXTFILE
TBLPROPERTIES ('skip.header.line.count'='1');

-- Verify tables
SHOW TABLES;
DESCRIBE movies;
DESCRIBE movie_genres;
