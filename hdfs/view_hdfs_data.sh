#!/bin/bash
# ============================================================
# Big Data Movie Recommender - View HDFS Data
# ============================================================
# Demonstrates HDFS file viewing commands.
# Shows directory listings, file contents, and storage info.
#
# Environment: [CLOUDERA]
#
# Usage:
#   bash hdfs/view_hdfs_data.sh
# ============================================================

set -euo pipefail

# ---- Determine project root ----
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# ---- Determine HDFS user ----
HDFS_USER="${HDFS_USER:-$(whoami)}"
HDFS_BASE="/user/${HDFS_USER}/movie_recommender"

echo "============================================================"
echo "  Viewing HDFS Data"
echo "============================================================"
echo "  HDFS User : ${HDFS_USER}"
echo "  HDFS Base : ${HDFS_BASE}"
echo "============================================================"

# ---- Check if HDFS command is available ----
if ! command -v hdfs &> /dev/null; then
    echo "[ERR] HDFS command not found."
    echo "      Run this script inside the Cloudera VM where Hadoop is installed."
    exit 1
fi

# ---- 1. List all directories (hdfs dfs -ls) ----
echo ""
echo "------------------------------------------------------------"
echo "  1. Directory Listing (hdfs dfs -ls)"
echo "------------------------------------------------------------"
echo "  Command: hdfs dfs -ls ${HDFS_BASE}/"
echo ""
hdfs dfs -ls "${HDFS_BASE}/" 2>/dev/null || echo "[WARN] Base directory not found. Run create_hdfs_structure.sh first."

# ---- 2. Recursive listing (hdfs dfs -ls -R) ----
echo ""
echo "------------------------------------------------------------"
echo "  2. Recursive Directory Listing (hdfs dfs -ls -R)"
echo "------------------------------------------------------------"
echo "  Command: hdfs dfs -ls -R ${HDFS_BASE}/"
echo ""
hdfs dfs -ls -R "${HDFS_BASE}/" 2>/dev/null || echo "[WARN] No data found."

# ---- 3. View file head (hdfs dfs -head) ----
echo ""
echo "------------------------------------------------------------"
echo "  3. File Content Preview (hdfs dfs -cat ... | head)"
echo "------------------------------------------------------------"

MOVIES_FILE="${HDFS_BASE}/processed/movies/movies.tsv"
if hdfs dfs -test -e "$MOVIES_FILE" 2>/dev/null; then
    echo "  Command: hdfs dfs -cat ${MOVIES_FILE} | head -5"
    echo ""
    hdfs dfs -cat "$MOVIES_FILE" 2>/dev/null | head -5
else
    echo "  [INFO] movies.tsv not found in HDFS. Upload data first."
fi

# ---- 4. View genre data ----
echo ""
echo "------------------------------------------------------------"
echo "  4. Genre Data Preview"
echo "------------------------------------------------------------"

GENRES_FILE="${HDFS_BASE}/processed/genres/movie_genres.tsv"
if hdfs dfs -test -e "$GENRES_FILE" 2>/dev/null; then
    echo "  Command: hdfs dfs -cat ${GENRES_FILE} | head -10"
    echo ""
    hdfs dfs -cat "$GENRES_FILE" 2>/dev/null | head -10
else
    echo "  [INFO] movie_genres.tsv not found in HDFS. Upload data first."
fi

# ---- 5. View tags data ----
echo ""
echo "------------------------------------------------------------"
echo "  5. Tags Data Preview"
echo "------------------------------------------------------------"

TAGS_FILE="${HDFS_BASE}/processed/tags/movie_tags.tsv"
if hdfs dfs -test -e "$TAGS_FILE" 2>/dev/null; then
    echo "  Command: hdfs dfs -cat ${TAGS_FILE} | head -5"
    echo ""
    hdfs dfs -cat "$TAGS_FILE" 2>/dev/null | head -5
else
    echo "  [INFO] movie_tags.tsv not found in HDFS. Upload data first."
fi

# ---- 6. File/directory count (hdfs dfs -count) ----
echo ""
echo "------------------------------------------------------------"
echo "  6. File and Directory Count (hdfs dfs -count)"
echo "------------------------------------------------------------"
echo "  Command: hdfs dfs -count ${HDFS_BASE}"
echo ""
hdfs dfs -count "${HDFS_BASE}" 2>/dev/null || echo "[WARN] No data found."

# ---- 7. Storage usage (hdfs dfs -du -h) ----
echo ""
echo "------------------------------------------------------------"
echo "  7. Storage Usage (hdfs dfs -du -h)"
echo "------------------------------------------------------------"
echo "  Command: hdfs dfs -du -h ${HDFS_BASE}"
echo ""
hdfs dfs -du -h "${HDFS_BASE}" 2>/dev/null || echo "[WARN] No data found."

echo ""
echo "============================================================"
echo "  [OK] HDFS data viewing complete."
echo "============================================================"
