# Mahout — Distributed Machine Learning

## Overview

Apache Mahout provides distributed machine learning capabilities for the Hadoop ecosystem. In this project, Mahout is used for **K-Means clustering** of movies based on numeric features (rating, popularity).

## Environment: [MAHOUT] — Cloudera VM

## Important Version Note

Mahout command syntax varies significantly across versions:
- **Mahout 0.9** (common in Cloudera QuickStart): Classic MapReduce-based algorithms
- **Mahout 0.10+**: Transition to Spark-based algorithms
- **Mahout 0.13+**: Deprecated many classic algorithms

This project targets Mahout 0.9 compatibility (Cloudera QuickStart).

## Check Mahout Availability

```bash
# Check if Mahout is installed
which mahout
mahout version

# If not installed, try:
sudo yum install mahout
```

## Running Mahout Clustering

```bash
bash mahout/clustering_commands.sh
```

The script will:
1. Check if Mahout is available
2. Generate feature vectors from movie data
3. Attempt K-Means clustering (K=3)
4. Display results or provide fallback instructions

## Fallback: MapReduce K-Means

If Mahout is unavailable or fails, the project includes a **custom MapReduce K-Means implementation** that demonstrates the same clustering concept:

```bash
cd mapreduce
javac -classpath $(hadoop classpath) -d . KMeansMapper.java KMeansReducer.java
jar -cvf kmeans.jar KMeansMapper*.class KMeansReducer*.class

# Create initial centroids (K=3)
echo -e "0\t0.3,0.1\n1\t0.6,0.5\n2\t0.8,0.9" > centroids.txt

HDFS_USER=$(whoami)
hadoop jar kmeans.jar KMeansReducer \
  -Dcentroids.path=centroids.txt \
  -files centroids.txt \
  /user/${HDFS_USER}/movie_recommender/processed/movies/movies.tsv \
  /user/${HDFS_USER}/movie_recommender/processed/mapreduce/kmeans
```

See [mapreduce/README.md](../mapreduce/README.md) for full details.

## Features Used for Clustering

| Feature | Description | Normalization |
|---------|-------------|---------------|
| vote_average | Movie rating (0-10) | Divided by 10 |
| popularity | TMDB popularity score | Capped at 100, divided by 100 |

## Expected Clusters (K=3)

The clustering typically identifies groups such as:
- **Cluster 0**: Low-rated, low-popularity movies
- **Cluster 1**: Medium-rated, medium-popularity movies
- **Cluster 2**: High-rated, high-popularity blockbusters

*Actual cluster assignments are determined by the algorithm — results will vary.*

## Academic Purpose

Mahout demonstrates **Unit-V** of the BDA syllabus:
- Distributed machine learning on Hadoop
- Clustering algorithms in a Big Data context
- Integration of ML with HDFS storage
