#!/bin/bash
# ============================================================
# Big Data Movie Recommender - Download Data from HDFS
# ============================================================
# Copies processed data and analytics results from HDFS back
# to the local filesystem.
#
# Demonstrates: hdfs dfs -get, hdfs dfs -copyToLocal
#
# Environment: [CLOUDERA]
#
# Usage:
#   bash hdfs/download_from_hdfs.sh
# ============================================================

set -euo pipefail

# ---- Determine project root ----
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# ---- Determine HDFS user ----
HDFS_USER="${HDFS_USER:-$(whoami)}"
HDFS_BASE="/user/${HDFS_USER}/movie_recommender"

# ---- Local output directory ----
LOCAL_OUTPUT="${PROJECT_ROOT}/output/hdfs_downloads"
mkdir -p "$LOCAL_OUTPUT"

echo "============================================================"
echo "  Downloading Data from HDFS"
echo "============================================================"
echo "  HDFS User    : ${HDFS_USER}"
echo "  HDFS Base    : ${HDFS_BASE}"
echo "  Local Output : ${LOCAL_OUTPUT}"
echo "============================================================"

# ---- Check if HDFS command is available ----
if ! command -v hdfs &> /dev/null; then
    echo "[ERR] HDFS command not found."
    echo "      Run this script inside the Cloudera VM where Hadoop is installed."
    exit 1
fi

# ---- Download processed data ----
echo ""
echo "[INFO] Downloading processed data from HDFS..."

# Download movies.tsv
if hdfs dfs -test -e "${HDFS_BASE}/processed/movies/movies.tsv" 2>/dev/null; then
    hdfs dfs -get -f "${HDFS_BASE}/processed/movies/movies.tsv" "${LOCAL_OUTPUT}/"
    echo "[OK]   Downloaded movies.tsv"
else
    echo "[WARN] movies.tsv not found in HDFS"
fi

# Download movie_genres.tsv
if hdfs dfs -test -e "${HDFS_BASE}/processed/genres/movie_genres.tsv" 2>/dev/null; then
    hdfs dfs -get -f "${HDFS_BASE}/processed/genres/movie_genres.tsv" "${LOCAL_OUTPUT}/"
    echo "[OK]   Downloaded movie_genres.tsv"
else
    echo "[WARN] movie_genres.tsv not found in HDFS"
fi

# Download movie_tags.tsv
if hdfs dfs -test -e "${HDFS_BASE}/processed/tags/movie_tags.tsv" 2>/dev/null; then
    hdfs dfs -get -f "${HDFS_BASE}/processed/tags/movie_tags.tsv" "${LOCAL_OUTPUT}/"
    echo "[OK]   Downloaded movie_tags.tsv"
else
    echo "[WARN] movie_tags.tsv not found in HDFS"
fi

# ---- Download MapReduce output ----
echo ""
echo "[INFO] Downloading MapReduce output from HDFS..."

MR_OUTPUT="${LOCAL_OUTPUT}/mapreduce"
mkdir -p "$MR_OUTPUT"

for mr_dir in wordcount frequent_words genre_count year_count kmeans; do
    MR_HDFS="${HDFS_BASE}/processed/mapreduce/${mr_dir}"
    if hdfs dfs -test -d "$MR_HDFS" 2>/dev/null; then
        mkdir -p "${MR_OUTPUT}/${mr_dir}"
        hdfs dfs -copyToLocal "${MR_HDFS}/part-*" "${MR_OUTPUT}/${mr_dir}/" 2>/dev/null && \
            echo "[OK]   Downloaded MapReduce output: ${mr_dir}" || \
            echo "[WARN] No output files in ${mr_dir}"
    else
        echo "[INFO] MapReduce output not found: ${mr_dir} (run the job first)"
    fi
done

# ---- Summary ----
echo ""
echo "============================================================"
echo "  Download Summary"
echo "============================================================"
echo ""
echo "  Files downloaded to: ${LOCAL_OUTPUT}"
echo ""
ls -la "$LOCAL_OUTPUT" 2>/dev/null || echo "  (empty)"
echo ""
echo "[OK] Download complete."
