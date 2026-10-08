#!/bin/bash
# ============================================================
# Big Data Movie Recommender - Mahout Clustering Commands
# ============================================================
# Demonstrates Apache Mahout K-Means clustering on movie data.
#
# IMPORTANT:
#   Mahout availability varies across Cloudera versions.
#   This script checks for Mahout and provides commands
#   appropriate for the detected version.
#
#   If Mahout is NOT available, the project still functions
#   fully — the MapReduce K-Means implementation (mapreduce/)
#   serves as the clustering demonstration.
#
# Environment: [MAHOUT] — Cloudera VM
# Usage:
#   bash mahout/clustering_commands.sh
# ============================================================

set -euo pipefail

# ---- Determine project root ----
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# ---- Determine HDFS user ----
HDFS_USER="${HDFS_USER:-$(whoami)}"
HDFS_BASE="/user/${HDFS_USER}/movie_recommender"

echo "============================================================"
echo "  Mahout Clustering — Movie Data"
echo "============================================================"

# ---- Step 1: Check Mahout availability ----
if ! command -v mahout &> /dev/null; then
    echo "[WARN] Mahout command not found on this system."
    echo ""
    echo "  Mahout may not be installed in this Cloudera version."
    echo "  The project includes a MapReduce K-Means implementation"
    echo "  as an alternative clustering demonstration."
    echo ""
    echo "  See: mapreduce/KMeansMapper.java and mapreduce/KMeansReducer.java"
    echo ""
    echo "  To install Mahout (if supported by your Cloudera version):"
    echo "    sudo yum install mahout"
    echo "    or"
    echo "    sudo apt-get install mahout"
    echo ""
    exit 0
fi

# ---- Step 2: Detect Mahout version ----
echo "[INFO] Detected Mahout installation."
echo ""
mahout version 2>/dev/null || echo "[INFO] Mahout version command not available"
echo ""

# ---- Step 3: Prepare input data ----
echo "[INFO] Preparing input data for Mahout..."

MAHOUT_INPUT="${HDFS_BASE}/mahout/input"
MAHOUT_OUTPUT="${HDFS_BASE}/mahout/output/kmeans"

# Create a sequence file from movie features
# Mahout requires input in a specific vector format
# We use a simple CSV with numeric features:
#   vote_average, popularity (normalized)

FEATURES_FILE="${PROJECT_ROOT}/output/mahout_features.csv"

if [ -f "${PROJECT_ROOT}/data/processed/movies.tsv" ]; then
    echo "[INFO] Generating feature vectors from movies.tsv..."

    # Extract numeric features (vote_average, popularity)
    # Skip header, extract columns 6 and 8 (1-indexed)
    tail -n +2 "${PROJECT_ROOT}/data/processed/movies.tsv" | \
        awk -F'\t' '{
            if ($6 != "" && $8 != "") {
                # Normalize: vote_avg/10, popularity/100 (capped)
                va = $6 / 10.0;
                pop = ($8 > 100 ? 1.0 : $8 / 100.0);
                printf "%s,%s\n", va, pop
            }
        }' > "$FEATURES_FILE"

    echo "[OK]   Generated feature vectors: $FEATURES_FILE"
    echo "       Total vectors: $(wc -l < "$FEATURES_FILE")"
else
    echo "[WARN] movies.tsv not found. Run preprocessing first."
    exit 1
fi

# Upload to HDFS
hdfs dfs -mkdir -p "${MAHOUT_INPUT}"
hdfs dfs -put -f "$FEATURES_FILE" "${MAHOUT_INPUT}/features.csv"
echo "[OK]   Uploaded features to HDFS: ${MAHOUT_INPUT}/features.csv"

# ---- Step 4: Run Mahout K-Means ----
echo ""
echo "============================================================"
echo "  Running Mahout K-Means Clustering (K=3)"
echo "============================================================"
echo ""

# Clean previous output
hdfs dfs -rm -r -f "${MAHOUT_OUTPUT}" 2>/dev/null || true

# Mahout K-Means command
# NOTE: The exact command depends on the Mahout version.
# Cloudera QuickStart typically includes Mahout 0.9 or similar.

echo "[INFO] Attempting Mahout K-Means..."
echo ""
echo "  Command:"
echo "    mahout kmeans \\"
echo "      -i ${MAHOUT_INPUT} \\"
echo "      -c ${MAHOUT_OUTPUT}/initial-centroids \\"
echo "      -o ${MAHOUT_OUTPUT}/clusters \\"
echo "      -k 3 \\"
echo "      -x 10 \\"
echo "      -dm org.apache.mahout.common.distance.EuclideanDistanceMeasure \\"
echo "      -cl"
echo ""

# Try running Mahout K-Means
# If the command fails, provide fallback instructions
mahout kmeans \
    -i "${MAHOUT_INPUT}" \
    -c "${MAHOUT_OUTPUT}/initial-centroids" \
    -o "${MAHOUT_OUTPUT}/clusters" \
    -k 3 \
    -x 10 \
    -dm org.apache.mahout.common.distance.EuclideanDistanceMeasure \
    -cl 2>&1 || {
    echo ""
    echo "[WARN] Mahout K-Means command failed."
    echo ""
    echo "  This may be due to:"
    echo "    1. Input format incompatibility (Mahout may require SequenceFile)"
    echo "    2. Version-specific command syntax differences"
    echo "    3. Missing Mahout dependencies"
    echo ""
    echo "  Alternative: Use the MapReduce K-Means implementation:"
    echo "    cd mapreduce"
    echo "    javac -classpath \$(hadoop classpath) -d . KMeansMapper.java KMeansReducer.java"
    echo "    jar -cvf kmeans.jar KMeansMapper*.class KMeansReducer*.class"
    echo "    hadoop jar kmeans.jar KMeansReducer -Dcentroids.path=centroids.txt ..."
    echo ""
    echo "  See mapreduce/README.md for full instructions."
    exit 0
}

# ---- Step 5: View Results ----
echo ""
echo "============================================================"
echo "  Mahout K-Means Results"
echo "============================================================"
echo ""
echo "[INFO] Output directory:"
hdfs dfs -ls "${MAHOUT_OUTPUT}/" 2>/dev/null || echo "  (empty)"

echo ""
echo "[INFO] Cluster dump (if available):"
mahout clusterdump \
    -i "${MAHOUT_OUTPUT}/clusters" \
    -o "${PROJECT_ROOT}/output/mahout_clusters.txt" \
    -p "${MAHOUT_OUTPUT}/clusters/clusteredPoints" 2>/dev/null || \
    echo "[WARN] Could not dump clusters. View output manually."

echo ""
echo "[OK] Mahout clustering complete."
