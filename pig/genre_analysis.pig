-- ============================================================
-- Big Data Movie Recommender - Genre Analysis (Pig Latin)
-- ============================================================
-- Analyzes movie genre distribution using Pig Latin.
--
-- Concepts: LOAD, FILTER, FOREACH, GROUP, COUNT, ORDER, STORE
--
-- Environment: [PIG]
-- Execute inside Cloudera VM:
--   pig pig/genre_analysis.pig
-- ============================================================

-- ============================================================
-- Step 1: LOAD genre data from HDFS
-- ============================================================
genres = LOAD '/user/$USER/movie_recommender/processed/genres/movie_genres.tsv'
    USING PigStorage('\t')
    AS (movie_id:int, genre:chararray);

-- ============================================================
-- Step 2: FILTER - Remove header and null values
-- ============================================================
genres_clean = FILTER genres BY movie_id IS NOT NULL
    AND genre IS NOT NULL
    AND genre != 'genre';

-- ============================================================
-- Step 3: Genre Count (GROUP BY + COUNT)
-- ============================================================
genre_group = GROUP genres_clean BY genre;
genre_count = FOREACH genre_group GENERATE
    group AS genre,
    COUNT(genres_clean) AS movie_count;

genre_count_sorted = ORDER genre_count BY movie_count DESC;

DUMP genre_count_sorted;

STORE genre_count_sorted INTO '/user/$USER/movie_recommender/processed/pig/genre_count'
    USING PigStorage('\t');

-- ============================================================
-- Step 4: Load movies for JOIN analysis
-- ============================================================
movies = LOAD '/user/$USER/movie_recommender/processed/movies/movies.tsv'
    USING PigStorage('\t')
    AS (movie_id:int, title:chararray, overview:chararray,
        release_date:chararray, release_year:chararray,
        vote_average:double, vote_count:int,
        popularity:double, original_language:chararray,
        runtime:double, revenue:long);

movies_clean = FILTER movies BY movie_id IS NOT NULL AND vote_average > 0;

-- ============================================================
-- Step 5: JOIN genres with movies for rating analysis
-- ============================================================
genre_movies = JOIN genres_clean BY movie_id, movies_clean BY movie_id;

genre_ratings = FOREACH genre_movies GENERATE
    genres_clean::genre AS genre,
    movies_clean::vote_average AS vote_average,
    movies_clean::popularity AS popularity;

-- ============================================================
-- Step 6: Average Rating by Genre
-- ============================================================
genre_rating_group = GROUP genre_ratings BY genre;
avg_by_genre = FOREACH genre_rating_group GENERATE
    group AS genre,
    COUNT(genre_ratings) AS movie_count,
    ROUND_TO(AVG(genre_ratings.vote_average), 2) AS avg_rating,
    ROUND_TO(AVG(genre_ratings.popularity), 2) AS avg_popularity;

avg_by_genre_sorted = ORDER avg_by_genre BY avg_rating DESC;

DUMP avg_by_genre_sorted;

STORE avg_by_genre_sorted INTO '/user/$USER/movie_recommender/processed/pig/genre_avg_ratings'
    USING PigStorage('\t');
