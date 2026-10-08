-- ============================================================
-- Big Data Movie Recommender - Create Hive Database
-- ============================================================
-- Creates the movie_recommender database in Hive.
--
-- Environment: [HIVE]
-- Execute inside Cloudera VM:
--   hive -f hive/create_database.sql
-- ============================================================

-- Create database if it doesn't exist
CREATE DATABASE IF NOT EXISTS movie_recommender
COMMENT 'Movie Recommendation and Analytics System - BDA Lab Project';

-- Use the database
USE movie_recommender;

-- Verify
SHOW DATABASES;
DESCRIBE DATABASE movie_recommender;
