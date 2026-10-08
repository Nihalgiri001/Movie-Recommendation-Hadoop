# MapReduce Programs — Compilation and Execution Guide

## Environment: [CLOUDERA]

All MapReduce programs must be compiled and executed inside the **Cloudera QuickStart VM** where Hadoop is installed.

---

## Prerequisites

1. Navigate to the project's `mapreduce/` directory:
   ```bash
   cd big-data-movie-recommender/mapreduce
   ```

2. Verify Hadoop is available:
   ```bash
   hadoop version
   hadoop classpath
   ```

3. Ensure data has been uploaded to HDFS:
   ```bash
   bash ../hdfs/upload_to_hdfs.sh
   ```

---

## Set HDFS User Variable

```bash
HDFS_USER=$(whoami)
HDFS_BASE="/user/${HDFS_USER}/movie_recommender"
```

---

## 1. WordCount

**Purpose:** Count word occurrences in movie tags/descriptions.

```bash
# Compile
javac -classpath $(hadoop classpath) -d . WordCount.java

# Create JAR
jar -cvf wordcount.jar WordCount*.class

# Run
INPUT="${HDFS_BASE}/processed/tags/movie_tags.tsv"
OUTPUT="${HDFS_BASE}/processed/mapreduce/wordcount"
hdfs dfs -rm -r -f ${OUTPUT}
hadoop jar wordcount.jar WordCount ${INPUT} ${OUTPUT}

# View output
hdfs dfs -cat ${OUTPUT}/part-r-00000 | head -20
```

---

## 2. FrequentWords

**Purpose:** Find the most frequent words in the movie corpus.

```bash
# Compile
javac -classpath $(hadoop classpath) -d . FrequentWords.java

# Create JAR
jar -cvf frequentwords.jar FrequentWords*.class

# Run (uses WordCount output as input)
INPUT="${HDFS_BASE}/processed/mapreduce/wordcount"
OUTPUT="${HDFS_BASE}/processed/mapreduce/frequent_words"
hdfs dfs -rm -r -f ${OUTPUT}
hadoop jar frequentwords.jar FrequentWords ${INPUT} ${OUTPUT}

# View output
hdfs dfs -cat ${OUTPUT}/part-r-00000
```

---

## 3. MovieGenreCount

**Purpose:** Count movies in each genre.

```bash
# Compile
javac -classpath $(hadoop classpath) -d . MovieGenreCount.java

# Create JAR
jar -cvf genrecount.jar MovieGenreCount*.class

# Run
INPUT="${HDFS_BASE}/processed/genres/movie_genres.tsv"
OUTPUT="${HDFS_BASE}/processed/mapreduce/genre_count"
hdfs dfs -rm -r -f ${OUTPUT}
hadoop jar genrecount.jar MovieGenreCount ${INPUT} ${OUTPUT}

# View output
hdfs dfs -cat ${OUTPUT}/part-r-00000
```

---

## 4. MovieYearCount

**Purpose:** Count movies released per year.

```bash
# Compile
javac -classpath $(hadoop classpath) -d . MovieYearCount.java

# Create JAR
jar -cvf yearcount.jar MovieYearCount*.class

# Run
INPUT="${HDFS_BASE}/processed/movies/movies.tsv"
OUTPUT="${HDFS_BASE}/processed/mapreduce/year_count"
hdfs dfs -rm -r -f ${OUTPUT}
hadoop jar yearcount.jar MovieYearCount ${INPUT} ${OUTPUT}

# View output
hdfs dfs -cat ${OUTPUT}/part-r-00000
```

---

## 5. K-Means Clustering

**Purpose:** Cluster movies based on vote_average and popularity.

```bash
# Compile both files together
javac -classpath $(hadoop classpath) -d . KMeansMapper.java KMeansReducer.java

# Create JAR
jar -cvf kmeans.jar KMeansMapper*.class KMeansReducer*.class

# Create initial centroids file (K=3)
cat > centroids.txt << 'EOF'
0	0.3,0.1
1	0.6,0.5
2	0.8,0.9
EOF

# Upload centroids
hdfs dfs -put -f centroids.txt ${HDFS_BASE}/mahout/input/

# Run (single iteration)
INPUT="${HDFS_BASE}/processed/movies/movies.tsv"
OUTPUT="${HDFS_BASE}/processed/mapreduce/kmeans"
hdfs dfs -rm -r -f ${OUTPUT}
hadoop jar kmeans.jar KMeansReducer \
  -Dcentroids.path=centroids.txt \
  -files centroids.txt \
  ${INPUT} ${OUTPUT}

# View output (new centroids + cluster sizes)
hdfs dfs -cat ${OUTPUT}/part-r-00000
```

### K-Means Iteration Process

Each run produces updated centroids. For full convergence:
1. Read the output centroids
2. Update `centroids.txt` with the new centroid values
3. Re-run the job
4. Repeat until centroids change minimally (convergence)

For academic demonstration, 2-3 iterations are typically sufficient.

---

## Cleanup

To remove all MapReduce output:
```bash
hdfs dfs -rm -r -f ${HDFS_BASE}/processed/mapreduce/
hdfs dfs -mkdir -p ${HDFS_BASE}/processed/mapreduce/
```

To remove compiled files:
```bash
rm -f *.class *.jar
```
