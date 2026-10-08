# Pig Latin Scripts — Execution Guide

## Environment: [PIG] — Cloudera VM

All Pig scripts must be executed inside the **Cloudera QuickStart VM**.

---

## Prerequisites

1. Processed data must be in HDFS:
   ```bash
   bash hdfs/upload_to_hdfs.sh
   ```

2. Verify Pig is available:
   ```bash
   pig --version
   ```

3. Set your HDFS user (Pig uses `$USER` automatically):
   ```bash
   echo $USER
   ```

**Note:** The Pig scripts use `/user/$USER/movie_recommender/` paths.
`$USER` is automatically expanded by Pig at runtime.

---

## Running Pig Scripts

### 1. Movie Analysis

Analyzes movie counts, ratings, year distribution, and popularity.

```bash
pig pig/movie_analysis.pig
```

**Output HDFS directories:**
- `/user/$USER/movie_recommender/processed/pig/movies_per_year`
- `/user/$USER/movie_recommender/processed/pig/movies_per_language`
- `/user/$USER/movie_recommender/processed/pig/top_rated`

### 2. Genre Analysis

Counts movies per genre and computes average ratings by genre.

```bash
pig pig/genre_analysis.pig
```

**Output HDFS directories:**
- `/user/$USER/movie_recommender/processed/pig/genre_count`
- `/user/$USER/movie_recommender/processed/pig/genre_avg_ratings`

### 3. Movie Word Count

Counts word frequencies in movie tags/descriptions.

```bash
pig pig/movie_wordcount.pig
```

**Output HDFS directory:**
- `/user/$USER/movie_recommender/processed/pig/wordcount`

---

## Viewing Output

```bash
hdfs dfs -cat /user/$USER/movie_recommender/processed/pig/genre_count/part-r-00000 | head -20
hdfs dfs -cat /user/$USER/movie_recommender/processed/pig/movies_per_year/part-r-00000 | head -20
```

---

## Cleaning Up Output (Before Re-running)

Pig will fail if the output directory already exists. Remove it first:

```bash
hdfs dfs -rm -r /user/$USER/movie_recommender/processed/pig/genre_count
hdfs dfs -rm -r /user/$USER/movie_recommender/processed/pig/movies_per_year
# etc.
```

---

## Local Mode (For Testing)

Run Pig in local mode (processes local files, not HDFS):

```bash
pig -x local pig/movie_analysis.pig
```

**Note:** Local mode paths must point to local filesystem files, not HDFS.
Adjust LOAD paths to use `data/processed/*.tsv` for local testing.
