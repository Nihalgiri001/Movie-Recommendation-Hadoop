/**
 * ============================================================
 * Big Data Movie Recommender - K-Means Mapper
 * ============================================================
 * Mapper for K-Means clustering of movies.
 *
 * Features used for clustering:
 *   - vote_average (normalized)
 *   - popularity (normalized)
 *
 * The mapper:
 *   1. Reads initial/updated centroids from distributed cache
 *   2. For each movie, computes Euclidean distance to all centroids
 *   3. Assigns the movie to the nearest centroid
 *   4. Emits (centroid_id, feature_vector)
 *
 * Environment: [CLOUDERA]
 * ============================================================
 */

import java.io.BufferedReader;
import java.io.FileReader;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

import org.apache.hadoop.io.IntWritable;
import org.apache.hadoop.io.LongWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Mapper;

public class KMeansMapper extends Mapper<LongWritable, Text, IntWritable, Text> {

    private List<double[]> centroids = new ArrayList<>();
    private boolean headerSkipped = false;

    /**
     * Load centroids from the distributed cache file.
     * Centroid format: centroid_id\tfeature1,feature2
     */
    @Override
    protected void setup(Context context) throws IOException, InterruptedException {
        // Read centroids file from distributed cache
        String centroidsPath = context.getConfiguration().get("centroids.path");
        if (centroidsPath != null) {
            BufferedReader reader = new BufferedReader(new FileReader(centroidsPath));
            String line;
            while ((line = reader.readLine()) != null) {
                line = line.trim();
                if (line.isEmpty() || line.startsWith("#")) continue;

                String[] parts = line.split("\t");
                if (parts.length >= 2) {
                    String[] features = parts[1].split(",");
                    double[] centroid = new double[features.length];
                    for (int i = 0; i < features.length; i++) {
                        centroid[i] = Double.parseDouble(features[i].trim());
                    }
                    centroids.add(centroid);
                }
            }
            reader.close();
        }

        if (centroids.isEmpty()) {
            throw new IOException("No centroids loaded. Check centroids file.");
        }
    }

    /**
     * Map: Assign each movie to the nearest centroid.
     *
     * Input: movies.tsv (movie_id, title, overview, release_date,
     *        release_year, vote_average, vote_count, popularity,
     *        original_language, runtime, revenue)
     *
     * Features extracted: vote_average (index 5), popularity (index 7)
     */
    @Override
    public void map(LongWritable key, Text value, Context context)
            throws IOException, InterruptedException {

        String line = value.toString().trim();
        if (line.isEmpty()) return;

        // Skip header
        if (!headerSkipped) {
            if (line.startsWith("movie_id")) {
                headerSkipped = true;
                return;
            }
            headerSkipped = true;
        }

        String[] parts = line.split("\t");
        if (parts.length < 8) return;

        try {
            double voteAvg = Double.parseDouble(parts[5].trim());
            double popularity = Double.parseDouble(parts[7].trim());

            // Normalize features (simple min-max scaling)
            // vote_average: 0-10, popularity: 0-1000+ (cap at 100 for scaling)
            double normVote = voteAvg / 10.0;
            double normPop = Math.min(popularity, 100.0) / 100.0;

            double[] point = {normVote, normPop};

            // Find nearest centroid
            int nearestIdx = 0;
            double minDist = Double.MAX_VALUE;

            for (int i = 0; i < centroids.size(); i++) {
                double dist = euclideanDistance(point, centroids.get(i));
                if (dist < minDist) {
                    minDist = dist;
                    nearestIdx = i;
                }
            }

            // Emit: centroid_id -> feature_vector
            String featureStr = normVote + "," + normPop;
            context.write(new IntWritable(nearestIdx), new Text(featureStr));

        } catch (NumberFormatException e) {
            // Skip records with invalid numeric values
        }
    }

    /**
     * Compute Euclidean distance between two points.
     */
    private double euclideanDistance(double[] a, double[] b) {
        double sum = 0;
        int len = Math.min(a.length, b.length);
        for (int i = 0; i < len; i++) {
            sum += (a[i] - b[i]) * (a[i] - b[i]);
        }
        return Math.sqrt(sum);
    }
}
