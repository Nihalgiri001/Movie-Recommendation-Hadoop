-- ============================================================
-- Big Data Movie Recommender - Genre Analysis (Hive)
-- ============================================================
-- In-depth genre analytics using Hive.
--
-- Demonstrates:
--   JOIN, GROUP BY, ORDER BY, COUNT, AVG, MIN, MAX
--   Subqueries, aggregate functions
--
-- Environment: [HIVE]
-- Execute inside Cloudera VM:
--   hive -f hive/genre_analysis.sql
-- ============================================================

USE movie_recommender;

-- ============================================================
-- Query 1: Movie Count by Genre (COUNT + GROUP BY)
-- Adapted from "count per state" → "count per genre"
-- ============================================================
SELECT '--- Genre Analysis Query 1: Movie Count by Genre ---';
SELECT
    g.genre,
    COUNT(*) AS movie_count
FROM movie_genres g
GROUP BY g.genre
ORDER BY movie_count DESC;

-- ============================================================
-- Query 2: Average Rating by Genre (AVG + JOIN)
-- ============================================================
SELECT '--- Genre Analysis Query 2: Average Rating by Genre ---';
SELECT
    g.genre,
    COUNT(*) AS movie_count,
    ROUND(AVG(m.vote_average), 2) AS avg_rating,
    ROUND(MIN(m.vote_average), 2) AS min_rating,
    ROUND(MAX(m.vote_average), 2) AS max_rating
FROM movie_genres g
JOIN movies m ON g.movie_id = m.movie_id
WHERE m.vote_average > 0
GROUP BY g.genre
ORDER BY avg_rating DESC;

-- ============================================================
-- Query 3: Average Popularity by Genre
-- ============================================================
SELECT '--- Genre Analysis Query 3: Average Popularity by Genre ---';
SELECT
    g.genre,
    COUNT(*) AS movie_count,
    ROUND(AVG(m.popularity), 2) AS avg_popularity,
    ROUND(MAX(m.popularity), 2) AS max_popularity
FROM movie_genres g
JOIN movies m ON g.movie_id = m.movie_id
GROUP BY g.genre
ORDER BY avg_popularity DESC;

-- ============================================================
-- Query 4: Top Rated Movie in Each Genre
-- ============================================================
SELECT '--- Genre Analysis Query 4: Highest Rated Movie per Genre ---';
SELECT
    g.genre,
    m.title,
    m.vote_average,
    m.vote_count
FROM movie_genres g
JOIN movies m ON g.movie_id = m.movie_id
WHERE m.vote_count >= 50
    AND m.vote_average = (
        SELECT MAX(m2.vote_average)
        FROM movie_genres g2
        JOIN movies m2 ON g2.movie_id = m2.movie_id
        WHERE g2.genre = g.genre AND m2.vote_count >= 50
    )
ORDER BY g.genre;

-- ============================================================
-- Query 5: Genre Combinations (Genres with high avg revenue)
-- Demonstrates: HAVING
-- ============================================================
SELECT '--- Genre Analysis Query 5: Genres with High Average Revenue ---';
SELECT
    g.genre,
    COUNT(*) AS movie_count,
    ROUND(AVG(m.revenue), 0) AS avg_revenue,
    ROUND(SUM(m.revenue), 0) AS total_revenue
FROM movie_genres g
JOIN movies m ON g.movie_id = m.movie_id
WHERE m.revenue > 0
GROUP BY g.genre
HAVING COUNT(*) >= 10
ORDER BY avg_revenue DESC;

-- ============================================================
-- Query 6: Genre Count Per Distinct Language
-- Demonstrates: COUNT DISTINCT
-- ============================================================
SELECT '--- Genre Analysis Query 6: Languages Per Genre ---';
SELECT
    g.genre,
    COUNT(DISTINCT m.original_language) AS language_count
FROM movie_genres g
JOIN movies m ON g.movie_id = m.movie_id
GROUP BY g.genre
ORDER BY language_count DESC;
