-- ============================================================
-- Big Data Movie Recommender - MySQL Tables for Sqoop
-- ============================================================
-- Creates MySQL tables used for Sqoop import/export.
--
-- Environment: [CLOUDERA] - MySQL
-- Execute inside Cloudera VM:
--   mysql -u root -p < sqoop/create_mysql_tables.sql
--
-- Or interactively:
--   mysql -u root -p
--   source sqoop/create_mysql_tables.sql
--
-- Default Cloudera QuickStart MySQL password: cloudera
-- ============================================================

-- Create the database
CREATE DATABASE IF NOT EXISTS movie_recommender;
USE movie_recommender;

-- ============================================================
-- Table 1: movie_summary
-- Purpose: Stores movie metadata for Sqoop import to HDFS/Hive
-- ============================================================
DROP TABLE IF EXISTS movie_summary;

CREATE TABLE movie_summary (
    movie_id        INT PRIMARY KEY,
    title           VARCHAR(500) NOT NULL,
    vote_average    DECIMAL(3,1) DEFAULT 0.0,
    vote_count      INT DEFAULT 0,
    popularity      DECIMAL(10,3) DEFAULT 0.0,
    release_year    VARCHAR(10) DEFAULT '',
    original_language VARCHAR(10) DEFAULT 'en',
    runtime         DECIMAL(5,1) DEFAULT 0.0,
    revenue         BIGINT DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- ============================================================
-- Table 2: recommendations
-- Purpose: Stores recommendation results for Sqoop export
-- ============================================================
DROP TABLE IF EXISTS recommendations;

CREATE TABLE recommendations (
    id                  INT AUTO_INCREMENT PRIMARY KEY,
    input_movie         VARCHAR(500) NOT NULL,
    recommended_movie   VARCHAR(500) NOT NULL,
    similarity_score    DECIMAL(6,4) DEFAULT 0.0,
    rank_position       INT DEFAULT 0,
    created_at          TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- ============================================================
-- Table 3: genre_stats
-- Purpose: Stores genre analytics from Hive/MapReduce
-- ============================================================
DROP TABLE IF EXISTS genre_stats;

CREATE TABLE genre_stats (
    genre           VARCHAR(100) PRIMARY KEY,
    movie_count     INT DEFAULT 0,
    avg_rating      DECIMAL(3,1) DEFAULT 0.0,
    avg_popularity  DECIMAL(10,3) DEFAULT 0.0
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Verify tables
SHOW TABLES;
DESCRIBE movie_summary;
DESCRIBE recommendations;
DESCRIBE genre_stats;

SELECT 'MySQL tables created successfully.' AS status;
