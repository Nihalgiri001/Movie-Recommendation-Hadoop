#!/bin/bash
# ============================================================
# Big Data Movie Recommender - Upload Data to HDFS
# ============================================================
# Uploads raw and processed dataset files from local filesystem
# to HDFS.
#
# Environment: [CLOUDERA]
# Run this script inside the Cloudera QuickStart VM.
#
# Prerequisites:
#   1. Run create_hdfs_structure.sh first
#   2. Place TMDB CSV files in data/
#   3. Run python3 python/preprocessing.py
#
# Usage:
#   bash hdfs/upload_to_hdfs.sh
# ============================================================

set -euo pipefail

# ---- Determine project root ----
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# ---- Determine HDFS user ----
HDFS_USER="${HDFS_USER:-$(whoami)}"
HDFS_BASE="/user/${HDFS_USER}/movie_recommender"

echo "============================================================"
echo "  Uploading Data to HDFS"
echo "============================================================"
echo "  HDFS User    : ${HDFS_USER}"
echo "  HDFS Base    : ${HDFS_BASE}"
echo "  Project Root : ${PROJECT_ROOT}"
echo "============================================================"

# ---- Check if HDFS command is available ----
if ! command -v hdfs &> /dev/null; then
    echo "[ERR] HDFS command not found."
    echo "      Run this script inside the Cloudera VM where Hadoop is installed."
    exit 1
fi

# ---- Upload raw CSV files ----
echo ""
echo "[INFO] Uploading raw dataset files..."

RAW_MOVIES="${PROJECT_ROOT}/data/tmdb_5000_movies.csv"
RAW_CREDITS="${PROJECT_ROOT}/data/tmdb_5000_credits.csv"

if [ -f "$RAW_MOVIES" ]; then
    hdfs dfs -put -f "$RAW_MOVIES" "${HDFS_BASE}/raw/movies/"
    echo "[OK]   Uploaded tmdb_5000_movies.csv → ${HDFS_BASE}/raw/movies/"
else
    echo "[WARN] tmdb_5000_movies.csv not found in ${PROJECT_ROOT}/data/"
    echo "       Please download from https://www.kaggle.com/datasets/tmdb/tmdb-movie-metadata"
fi

if [ -f "$RAW_CREDITS" ]; then
    hdfs dfs -put -f "$RAW_CREDITS" "${HDFS_BASE}/raw/credits/"
    echo "[OK]   Uploaded tmdb_5000_credits.csv → ${HDFS_BASE}/raw/credits/"
else
    echo "[WARN] tmdb_5000_credits.csv not found in ${PROJECT_ROOT}/data/"
    echo "       Please download from https://www.kaggle.com/datasets/tmdb/tmdb-movie-metadata"
fi

# ---- Upload processed TSV files ----
echo ""
echo "[INFO] Uploading processed data files..."

PROCESSED_DIR="${PROJECT_ROOT}/data/processed"

if [ -d "$PROCESSED_DIR" ]; then
    for tsv_file in "$PROCESSED_DIR"/*.tsv; do
        if [ -f "$tsv_file" ]; then
            filename=$(basename "$tsv_file")
            case "$filename" in
                "movies.tsv")
                    hdfs dfs -put -f "$tsv_file" "${HDFS_BASE}/processed/movies/"
                    echo "[OK]   Uploaded ${filename} → ${HDFS_BASE}/processed/movies/"
                    ;;
                "movie_genres.tsv")
                    hdfs dfs -put -f "$tsv_file" "${HDFS_BASE}/processed/genres/"
                    echo "[OK]   Uploaded ${filename} → ${HDFS_BASE}/processed/genres/"
                    ;;
                "movie_tags.tsv")
                    hdfs dfs -put -f "$tsv_file" "${HDFS_BASE}/processed/tags/"
                    echo "[OK]   Uploaded ${filename} → ${HDFS_BASE}/processed/tags/"
                    ;;
                *)
                    hdfs dfs -put -f "$tsv_file" "${HDFS_BASE}/processed/"
                    echo "[OK]   Uploaded ${filename} → ${HDFS_BASE}/processed/"
                    ;;
            esac
        fi
    done
else
    echo "[WARN] Processed data directory not found: ${PROCESSED_DIR}"
    echo "       Please run preprocessing first:"
    echo "         python3 python/preprocessing.py"
fi

# ---- Summary ----
echo ""
echo "============================================================"
echo "  Upload Summary"
echo "============================================================"
echo ""
echo "  Raw data:"
hdfs dfs -ls "${HDFS_BASE}/raw/movies/" 2>/dev/null || echo "    (empty)"
hdfs dfs -ls "${HDFS_BASE}/raw/credits/" 2>/dev/null || echo "    (empty)"
echo ""
echo "  Processed data:"
hdfs dfs -ls "${HDFS_BASE}/processed/movies/" 2>/dev/null || echo "    (empty)"
hdfs dfs -ls "${HDFS_BASE}/processed/genres/" 2>/dev/null || echo "    (empty)"
hdfs dfs -ls "${HDFS_BASE}/processed/tags/" 2>/dev/null || echo "    (empty)"
echo ""
echo "  Storage usage:"
hdfs dfs -du -h "${HDFS_BASE}" 2>/dev/null || echo "    (no data)"
echo ""
echo "[OK] Upload complete. Next step: Run MapReduce, Hive, or Pig."
