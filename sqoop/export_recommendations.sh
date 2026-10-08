#!/bin/bash
# ============================================================
# Big Data Movie Recommender - Sqoop Export (HDFS/Hive → MySQL)
# ============================================================
# Exports recommendation results from HDFS back to MySQL.
#
# Demonstrates: HDFS/Hive → SQL data transfer
#
# Environment: [SQOOP] — Cloudera VM
# Usage:
#   bash sqoop/export_recommendations.sh
#
# Prerequisites:
#   1. MySQL recommendations table exists
#   2. Recommendation output has been generated and stored in HDFS
#      or a TSV file exists at output/recommendations_export.tsv
# ============================================================

set -euo pipefail

# ---- Determine project root ----
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# ---- Load configuration ----
CONFIG_FILE="${PROJECT_ROOT}/config/config.env"
if [ -f "$CONFIG_FILE" ]; then
    source "$CONFIG_FILE"
fi

# ---- Configurable variables ----
MYSQL_HOST="${MYSQL_HOST:-localhost}"
MYSQL_PORT="${MYSQL_PORT:-3306}"
MYSQL_DATABASE="${MYSQL_DATABASE:-movie_recommender}"
MYSQL_USER="${MYSQL_USER:-root}"
MYSQL_PASSWORD="${MYSQL_PASSWORD:-cloudera}"

HDFS_USER="${HDFS_USER:-$(whoami)}"
HDFS_BASE="/user/${HDFS_USER}/movie_recommender"
EXPORT_SOURCE="${HDFS_BASE}/recommendations/output"

echo "============================================================"
echo "  Sqoop Export: HDFS → MySQL"
echo "============================================================"
echo "  Source    : ${EXPORT_SOURCE}"
echo "  MySQL     : ${MYSQL_USER}@${MYSQL_HOST}:${MYSQL_PORT}/${MYSQL_DATABASE}"
echo "  Table     : recommendations"
echo "============================================================"

# ---- Check Sqoop availability ----
if ! command -v sqoop &> /dev/null; then
    echo "[ERR] Sqoop command not found."
    echo "      Run this script inside the Cloudera VM where Sqoop is installed."
    exit 1
fi

# ---- Check if export data exists in HDFS ----
if ! hdfs dfs -test -d "${EXPORT_SOURCE}" 2>/dev/null; then
    echo "[WARN] Export source not found in HDFS: ${EXPORT_SOURCE}"
    echo ""
    echo "  To prepare export data, generate recommendations and upload:"
    echo ""
    echo "    # Generate recommendations"
    echo "    python3 python/recommendation_app.py --movie \"Batman\" > output/recs.tsv"
    echo ""
    echo "    # Upload to HDFS"
    echo "    hdfs dfs -mkdir -p ${EXPORT_SOURCE}"
    echo "    hdfs dfs -put output/recs.tsv ${EXPORT_SOURCE}/"
    echo ""

    # Check for local file as fallback
    LOCAL_EXPORT="${PROJECT_ROOT}/output/recommendations_export.tsv"
    if [ -f "$LOCAL_EXPORT" ]; then
        echo "[INFO] Found local export file. Uploading to HDFS first..."
        hdfs dfs -mkdir -p "${EXPORT_SOURCE}"
        hdfs dfs -put -f "$LOCAL_EXPORT" "${EXPORT_SOURCE}/"
        echo "[OK]   Uploaded to HDFS"
    else
        echo "[ERR] No export data available. Generate recommendations first."
        exit 1
    fi
fi

# ---- Run Sqoop Export ----
echo "[INFO] Running Sqoop export..."

sqoop export \
    --connect "jdbc:mysql://${MYSQL_HOST}:${MYSQL_PORT}/${MYSQL_DATABASE}" \
    --username "${MYSQL_USER}" \
    --password "${MYSQL_PASSWORD}" \
    --table recommendations \
    --export-dir "${EXPORT_SOURCE}" \
    --input-fields-terminated-by '\t' \
    --input-lines-terminated-by '\n' \
    --columns "input_movie,recommended_movie,similarity_score,rank_position" \
    --num-mappers 1

# ---- Verify ----
echo ""
echo "[INFO] Verifying export..."
mysql -h "${MYSQL_HOST}" -P "${MYSQL_PORT}" -u "${MYSQL_USER}" -p"${MYSQL_PASSWORD}" \
    -e "USE ${MYSQL_DATABASE}; SELECT COUNT(*) AS exported_rows FROM recommendations;" 2>/dev/null || \
    echo "[WARN] Could not verify. Check manually in MySQL."

echo ""
echo "[OK] Sqoop export complete: HDFS → MySQL recommendations"
