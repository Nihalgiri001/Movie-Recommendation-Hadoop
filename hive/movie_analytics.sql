-- ============================================================
-- Big Data Movie Recommender - Movie Analytics Queries
-- ============================================================
-- Demonstrates Hive analytical queries on movie data.
--
-- Concepts demonstrated:
--   COUNT, AVG, MIN, MAX, SUM
--   COUNT DISTINCT
--   GROUP BY, ORDER BY
--   WHERE, HAVING
--
-- Environment: [HIVE]
-- Execute inside Cloudera VM:
--   hive -f hive/movie_analytics.sql
--
-- Or run individual queries interactively:
--   hive
--   USE movie_recommender;
--   <paste query>
-- ============================================================

USE movie_recommender;

-- ============================================================
-- Query 1: Total Number of Movies
-- Demonstrates: COUNT
-- ============================================================
SELECT '--- Query 1: Total Number of Movies ---';
SELECT COUNT(*) AS total_movies FROM movies;

-- ============================================================
-- Query 2: Average Rating (AVG)
-- Demonstrates: AVG
-- ============================================================
SELECT '--- Query 2: Average Movie Rating ---';
SELECT
    ROUND(AVG(vote_average), 2) AS avg_rating
FROM movies
WHERE vote_average > 0;

-- ============================================================
-- Query 3: Minimum Rating (MIN)
-- Demonstrates: MIN
-- ============================================================
SELECT '--- Query 3: Minimum Rating ---';
SELECT
    title AS movie_title,
    vote_average AS rating
FROM movies
WHERE vote_average > 0
ORDER BY rating ASC
LIMIT 5;

-- ============================================================
-- Query 4: Maximum Rating (MAX)
-- Demonstrates: MAX
-- ============================================================
SELECT '--- Query 4: Maximum Rating ---';
SELECT
    MAX(vote_average) AS max_rating
FROM movies;

-- ============================================================
-- Query 5: Movie Count by Year (GROUP BY + ORDER BY)
-- Demonstrates: COUNT, GROUP BY, ORDER BY
-- Adapted from "count per state" to "count per year"
-- ============================================================
SELECT '--- Query 5: Movie Count by Year ---';
SELECT
    release_year,
    COUNT(*) AS movie_count
FROM movies
WHERE release_year IS NOT NULL
    AND release_year != ''
GROUP BY release_year
ORDER BY release_year DESC
LIMIT 20;

-- ============================================================
-- Query 6: Movie Count by Language
-- Demonstrates: COUNT, GROUP BY, ORDER BY
-- Adapted from "count per state" to "count per language"
-- ============================================================
SELECT '--- Query 6: Movie Count by Language ---';
SELECT
    original_language,
    COUNT(*) AS movie_count
FROM movies
GROUP BY original_language
ORDER BY movie_count DESC
LIMIT 15;

-- ============================================================
-- Query 7: Count Distinct Languages
-- Demonstrates: COUNT DISTINCT
-- ============================================================
SELECT '--- Query 7: Distinct Languages ---';
SELECT
    COUNT(DISTINCT original_language) AS distinct_languages
FROM movies;

-- ============================================================
-- Query 8: Top 10 Rated Movies (WHERE + ORDER BY)
-- Demonstrates: WHERE, ORDER BY, LIMIT
-- ============================================================
SELECT '--- Query 8: Top 10 Rated Movies (min 100 votes) ---';
SELECT
    title,
    vote_average,
    vote_count,
    popularity
FROM movies
WHERE vote_count >= 100
ORDER BY vote_average DESC
LIMIT 10;

-- ============================================================
-- Query 9: Most Popular Movies
-- Demonstrates: ORDER BY DESC
-- ============================================================
SELECT '--- Query 9: Top 10 Most Popular Movies ---';
SELECT
    title,
    popularity,
    vote_average,
    vote_count
FROM movies
ORDER BY popularity DESC
LIMIT 10;

-- ============================================================
-- Query 10: Rating Distribution
-- Demonstrates: CASE, COUNT, GROUP BY
-- ============================================================
SELECT '--- Query 10: Rating Distribution ---';
SELECT
    CASE
        WHEN vote_average >= 8 THEN 'Excellent (8-10)'
        WHEN vote_average >= 6 THEN 'Good (6-8)'
        WHEN vote_average >= 4 THEN 'Average (4-6)'
        WHEN vote_average >= 2 THEN 'Below Average (2-4)'
        ELSE 'Poor (0-2)'
    END AS rating_category,
    COUNT(*) AS movie_count
FROM movies
WHERE vote_average > 0
GROUP BY
    CASE
        WHEN vote_average >= 8 THEN 'Excellent (8-10)'
        WHEN vote_average >= 6 THEN 'Good (6-8)'
        WHEN vote_average >= 4 THEN 'Average (4-6)'
        WHEN vote_average >= 2 THEN 'Below Average (2-4)'
        ELSE 'Poor (0-2)'
    END
ORDER BY rating_category;

-- ============================================================
-- Query 11: High-Vote Movies with Above-Average Rating (HAVING)
-- Demonstrates: GROUP BY, HAVING, AVG
-- ============================================================
SELECT '--- Query 11: Languages with High Average Rating (HAVING) ---';
SELECT
    original_language,
    COUNT(*) AS movie_count,
    ROUND(AVG(vote_average), 2) AS avg_rating
FROM movies
WHERE vote_average > 0
GROUP BY original_language
HAVING COUNT(*) >= 10 AND AVG(vote_average) >= 6.0
ORDER BY avg_rating DESC;

-- ============================================================
-- Query 12: Revenue Statistics
-- Demonstrates: SUM, AVG, MAX, MIN
-- ============================================================
SELECT '--- Query 12: Revenue Statistics ---';
SELECT
    COUNT(*) AS movies_with_revenue,
    ROUND(AVG(revenue), 0) AS avg_revenue,
    MAX(revenue) AS max_revenue,
    MIN(revenue) AS min_revenue_nonzero,
    SUM(revenue) AS total_revenue
FROM movies
WHERE revenue > 0;
