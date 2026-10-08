-- ============================================================
-- Big Data Movie Recommender - Movie Analysis (Pig Latin)
-- ============================================================
-- Demonstrates Pig Latin data processing on movie data.
--
-- Concepts: LOAD, FILTER, FOREACH, GROUP, COUNT, ORDER, STORE
--
-- Environment: [PIG]
-- Execute inside Cloudera VM:
--   pig pig/movie_analysis.pig
--
-- Or in local mode:
--   pig -x local pig/movie_analysis.pig
--
-- NOTE: Update HDFS paths if your username differs.
--       Default uses /user/<whoami>/movie_recommender/
-- ============================================================

-- ============================================================
-- Step 1: LOAD movie data from HDFS
-- ============================================================
movies = LOAD '/user/$USER/movie_recommender/processed/movies/movies.tsv'
    USING PigStorage('\t')
    AS (movie_id:int, title:chararray, overview:chararray,
        release_date:chararray, release_year:chararray,
        vote_average:double, vote_count:int,
        popularity:double, original_language:chararray,
        runtime:double, revenue:long);

-- ============================================================
-- Step 2: FILTER - Remove header and invalid records
-- ============================================================
movies_clean = FILTER movies BY movie_id IS NOT NULL
    AND title IS NOT NULL
    AND vote_average > 0;

-- ============================================================
-- Step 3: Total Movie Count
-- ============================================================
movies_group = GROUP movies_clean ALL;
total_count = FOREACH movies_group GENERATE
    COUNT(movies_clean) AS total_movies;

DUMP total_count;

-- ============================================================
-- Step 4: Average Rating (FOREACH + AVG)
-- ============================================================
avg_rating = FOREACH movies_group GENERATE
    ROUND_TO(AVG(movies_clean.vote_average), 2) AS avg_rating;

DUMP avg_rating;

-- ============================================================
-- Step 5: Movies Per Year (GROUP BY + COUNT + ORDER)
-- ============================================================
year_group = GROUP movies_clean BY release_year;
movies_per_year = FOREACH year_group GENERATE
    group AS release_year,
    COUNT(movies_clean) AS movie_count;

movies_per_year_sorted = ORDER movies_per_year BY release_year DESC;

-- Store results to HDFS
STORE movies_per_year_sorted INTO '/user/$USER/movie_recommender/processed/pig/movies_per_year'
    USING PigStorage('\t');

-- ============================================================
-- Step 6: Movies by Language (GROUP BY + COUNT)
-- ============================================================
lang_group = GROUP movies_clean BY original_language;
movies_per_lang = FOREACH lang_group GENERATE
    group AS language,
    COUNT(movies_clean) AS movie_count;

movies_per_lang_sorted = ORDER movies_per_lang BY movie_count DESC;

STORE movies_per_lang_sorted INTO '/user/$USER/movie_recommender/processed/pig/movies_per_language'
    USING PigStorage('\t');

-- ============================================================
-- Step 7: Top 10 Rated Movies (FILTER + ORDER + LIMIT)
-- ============================================================
popular_movies = FILTER movies_clean BY vote_count >= 100;
top_rated = ORDER popular_movies BY vote_average DESC;
top_10 = LIMIT top_rated 10;

top_10_display = FOREACH top_10 GENERATE
    title, vote_average, vote_count, popularity;

DUMP top_10_display;

STORE top_10_display INTO '/user/$USER/movie_recommender/processed/pig/top_rated'
    USING PigStorage('\t');

-- ============================================================
-- Step 8: Popularity Analysis
-- ============================================================
popularity_stats = FOREACH movies_group GENERATE
    ROUND_TO(AVG(movies_clean.popularity), 2) AS avg_popularity,
    ROUND_TO(MIN(movies_clean.popularity), 2) AS min_popularity,
    ROUND_TO(MAX(movies_clean.popularity), 2) AS max_popularity;

DUMP popularity_stats;
