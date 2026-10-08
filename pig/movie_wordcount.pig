-- ============================================================
-- Big Data Movie Recommender - Word Count (Pig Latin)
-- ============================================================
-- Word count analysis on movie tags using Pig Latin.
--
-- Demonstrates: LOAD, FOREACH, FLATTEN, TOKENIZE, GROUP, COUNT
--
-- Environment: [PIG]
-- Execute inside Cloudera VM:
--   pig pig/movie_wordcount.pig
-- ============================================================

-- ============================================================
-- Step 1: LOAD movie tags from HDFS
-- ============================================================
tags = LOAD '/user/$USER/movie_recommender/processed/tags/movie_tags.tsv'
    USING PigStorage('\t')
    AS (movie_id:int, title:chararray, tags_text:chararray);

-- ============================================================
-- Step 2: FILTER - Remove header and empty tags
-- ============================================================
tags_clean = FILTER tags BY movie_id IS NOT NULL
    AND tags_text IS NOT NULL
    AND tags_text != 'tags';

-- ============================================================
-- Step 3: Extract only the tags column
-- ============================================================
tags_only = FOREACH tags_clean GENERATE
    LOWER(tags_text) AS tags_text;

-- ============================================================
-- Step 4: TOKENIZE - Split tags into individual words
-- ============================================================
words = FOREACH tags_only GENERATE
    FLATTEN(TOKENIZE(tags_text)) AS word;

-- ============================================================
-- Step 5: FILTER - Remove short words (length <= 2)
-- ============================================================
words_filtered = FILTER words BY SIZE(word) > 2;

-- ============================================================
-- Step 6: GROUP BY word and COUNT
-- ============================================================
word_group = GROUP words_filtered BY word;
word_count = FOREACH word_group GENERATE
    group AS word,
    COUNT(words_filtered) AS count;

-- ============================================================
-- Step 7: ORDER by count descending
-- ============================================================
word_count_sorted = ORDER word_count BY count DESC;

-- ============================================================
-- Step 8: Get top 50 words
-- ============================================================
top_words = LIMIT word_count_sorted 50;

DUMP top_words;

-- ============================================================
-- Step 9: STORE full word count to HDFS
-- ============================================================
STORE word_count_sorted INTO '/user/$USER/movie_recommender/processed/pig/wordcount'
    USING PigStorage('\t');
