-- ============================================================
-- Big Data Movie Recommender - Recommendation Analysis (Hive)
-- ============================================================
-- Analytical queries supporting the recommendation system.
--
-- These queries identify patterns useful for understanding
-- movie similarity and recommendation quality.
--
-- Environment: [HIVE]
-- Execute inside Cloudera VM:
--   hive -f hive/recommendation_analysis.sql
-- ============================================================

USE movie_recommender;

-- ============================================================
-- Query 1: Movies with Most Genres (potential recommendation hubs)
-- ============================================================
SELECT '--- Rec Analysis 1: Movies with Most Genre Tags ---';
SELECT
    m.title,
    COUNT(g.genre) AS genre_count,
    m.vote_average,
    m.popularity
FROM movies m
JOIN movie_genres g ON m.movie_id = g.movie_id
GROUP BY m.title, m.vote_average, m.popularity
ORDER BY genre_count DESC
LIMIT 15;

-- ============================================================
-- Query 2: Genre Co-occurrence (which genres appear together)
-- ============================================================
SELECT '--- Rec Analysis 2: Genre Co-occurrence ---';
SELECT
    g1.genre AS genre_a,
    g2.genre AS genre_b,
    COUNT(*) AS co_occurrence
FROM movie_genres g1
JOIN movie_genres g2 ON g1.movie_id = g2.movie_id
WHERE g1.genre < g2.genre
GROUP BY g1.genre, g2.genre
HAVING COUNT(*) >= 50
ORDER BY co_occurrence DESC
LIMIT 20;

-- ============================================================
-- Query 3: Highly Rated Movies Suitable for Recommendations
-- (High rating + High vote count = reliable for similarity)
-- ============================================================
SELECT '--- Rec Analysis 3: Reliable High-Quality Movies ---';
SELECT
    title,
    vote_average,
    vote_count,
    popularity,
    release_year
FROM movies
WHERE vote_count >= 200
    AND vote_average >= 7.0
ORDER BY vote_average DESC, vote_count DESC
LIMIT 20;

-- ============================================================
-- Query 4: Year-Genre Trends (genre popularity over time)
-- ============================================================
SELECT '--- Rec Analysis 4: Genre Trends by Decade ---';
SELECT
    CONCAT(CAST(FLOOR(CAST(m.release_year AS INT) / 10) * 10 AS STRING), 's') AS decade,
    g.genre,
    COUNT(*) AS movie_count
FROM movies m
JOIN movie_genres g ON m.movie_id = g.movie_id
WHERE m.release_year IS NOT NULL
    AND m.release_year != ''
    AND CAST(m.release_year AS INT) >= 1970
GROUP BY
    CONCAT(CAST(FLOOR(CAST(m.release_year AS INT) / 10) * 10 AS STRING), 's'),
    g.genre
HAVING COUNT(*) >= 10
ORDER BY decade, movie_count DESC;

-- ============================================================
-- Query 5: Language Distribution for Top-Rated Content
-- ============================================================
SELECT '--- Rec Analysis 5: Language Distribution (Rated > 7) ---';
SELECT
    original_language,
    COUNT(*) AS high_rated_count,
    ROUND(AVG(vote_average), 2) AS avg_rating
FROM movies
WHERE vote_average >= 7.0 AND vote_count >= 50
GROUP BY original_language
ORDER BY high_rated_count DESC
LIMIT 10;
