# Big Data-Based Movie Recommendation and Analytics System Using Hadoop Ecosystem

> **B.Tech Computer Science and Engineering — Big Data Analytics Laboratory Project**

---

## Table of Contents

1. [Project Overview](#1-project-overview)
2. [Problem Statement](#2-problem-statement)
3. [Objectives](#3-objectives)
4. [Features](#4-features)
5. [System Architecture](#5-system-architecture)
6. [Technology Stack](#6-technology-stack)
7. [Dataset](#7-dataset)
8. [Development vs Execution Environment](#8-development-vs-execution-environment)
9. [GitHub Workflow](#9-github-workflow)
10. [Installation and Setup](#10-installation-and-setup)
11. [HDFS Setup (Phase 5)](#11-hdfs-setup-phase-5)
12. [MapReduce Execution (Phase 6)](#12-mapreduce-execution-phase-6)
13. [Hive Analytics (Phase 7)](#13-hive-analytics-phase-7)
14. [Pig Processing (Phase 8)](#14-pig-processing-phase-8)
15. [Sqoop Integration (Phase 9)](#15-sqoop-integration-phase-9)
16. [Mahout Clustering (Phase 10)](#16-mahout-clustering-phase-10)
17. [Python Recommendation System (Phases 11–13)](#17-python-recommendation-system-phases-11-13)
18. [Visualization](#18-visualization)
19. [Optional Streamlit UI](#19-optional-streamlit-ui)
20. [Testing](#20-testing)
21. [Troubleshooting](#21-troubleshooting)
22. [Project Structure](#22-project-structure)
23. [BDA Syllabus Mapping](#23-bda-syllabus-mapping)
24. [Limitations](#24-limitations)
25. [Future Enhancements](#25-future-enhancements)

---

## 1. Project Overview

This project implements a **Big Data-based movie analytics and recommendation platform** using the **TMDB 5000 Movie Dataset** and the **Hadoop ecosystem**. It demonstrates the full Big Data pipeline from raw data ingestion through distributed storage, batch processing, structured analytics, SQL integration, machine learning, and intelligent movie recommendations.

```
TMDB CSV DATA → Data Preprocessing → HDFS → MapReduce / Hive / Pig
    → Analytics Outputs → Sqoop ↔ MySQL → Python Processing
    → Recommendation Model → Movie Recommendations → Visualization/UI
```

The system combines content-based recommendation (TF-IDF + Cosine Similarity + KNN) with Hadoop ecosystem analytics to build a technically correct and academically meaningful demonstration project.

---

## 2. Problem Statement

With the exponential growth of movie content across streaming platforms, users face information overload when choosing movies. This project addresses this challenge by:

1. Storing and processing large-scale movie metadata using distributed systems (HDFS, MapReduce)
2. Performing structured analytics using SQL-on-Hadoop tools (Hive, Pig)
3. Building an intelligent content-based recommendation system using machine learning
4. Demonstrating end-to-end Big Data pipeline integration

---

## 3. Objectives

- Demonstrate HDFS operations for distributed data storage
- Implement Hadoop MapReduce programs in Java for batch processing
- Perform structured analytical queries using Hive
- Process and transform data using Pig Latin
- Integrate relational databases with Hadoop using Sqoop
- Demonstrate distributed ML using Mahout (where available)
- Build a content-based movie recommendation engine using Python
- Generate data visualizations for analytical insights

---

## 4. Features

| Feature | Technology | Status |
|---------|-----------|--------|
| Distributed storage | HDFS | ✅ |
| Data preprocessing | Python/Pandas | ✅ |
| Word count analytics | Java MapReduce | ✅ |
| Most frequent words | Java MapReduce | ✅ |
| Genre count analytics | Java MapReduce | ✅ |
| Year count analytics | Java MapReduce | ✅ |
| K-Means clustering | Java MapReduce | ✅ |
| SQL analytics | Hive (12+ queries) | ✅ |
| Data flow processing | Pig Latin (3 scripts) | ✅ |
| SQL ↔ Hadoop integration | Sqoop | ✅ |
| Distributed ML | Mahout (optional) | ✅ |
| TF-IDF recommendation | Python/scikit-learn | ✅ |
| Cosine similarity | Python/scikit-learn | ✅ |
| KNN recommendation | Python/scikit-learn | ✅ |
| Counter-based voting | Python | ✅ |
| Data visualization | Python/Matplotlib | ✅ |
| Interactive UI | Streamlit (optional) | ✅ |
| Unit tests | Python unittest | ✅ |

---

## 5. System Architecture

```
                    TMDB CSV DATA
                         │
                         ▼
                  Python Preprocessing
                    (preprocessing.py)
                         │
                         ▼
              Hadoop-friendly TSV files
                         │
                         ▼
                       HDFS
           /user/<USER>/movie_recommender/
                         │
          ┌──────────────┼──────────────┐
          │              │              │
          ▼              ▼              ▼
      MapReduce         Hive           Pig
    (Java programs)  (SQL queries)  (Pig Latin)
          │              │              │
          └──────────────┼──────────────┘
                         │
                         ▼
                 Analytics Outputs
                         │
              ┌──────────┼──────────┐
              │                     │
              ▼                     ▼
           Sqoop                  Mahout
         (MySQL ↔ HDFS)        (Clustering)
              │
              ▼
        Python Processing
     (train_recommender.py)
              │
              ▼
       Recommendation Model
     (TF-IDF + Cosine + KNN)
              │
              ▼
      Movie Recommendations
     (recommendation_app.py)
              │
              ▼
       Visualization / UI
```

### Data Flow

```
RAW DATA → DATA CLEANING → DATA TRANSFORMATION → DISTRIBUTED STORAGE → DISTRIBUTED PROCESSING
```

```
TMDB CSV → Python Preprocessing → Hadoop-friendly TSV → HDFS
    → MapReduce/Hive/Pig → Analytics → Python Recommendation
    → TF-IDF → Cosine Similarity → KNN support → Counter voting → Top-N Recommendations
```

---

## 6. Technology Stack

| Component | Technology | Purpose |
|-----------|-----------|---------|
| Distributed Storage | HDFS | Store datasets and outputs at scale |
| Batch Processing | Hadoop MapReduce (Java) | Word count, genre/year analytics, K-Means |
| Structured Analytics | Apache Hive | SQL-like analytical queries |
| Data Flow Processing | Apache Pig | High-level data transformation |
| SQL Integration | Apache Sqoop | MySQL ↔ HDFS/Hive transfer |
| Distributed ML | Apache Mahout | K-Means clustering demonstration |
| Recommendation Engine | Python (scikit-learn) | TF-IDF, Cosine Similarity, KNN |
| Data Processing | Python (Pandas, NumPy) | Preprocessing and feature engineering |
| Visualization | Python (Matplotlib, Seaborn) | Charts and analytical graphs |
| Development | macOS | Code editing, Git, documentation |
| Execution | Cloudera QuickStart VM | All Hadoop ecosystem components |

---

## 7. Dataset

### TMDB 5000 Movie Dataset

This project uses the **TMDB 5000 Movie Dataset** as the primary dataset.

**Download:** [https://www.kaggle.com/datasets/tmdb/tmdb-movie-metadata](https://www.kaggle.com/datasets/tmdb/tmdb-movie-metadata)

**Required files:**

| File | Description | Size |
|------|-------------|------|
| `tmdb_5000_movies.csv` | Movie metadata (budget, genres, overview, etc.) | ~5.4 MB |
| `tmdb_5000_credits.csv` | Cast and crew information | ~38 MB |

### Placement

After downloading, place the CSV files in the `data/` directory:

```
big-data-movie-recommender/
└── data/
    ├── tmdb_5000_movies.csv    ← Place here
    └── tmdb_5000_credits.csv   ← Place here
```

> **Note:** These CSV files are **NOT committed to GitHub** (listed in `.gitignore`). Each user must download them separately from Kaggle.

---

## 8. Development vs Execution Environment

### MAC — Development Environment

The Mac is used for:
- Writing and editing code
- Git version control
- GitHub push/pull
- Python development (preprocessing, recommendation code)
- Lightweight testing
- Documentation

> **Hadoop tools (HDFS, MapReduce, Hive, Pig, Sqoop, Mahout) are NOT installed on macOS.**

### CLOUDERA VM — Execution Environment

The Cloudera QuickStart VM is used for:
- HDFS operations
- Hadoop MapReduce execution
- Hive queries
- Pig scripts
- Sqoop import/export
- Mahout clustering
- Java compilation using Hadoop classpath
- Final Big Data demonstration

```
MAC (Development) → git push → GITHUB → git clone/pull → CLOUDERA VM (Execution)
```

---

## 9. GitHub Workflow

### Initial Setup

**[MAC]**
```bash
cd big-data-movie-recommender
git init
git add .
git commit -m "Initial commit: Big Data Movie Recommender"
git remote add origin <your-repository-url>
git push -u origin main
```

### Regular Updates

**[MAC]**
```bash
git add .
git commit -m "Update project"
git push
```

### Clone into Cloudera VM

**[CLOUDERA]**
```bash
git clone <your-repository-url>
cd big-data-movie-recommender
```

### Pull Updates

**[CLOUDERA]**
```bash
cd big-data-movie-recommender
git pull
```

---

## 10. Installation and Setup

### Phase 1 — Mac Setup (Development)

**[MAC]**

```bash
# Clone the repository
git clone <your-repository-url>
cd big-data-movie-recommender

# Install Python dependencies
pip3 install -r requirements.txt
```

### Phase 2 — Cloudera VM Setup

**[CLOUDERA]**

```bash
# Clone the repository
git clone <your-repository-url>
cd big-data-movie-recommender

# Install Python dependencies (if needed for recommendation)
pip install -r requirements.txt
```

### Phase 3 — Dataset Placement

**[MAC or CLOUDERA]**

Download the TMDB dataset from [Kaggle](https://www.kaggle.com/datasets/tmdb/tmdb-movie-metadata) and place in `data/`:

```bash
ls data/
# Should show:
# tmdb_5000_movies.csv
# tmdb_5000_credits.csv
```

### Phase 4 — Preprocessing

**[PYTHON]** (Can run on Mac or Cloudera)

```bash
python3 python/preprocessing.py
```

This generates Hadoop-friendly TSV files in `data/processed/`:
- `movies.tsv` — Movie metadata
- `movie_genres.tsv` — Movie-genre mapping
- `movie_tags.tsv` — Combined tags for recommendation

### Configuration (Optional)

```bash
cp config/config.example.env config/config.env
# Edit config/config.env with your MySQL credentials
```

---

## 11. HDFS Setup (Phase 5)

### Create HDFS Directory Structure

**[HDFS]**

```bash
bash hdfs/create_hdfs_structure.sh
```

This creates:
```
/user/<USERNAME>/movie_recommender/
├── raw/movies/            # Raw CSV files
├── raw/credits/
├── processed/movies/      # Preprocessed TSV
├── processed/genres/
├── processed/tags/
├── processed/mapreduce/   # MapReduce output
├── processed/hive/
├── processed/pig/
├── sqoop/imports/         # Sqoop import data
├── sqoop/exports/
├── mahout/input/          # Mahout input vectors
├── mahout/output/
└── recommendations/output/
```

### Upload Data to HDFS

**[HDFS]**

```bash
bash hdfs/upload_to_hdfs.sh
```

### View HDFS Data

**[HDFS]**

```bash
bash hdfs/view_hdfs_data.sh
```

Demonstrates: `hdfs dfs -ls`, `hdfs dfs -cat`, `hdfs dfs -du`, `hdfs dfs -count`

### Download Data from HDFS

**[HDFS]**

```bash
bash hdfs/download_from_hdfs.sh
```

Demonstrates: `hdfs dfs -get`, `hdfs dfs -copyToLocal`

### Individual HDFS Commands Reference

```bash
HDFS_USER=$(whoami)
HDFS_BASE="/user/${HDFS_USER}/movie_recommender"

# Create directory
hdfs dfs -mkdir -p ${HDFS_BASE}/raw/movies

# Upload file
hdfs dfs -put data/processed/movies.tsv ${HDFS_BASE}/processed/movies/

# List files
hdfs dfs -ls ${HDFS_BASE}/

# View file content
hdfs dfs -cat ${HDFS_BASE}/processed/movies/movies.tsv | head -5

# Check storage usage
hdfs dfs -du -h ${HDFS_BASE}

# File/directory count
hdfs dfs -count ${HDFS_BASE}

# Download file
hdfs dfs -get ${HDFS_BASE}/processed/movies/movies.tsv output/
```

---

## 12. MapReduce Execution (Phase 6)

All MapReduce programs must be compiled and executed inside the **Cloudera VM**.

### Set Variables

**[CLOUDERA]**

```bash
cd big-data-movie-recommender/mapreduce
HDFS_USER=$(whoami)
HDFS_BASE="/user/${HDFS_USER}/movie_recommender"
```

### Program 1: WordCount

**Purpose:** Count word occurrences in movie tags/descriptions.

**[MAPREDUCE]**

```bash
# Compile
javac -classpath $(hadoop classpath) -d . WordCount.java

# Create JAR
jar -cvf wordcount.jar WordCount*.class

# Execute
INPUT="${HDFS_BASE}/processed/tags/movie_tags.tsv"
OUTPUT="${HDFS_BASE}/processed/mapreduce/wordcount"
hdfs dfs -rm -r -f ${OUTPUT}
hadoop jar wordcount.jar WordCount ${INPUT} ${OUTPUT}

# View output
hdfs dfs -cat ${OUTPUT}/part-r-00000 | head -20
```

**Input:** Movie tags TSV from HDFS
**Processing:** Mapper tokenizes words → Reducer sums counts
**Output:** `word\tcount` (sorted alphabetically)

---

### Program 2: FrequentWords

**Purpose:** Find the most frequent words in the movie corpus.

**[MAPREDUCE]**

```bash
javac -classpath $(hadoop classpath) -d . FrequentWords.java
jar -cvf frequentwords.jar FrequentWords*.class

INPUT="${HDFS_BASE}/processed/mapreduce/wordcount"
OUTPUT="${HDFS_BASE}/processed/mapreduce/frequent_words"
hdfs dfs -rm -r -f ${OUTPUT}
hadoop jar frequentwords.jar FrequentWords ${INPUT} ${OUTPUT}

hdfs dfs -cat ${OUTPUT}/part-r-00000
```

**Input:** WordCount output
**Processing:** Sorts by frequency using TreeMap top-N pattern
**Output:** Top 50 most frequent words (descending)

---

### Program 3: MovieGenreCount

**Purpose:** Count movies in each genre.

**[MAPREDUCE]**

```bash
javac -classpath $(hadoop classpath) -d . MovieGenreCount.java
jar -cvf genrecount.jar MovieGenreCount*.class

INPUT="${HDFS_BASE}/processed/genres/movie_genres.tsv"
OUTPUT="${HDFS_BASE}/processed/mapreduce/genre_count"
hdfs dfs -rm -r -f ${OUTPUT}
hadoop jar genrecount.jar MovieGenreCount ${INPUT} ${OUTPUT}

hdfs dfs -cat ${OUTPUT}/part-r-00000
```

**Input:** movie_genres.tsv (movie_id\tgenre)
**Output:** `genre\tcount`

---

### Program 4: MovieYearCount

**Purpose:** Count movies released per year.

**[MAPREDUCE]**

```bash
javac -classpath $(hadoop classpath) -d . MovieYearCount.java
jar -cvf yearcount.jar MovieYearCount*.class

INPUT="${HDFS_BASE}/processed/movies/movies.tsv"
OUTPUT="${HDFS_BASE}/processed/mapreduce/year_count"
hdfs dfs -rm -r -f ${OUTPUT}
hadoop jar yearcount.jar MovieYearCount ${INPUT} ${OUTPUT}

hdfs dfs -cat ${OUTPUT}/part-r-00000
```

**Input:** movies.tsv
**Output:** `year\tmovie_count`

---

### Program 5: K-Means Clustering

**Purpose:** Cluster movies based on rating and popularity using MapReduce.

**[MAPREDUCE]**

```bash
# Compile
javac -classpath $(hadoop classpath) -d . KMeansMapper.java KMeansReducer.java
jar -cvf kmeans.jar KMeansMapper*.class KMeansReducer*.class

# Create initial centroids (K=3)
cat > centroids.txt << 'EOF'
0	0.3,0.1
1	0.6,0.5
2	0.8,0.9
EOF

# Execute
INPUT="${HDFS_BASE}/processed/movies/movies.tsv"
OUTPUT="${HDFS_BASE}/processed/mapreduce/kmeans"
hdfs dfs -rm -r -f ${OUTPUT}
hadoop jar kmeans.jar KMeansReducer \
  -Dcentroids.path=centroids.txt \
  -files centroids.txt \
  ${INPUT} ${OUTPUT}

# View results
hdfs dfs -cat ${OUTPUT}/part-r-00000
```

**Features:** vote_average (normalized 0-1), popularity (normalized 0-1)
**K = 3 clusters**

**Iteration:** Update centroids.txt with output values and re-run for convergence. 2-3 iterations are typically sufficient for demonstration.

---

## 13. Hive Analytics (Phase 7)

### Setup

**[HIVE]**

```bash
cd big-data-movie-recommender

# Step 1: Create database
hive -f hive/create_database.sql

# Step 2: Create tables
hive -f hive/create_tables.sql

# Step 3: Load data (from local processed files)
hive -f hive/load_data.sql
```

### Run Analytics

**[HIVE]**

```bash
# Movie analytics (12 queries)
hive -f hive/movie_analytics.sql

# Genre analysis (6 queries)
hive -f hive/genre_analysis.sql

# Recommendation analysis (5 queries)
hive -f hive/recommendation_analysis.sql
```

### Queries Demonstrated

| # | Query | Concepts |
|---|-------|----------|
| 1 | Total number of movies | COUNT |
| 2 | Average rating | AVG |
| 3 | Minimum rating | MIN, ORDER BY |
| 4 | Maximum rating | MAX |
| 5 | Movie count by year | COUNT, GROUP BY, ORDER BY |
| 6 | Movie count by language | COUNT, GROUP BY |
| 7 | Distinct languages | COUNT DISTINCT |
| 8 | Top-rated movies | WHERE, ORDER BY, LIMIT |
| 9 | Most popular movies | ORDER BY DESC |
| 10 | Rating distribution | CASE, GROUP BY |
| 11 | High-rating languages | GROUP BY, HAVING, AVG |
| 12 | Revenue statistics | SUM, AVG, MAX, MIN |
| 13 | Average rating by genre | JOIN, GROUP BY, AVG |
| 14 | Genre co-occurrence | Self-JOIN, HAVING |
| 15+ | Additional analytics | Subqueries, aggregates |

### Interactive Hive

```bash
hive
USE movie_recommender;
SELECT * FROM movies LIMIT 5;
SELECT genre, COUNT(*) FROM movie_genres GROUP BY genre ORDER BY COUNT(*) DESC;
```

---

## 14. Pig Processing (Phase 8)

**[PIG]**

```bash
cd big-data-movie-recommender

# Movie analysis
pig pig/movie_analysis.pig

# Genre analysis
pig pig/genre_analysis.pig

# Word count
pig pig/movie_wordcount.pig
```

### Pig Concepts Demonstrated

| Concept | Script | Usage |
|---------|--------|-------|
| LOAD | All scripts | Load data from HDFS |
| FILTER | All scripts | Remove headers/nulls |
| FOREACH | All scripts | Project/transform columns |
| GROUP | All scripts | Aggregate by key |
| COUNT | All scripts | Count records |
| ORDER | All scripts | Sort results |
| STORE | All scripts | Save to HDFS |
| FLATTEN | movie_wordcount.pig | Expand tokenized words |
| TOKENIZE | movie_wordcount.pig | Split text into words |
| JOIN | genre_analysis.pig | Join genres with movies |
| LIMIT | movie_analysis.pig | Top-N results |
| AVG/MIN/MAX | movie_analysis.pig | Aggregate statistics |

### View Pig Output

```bash
hdfs dfs -cat /user/$USER/movie_recommender/processed/pig/genre_count/part-r-00000
hdfs dfs -cat /user/$USER/movie_recommender/processed/pig/movies_per_year/part-r-00000 | head -20
```

> **Note:** Remove output directories before re-running Pig scripts:
> `hdfs dfs -rm -r /user/$USER/movie_recommender/processed/pig/genre_count`

---

## 15. Sqoop Integration (Phase 9)

### MySQL Setup

**[CLOUDERA]** (MySQL runs inside Cloudera VM)

```bash
# Create MySQL tables
mysql -u root -pcloudera < sqoop/create_mysql_tables.sql
```

> **Note:** Default Cloudera QuickStart MySQL credentials: `root` / `cloudera`.
> MySQL runs **inside** the Cloudera VM, not on the Mac.

### Configure Credentials

```bash
cp config/config.example.env config/config.env
# Edit config/config.env if your credentials differ
```

> **NEVER commit `config/config.env` to GitHub.**

### Import: MySQL → HDFS

**[SQOOP]**

```bash
bash sqoop/import_movies.sh
```

### Import: MySQL → Hive

**[SQOOP]**

```bash
bash sqoop/import_to_hive.sh
```

### Export: HDFS → MySQL

**[SQOOP]**

```bash
bash sqoop/export_recommendations.sh
```

### Manual Sqoop Commands

```bash
# Import MySQL table to HDFS
sqoop import \
  --connect jdbc:mysql://localhost:3306/movie_recommender \
  --username root --password cloudera \
  --table movie_summary \
  --target-dir /user/$(whoami)/movie_recommender/sqoop/imports/movie_summary \
  --fields-terminated-by '\t' --num-mappers 1

# Import to Hive
sqoop import \
  --connect jdbc:mysql://localhost:3306/movie_recommender \
  --username root --password cloudera \
  --table movie_summary \
  --hive-import --hive-database movie_recommender \
  --hive-table movie_summary_imported --num-mappers 1

# Export from HDFS to MySQL
sqoop export \
  --connect jdbc:mysql://localhost:3306/movie_recommender \
  --username root --password cloudera \
  --table recommendations \
  --export-dir /user/$(whoami)/movie_recommender/recommendations/output \
  --input-fields-terminated-by '\t' --num-mappers 1
```

---

## 16. Mahout Clustering (Phase 10)

**[MAHOUT]**

```bash
bash mahout/clustering_commands.sh
```

### Important Notes

- Mahout availability varies across Cloudera versions
- The script automatically checks if Mahout is installed
- If Mahout is unavailable, the **MapReduce K-Means** implementation serves as the clustering demonstration
- The project functions fully without Mahout

### Fallback: MapReduce K-Means

If Mahout is not available:
```bash
# Use the custom MapReduce K-Means (see Phase 6, Program 5)
cd mapreduce
hadoop jar kmeans.jar KMeansReducer ...
```

See `mahout/README.md` for detailed version-aware instructions.

---

## 17. Python Recommendation System (Phases 11–13)

### Phase 11 — Model Training (MANUAL)

> **⚠️ Model training is manual and is NOT executed automatically by the project setup.**

**[PYTHON]**

```bash
python3 python/train_recommender.py
```

This trains:
1. **TF-IDF Vectorizer** — Converts movie tags to feature vectors
2. **Cosine Similarity Matrix** — Computes pairwise movie similarity
3. **KNN Model** (n_neighbors=5) — Auxiliary neighbor-based recommendations
4. **Auxiliary Models** (experimental) — SVM, Decision Tree, Gradient Boosting for genre classification

**Primary recommendation mechanism:**
```
TF-IDF → Cosine Similarity → KNN support → Counter-based voting → Top-N recommendations
```

**Auxiliary models note:** SVM, Decision Tree, and Gradient Boosting are **experimental genre classifiers** included for academic demonstration. They do **NOT** directly contribute to the final recommendation ranking.

**Output artifacts** (saved to `models/`):
- `tfidf_vectorizer.pkl`
- `cosine_similarity.pkl`
- `knn_model.pkl`
- `tfidf_matrix.pkl`
- `processed_movies.pkl`
- `svm_model.pkl` (auxiliary)
- `decision_tree_model.pkl` (auxiliary)
- `gradient_boosting_model.pkl` (auxiliary)

### Phase 12 — Get Recommendations

**[PYTHON]**

```bash
# Single movie recommendation
python3 python/recommendation_app.py --movie "Batman"

# Specify number of recommendations
python3 python/recommendation_app.py --movie "The Dark Knight" --n 5

# Interactive mode
python3 python/recommendation_app.py --interactive
```

**Example output:**
```
============================================================
  Recommendations for: Batman
============================================================

  Rank  Movie Title                                  Similarity  Rating  Year
  ------------------------------------------------------------------
  1     <dynamically generated>                       0.xxxx     x.x     xxxx
  2     <dynamically generated>                       0.xxxx     x.x     xxxx
  ...

  Total recommendations: 10
============================================================
```

> **Results are dynamically generated** from the trained model. No recommendations are hard-coded.

### Recommendation Pipeline

```
Input: "Batman"
    │
    ▼
Find movie index (case-insensitive, partial match)
    │
    ▼
Cosine similarity recommendations (top 2N candidates)
    │
    ▼
KNN recommendations (N neighbors)
    │
    ▼
Counter-based voting (weighted by rank)
    │
    ▼
Remove input movie from results
    │
    ▼
Return Top-N recommendations
```

---

## 18. Visualization

### Phase 13 — Generate Charts

**[PYTHON]**

```bash
python3 python/visualization.py
```

**Charts generated** (saved to `output/`):

| Chart | Description |
|-------|-------------|
| `genre_distribution.png` | Movie count by genre (bar chart) |
| `movies_per_year.png` | Movies released per year (line chart) |
| `avg_rating_by_genre.png` | Average rating by genre (bar chart) |
| `popularity_distribution.png` | Popularity score distribution (histogram) |
| `top_rated_movies.png` | Top 20 rated movies (bar chart) |
| `rating_distribution.png` | Rating distribution with KDE (histogram) |

> All charts are generated from actual preprocessed data.

---

## 19. Optional Streamlit UI

The Streamlit interface is **optional**. All core functionality works via command line.

To use Streamlit:

```bash
pip3 install streamlit
streamlit run python/streamlit_app.py
```

> The Hadoop components (HDFS, MapReduce, Hive, Pig, Sqoop) are completely independent of Streamlit.

---

## 20. Testing

**[PYTHON]** (Can run on Mac or Cloudera)

```bash
# Run all tests
python3 tests/test_recommender.py

# Or with pytest
python3 -m pytest tests/test_recommender.py -v
```

**Tests cover:**
- Utility functions (project root, paths)
- Preprocessing functions (safe_literal_eval, extract_names, clean_text)
- Recommender structure (initialization, error handling)
- Recommendation logic (with synthetic data, no full training)
- Project structure validation
- Edge cases (empty titles, missing movies, duplicates)

> **Tests do NOT perform expensive model training.** They use small synthetic datasets for validation.

---

## 21. Troubleshooting

| Problem | Solution |
|---------|----------|
| `HDFS command not found` | Run inside the Cloudera VM, not on Mac |
| `Hive command not found` | Run inside the Cloudera VM |
| `Pig command not found` | Run inside the Cloudera VM |
| `TMDB dataset not found` | Place CSV files in `data/` directory |
| `Recommendation model has not been trained` | Run `python3 python/train_recommender.py` first |
| `Movie not found` | Check spelling; try partial title |
| `max_df corresponds to < documents than min_df` | Dataset too small; add more movies |
| `HDFS: No such file or directory` | Run `hdfs/create_hdfs_structure.sh` and `hdfs/upload_to_hdfs.sh` |
| `MySQL connection refused` | Ensure MySQL is running: `sudo service mysqld start` |
| `Sqoop: Could not load db driver` | Check MySQL connector in Sqoop lib: `ls /usr/lib/sqoop/lib/mysql-*` |
| `Mahout: Command not found` | Mahout may not be in your Cloudera version; use MapReduce K-Means instead |
| `Permission denied` | Run `chmod +x hdfs/*.sh sqoop/*.sh mahout/*.sh` |
| `Java compilation error` | Ensure `hadoop classpath` returns valid paths |

---

## 22. Project Structure

```
big-data-movie-recommender/
│
├── data/                           # Dataset directory
│   └── .gitkeep                    # (CSV files not committed)
│
├── config/                         # Configuration
│   └── config.example.env          # Template (copy to config.env)
│
├── hdfs/                           # HDFS scripts (Unit-I)
│   ├── create_hdfs_structure.sh    # Create HDFS directories
│   ├── upload_to_hdfs.sh           # Upload data to HDFS
│   ├── view_hdfs_data.sh           # View HDFS contents
│   └── download_from_hdfs.sh       # Download from HDFS
│
├── mapreduce/                      # MapReduce programs (Unit-II)
│   ├── WordCount.java              # Word frequency count
│   ├── FrequentWords.java          # Most frequent words
│   ├── MovieGenreCount.java        # Genre distribution
│   ├── MovieYearCount.java         # Year distribution
│   ├── KMeansMapper.java           # K-Means clustering mapper
│   ├── KMeansReducer.java          # K-Means clustering reducer
│   └── README.md                   # Compilation guide
│
├── hive/                           # Hive scripts (Unit-III)
│   ├── create_database.sql         # Create database
│   ├── create_tables.sql           # Create tables
│   ├── load_data.sql               # Load TSV data
│   ├── movie_analytics.sql         # 12 analytical queries
│   ├── genre_analysis.sql          # Genre-focused queries
│   └── recommendation_analysis.sql # Recommendation queries
│
├── pig/                            # Pig Latin scripts (Unit-III)
│   ├── movie_analysis.pig          # Movie analytics
│   ├── genre_analysis.pig          # Genre analytics
│   ├── movie_wordcount.pig         # Word count
│   └── README.md                   # Execution guide
│
├── sqoop/                          # Sqoop scripts (Unit-IV)
│   ├── create_mysql_tables.sql     # MySQL table definitions
│   ├── import_movies.sh            # MySQL → HDFS
│   ├── import_to_hive.sh           # MySQL → Hive
│   └── export_recommendations.sh   # HDFS → MySQL
│
├── mahout/                         # Mahout ML (Unit-V)
│   ├── clustering_commands.sh      # K-Means clustering
│   └── README.md                   # Version-aware guide
│
├── python/                         # Python components (Unit-V)
│   ├── utils.py                    # Utility functions
│   ├── preprocessing.py            # Data preprocessing
│   ├── tfidf_recommender.py        # Recommendation engine
│   ├── train_recommender.py        # Model training (MANUAL)
│   ├── recommendation_app.py       # CLI application
│   └── visualization.py            # Chart generation
│
├── tests/                          # Unit tests
│   └── test_recommender.py         # 27 lightweight tests
│
├── output/                         # Generated output
│   └── .gitkeep                    # (outputs not committed)
│
├── models/                         # Trained models
│   └── .gitkeep                    # (models not committed)
│
├── requirements.txt                # Python dependencies
├── .gitignore                      # Git ignore rules
└── README.md                       # This file
```

---

## 23. BDA Syllabus Mapping

### Unit-I: Hadoop Storage File System (HDFS)

| Syllabus Requirement | Implementation |
|---------------------|----------------|
| Create HDFS directory structure | `hdfs/create_hdfs_structure.sh` |
| Create/prepare local data | `python/preprocessing.py` |
| Upload local → HDFS | `hdfs/upload_to_hdfs.sh` (`hdfs dfs -put`) |
| View HDFS files/directories | `hdfs/view_hdfs_data.sh` (`hdfs dfs -ls`, `-cat`) |
| Copy HDFS → local | `hdfs/download_from_hdfs.sh` (`hdfs dfs -get`) |
| Storage statistics | `hdfs dfs -du`, `hdfs dfs -count` |

### Unit-II: MapReduce

| Syllabus Requirement | Implementation |
|---------------------|----------------|
| Word Count | `mapreduce/WordCount.java` |
| Most Frequent Words | `mapreduce/FrequentWords.java` |
| Count by category | `mapreduce/MovieGenreCount.java`, `MovieYearCount.java` |
| K-Means clustering | `mapreduce/KMeansMapper.java`, `KMeansReducer.java` |
| Java Hadoop MapReduce API | All MapReduce programs |

### Unit-III: Hive and Pig

**Hive:**

| Syllabus Requirement | Implementation |
|---------------------|----------------|
| Create database/table | `hive/create_database.sql`, `create_tables.sql` |
| Load data | `hive/load_data.sql` |
| MIN, MAX, AVG, COUNT | `hive/movie_analytics.sql` (Queries 1-4, 12) |
| COUNT DISTINCT | `hive/movie_analytics.sql` (Query 7) |
| GROUP BY, ORDER BY | `hive/movie_analytics.sql` (Queries 5-6) |
| WHERE, HAVING | `hive/movie_analytics.sql` (Queries 8, 11) |
| Count per category (genre) | `hive/genre_analysis.sql` |
| JOIN | `hive/genre_analysis.sql`, `recommendation_analysis.sql` |

**Pig:**

| Syllabus Requirement | Implementation |
|---------------------|----------------|
| LOAD, FILTER, FOREACH | All Pig scripts |
| GROUP, COUNT, ORDER | All Pig scripts |
| STORE | All Pig scripts |
| TOKENIZE, FLATTEN | `pig/movie_wordcount.pig` |
| JOIN | `pig/genre_analysis.pig` |
| Word Count | `pig/movie_wordcount.pig` |

### Unit-IV: Sqoop

| Syllabus Requirement | Implementation |
|---------------------|----------------|
| SQL → HDFS | `sqoop/import_movies.sh` |
| SQL → Hive | `sqoop/import_to_hive.sh` |
| HDFS/Hive → SQL | `sqoop/export_recommendations.sh` |
| MySQL table creation | `sqoop/create_mysql_tables.sql` |

### Unit-V: Visualization and Mahout

| Syllabus Requirement | Implementation |
|---------------------|----------------|
| Python visualization | `python/visualization.py` (6 charts) |
| Mahout ML/clustering | `mahout/clustering_commands.sh` |
| K-Means clustering | `mahout/` + `mapreduce/KMeans*.java` |
| Recommendation system | `python/tfidf_recommender.py` |

---

## 24. Limitations

1. **Mahout compatibility:** Mahout availability depends on Cloudera version. MapReduce K-Means serves as fallback.
2. **Single-machine:** The Cloudera QuickStart VM runs in pseudo-distributed mode (single node).
3. **Dataset size:** TMDB 5000 is moderate-sized. For true Big Data demonstration, a larger dataset could be used.
4. **Sqoop MySQL:** Requires MySQL to be running inside Cloudera VM with accessible credentials.
5. **Cosine similarity matrix:** Stored in memory; for very large datasets, a sparse or distributed approach would be needed.
6. **Pig `$USER` expansion:** Pig uses `$USER` in HDFS paths; ensure the environment variable is set.

---

## 25. Future Enhancements

1. **Collaborative Filtering:** Add user-based or item-based collaborative filtering using MovieLens as supplementary data.
2. **Spark Integration:** Replace MapReduce with Spark for faster iterative algorithms.
3. **Real-time Processing:** Add Kafka + Storm/Flink for real-time recommendation updates.
4. **Larger Dataset:** Scale to full TMDB or IMDb datasets for genuine Big Data scale.
5. **Deep Learning:** Use neural collaborative filtering or transformer-based recommendations.
6. **Cloud Deployment:** Deploy on AWS EMR, Google Dataproc, or Azure HDInsight.
7. **API Server:** Create a REST API for recommendation serving.
8. **A/B Testing:** Implement recommendation quality evaluation framework.

---

## Complete End-to-End Workflow Summary

```
┌─────────────────────────────────────────────────────────────┐
│ PHASE 1  [MAC]       — Develop project, git push            │
│ PHASE 2  [CLOUDERA]  — git clone / git pull                 │
│ PHASE 3  [CLOUDERA]  — Place TMDB CSV files in data/        │
│ PHASE 4  [PYTHON]    — python3 python/preprocessing.py      │
│ PHASE 5  [HDFS]      — Create structure, upload data        │
│ PHASE 6  [MAPREDUCE] — Compile and run 5 Java programs      │
│ PHASE 7  [HIVE]      — Create DB, tables, run 23+ queries   │
│ PHASE 8  [PIG]       — Run 3 Pig Latin scripts              │
│ PHASE 9  [SQOOP]     — Import/export MySQL ↔ HDFS           │
│ PHASE 10 [MAHOUT]    — Run clustering (if available)        │
│ PHASE 11 [PYTHON]    — python3 python/train_recommender.py  │
│ PHASE 12 [PYTHON]    — python3 python/recommendation_app.py │
│ PHASE 13 [PYTHON]    — python3 python/visualization.py      │
└─────────────────────────────────────────────────────────────┘
```

---

*Model training was not executed automatically.*
