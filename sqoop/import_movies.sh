#!/bin/bash
# ============================================================
# Big Data Movie Recommender - Sqoop Import (MySQL → HDFS)
# ============================================================
# Imports movie data from MySQL to HDFS using Sqoop.
#
# Demonstrates: SQL → HDFS data transfer
#
# Environment: [SQOOP] — Cloudera VM
# Usage:
#   bash sqoop/import_movies.sh
#
# Prerequisites:
#   1. MySQL is running (Cloudera QuickStart has MySQL pre-installed)
#   2. MySQL tables created: mysql -u root -p < sqoop/create_mysql_tables.sql
#   3. Data loaded into MySQL movie_summary table
# ============================================================

set -euo pipefail

# ---- Determine project root ----
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# ---- Load configuration ----
# Source config if available, otherwise use defaults
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
SQOOP_TARGET="${HDFS_BASE}/sqoop/imports/movie_summary"

echo "============================================================"
echo "  Sqoop Import: MySQL → HDFS"
echo "============================================================"
echo "  MySQL     : ${MYSQL_USER}@${MYSQL_HOST}:${MYSQL_PORT}/${MYSQL_DATABASE}"
echo "  HDFS Path : ${SQOOP_TARGET}"
echo "============================================================"

# ---- Check Sqoop availability ----
if ! command -v sqoop &> /dev/null; then
    echo "[ERR] Sqoop command not found."
    echo "      Run this script inside the Cloudera VM where Sqoop is installed."
    exit 1
fi

# ---- Remove existing HDFS output ----
echo "[INFO] Cleaning previous import (if any)..."
hdfs dfs -rm -r -f "${SQOOP_TARGET}" 2>/dev/null || true

# ---- Run Sqoop Import ----
echo "[INFO] Running Sqoop import..."

sqoop import \
    --connect "jdbc:mysql://${MYSQL_HOST}:${MYSQL_PORT}/${MYSQL_DATABASE}" \
    --username "${MYSQL_USER}" \
    --password "${MYSQL_PASSWORD}" \
    --table movie_summary \
    --target-dir "${SQOOP_TARGET}" \
    --fields-terminated-by '\t' \
    --lines-terminated-by '\n' \
    --num-mappers 1 \
    --null-string '' \
    --null-non-string ''

# ---- Verify ----
echo ""
echo "[INFO] Verifying import..."
echo ""
echo "  HDFS listing:"
hdfs dfs -ls "${SQOOP_TARGET}" 2>/dev/null || echo "  (no files found)"
echo ""
echo "  Preview (first 5 lines):"
hdfs dfs -cat "${SQOOP_TARGET}/part-m-00000" 2>/dev/null | head -5 || echo "  (no data)"
echo ""
echo "[OK] Sqoop import complete: MySQL movie_summary → HDFS"
