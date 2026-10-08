#!/bin/bash
# ============================================================
# Big Data Movie Recommender - Sqoop Import to Hive
# ============================================================
# Imports movie data from MySQL directly into a Hive table.
#
# Demonstrates: SQL → Hive data transfer
#
# Environment: [SQOOP] — Cloudera VM
# Usage:
#   bash sqoop/import_to_hive.sh
#
# Prerequisites:
#   1. MySQL movie_summary table exists with data
#   2. Hive movie_recommender database exists
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

echo "============================================================"
echo "  Sqoop Import: MySQL → Hive"
echo "============================================================"
echo "  MySQL     : ${MYSQL_USER}@${MYSQL_HOST}:${MYSQL_PORT}/${MYSQL_DATABASE}"
echo "  Hive DB   : movie_recommender"
echo "  Hive Table: movie_summary_imported"
echo "============================================================"

# ---- Check Sqoop availability ----
if ! command -v sqoop &> /dev/null; then
    echo "[ERR] Sqoop command not found."
    echo "      Run this script inside the Cloudera VM where Sqoop is installed."
    exit 1
fi

# ---- Run Sqoop Import to Hive ----
echo "[INFO] Running Sqoop import to Hive..."

sqoop import \
    --connect "jdbc:mysql://${MYSQL_HOST}:${MYSQL_PORT}/${MYSQL_DATABASE}" \
    --username "${MYSQL_USER}" \
    --password "${MYSQL_PASSWORD}" \
    --table movie_summary \
    --hive-import \
    --hive-database movie_recommender \
    --hive-table movie_summary_imported \
    --hive-overwrite \
    --fields-terminated-by '\t' \
    --num-mappers 1 \
    --null-string '' \
    --null-non-string ''

# ---- Verify ----
echo ""
echo "[INFO] Verifying Hive import..."
echo ""
hive -e "USE movie_recommender; SELECT COUNT(*) FROM movie_summary_imported;" 2>/dev/null || \
    echo "[WARN] Could not verify. Check manually: hive -e 'USE movie_recommender; SELECT * FROM movie_summary_imported LIMIT 5;'"

echo ""
echo "[OK] Sqoop import to Hive complete: MySQL movie_summary → Hive movie_summary_imported"
