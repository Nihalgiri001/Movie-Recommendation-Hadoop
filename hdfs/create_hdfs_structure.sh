#!/bin/bash
# ============================================================
# Big Data Movie Recommender - Create HDFS Directory Structure
# ============================================================
# Creates the required HDFS directory structure for the project.
#
# Environment: [CLOUDERA]
# Run this script inside the Cloudera QuickStart VM.
#
# Usage:
#   bash hdfs/create_hdfs_structure.sh
# ============================================================

set -euo pipefail

# ---- Determine project root ----
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# ---- Determine HDFS user ----
HDFS_USER="${HDFS_USER:-$(whoami)}"
HDFS_BASE="/user/${HDFS_USER}/movie_recommender"

echo "============================================================"
echo "  Creating HDFS Directory Structure"
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

# ---- Create directory structure ----
echo "[INFO] Creating HDFS directories..."

# Raw data directories
hdfs dfs -mkdir -p "${HDFS_BASE}/raw/movies"
hdfs dfs -mkdir -p "${HDFS_BASE}/raw/credits"

# Processed data directories
hdfs dfs -mkdir -p "${HDFS_BASE}/processed/movies"
hdfs dfs -mkdir -p "${HDFS_BASE}/processed/genres"
hdfs dfs -mkdir -p "${HDFS_BASE}/processed/tags"
hdfs dfs -mkdir -p "${HDFS_BASE}/processed/mapreduce"
hdfs dfs -mkdir -p "${HDFS_BASE}/processed/hive"
hdfs dfs -mkdir -p "${HDFS_BASE}/processed/pig"

# Sqoop directories
hdfs dfs -mkdir -p "${HDFS_BASE}/sqoop/imports"
hdfs dfs -mkdir -p "${HDFS_BASE}/sqoop/exports"

# Mahout directories
hdfs dfs -mkdir -p "${HDFS_BASE}/mahout/input"
hdfs dfs -mkdir -p "${HDFS_BASE}/mahout/output"

# Recommendation output
hdfs dfs -mkdir -p "${HDFS_BASE}/recommendations/output"

echo ""
echo "[OK] HDFS directory structure created successfully."
echo ""

# ---- Display the created structure ----
echo "============================================================"
echo "  HDFS Directory Structure"
echo "============================================================"
hdfs dfs -ls -R "${HDFS_BASE}" 2>/dev/null || echo "[WARN] Directory listing returned empty (directories exist but are empty)"

echo ""
echo "============================================================"
echo "  HDFS Storage Summary"
echo "============================================================"
hdfs dfs -du -h "${HDFS_BASE}" 2>/dev/null || echo "[INFO] No data uploaded yet"

echo ""
echo "[OK] Done. Next step: Upload data using upload_to_hdfs.sh"
