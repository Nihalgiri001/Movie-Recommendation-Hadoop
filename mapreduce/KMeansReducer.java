/**
 * ============================================================
 * Big Data Movie Recommender - K-Means Reducer
 * ============================================================
 * Reducer for K-Means clustering of movies.
 *
 * The reducer:
 *   1. Receives all data points assigned to a centroid
 *   2. Computes the new centroid (mean of all points)
 *   3. Emits the updated centroid
 *
 * Environment: [CLOUDERA]
 *
 * Full K-Means Compilation and Execution:
 *   cd mapreduce
 *   javac -classpath $(hadoop classpath) -d . KMeansMapper.java KMeansReducer.java
 *   jar -cvf kmeans.jar KMeansMapper*.class KMeansReducer*.class
 *
 *   # Create initial centroids file
 *   # Format: centroid_id\tfeature1,feature2
 *   echo -e "0\t0.3,0.1\n1\t0.6,0.5\n2\t0.8,0.9" > centroids.txt
 *   hdfs dfs -put -f centroids.txt /user/$(whoami)/movie_recommender/mahout/input/
 *
 *   HDFS_USER=$(whoami)
 *   INPUT=/user/${HDFS_USER}/movie_recommender/processed/movies/movies.tsv
 *   OUTPUT=/user/${HDFS_USER}/movie_recommender/processed/mapreduce/kmeans
 *   CENTROIDS=/user/${HDFS_USER}/movie_recommender/mahout/input/centroids.txt
 *   hdfs dfs -rm -r -f ${OUTPUT}
 *
 *   hadoop jar kmeans.jar KMeansReducer \
 *     -Dcentroids.path=centroids.txt \
 *     -files centroids.txt \
 *     ${INPUT} ${OUTPUT}
 *
 * View Output:
 *   hdfs dfs -cat ${OUTPUT}/part-r-00000
 *
 * Iteration Process:
 *   Each run produces new centroids. To iterate:
 *   1. Extract new centroids from output
 *   2. Update centroids.txt
 *   3. Re-run the job
 *   Repeat until centroids converge (minimal change).
 * ============================================================
 */

import java.io.IOException;

import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.fs.Path;
import org.apache.hadoop.io.IntWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Job;
import org.apache.hadoop.mapreduce.Reducer;
import org.apache.hadoop.mapreduce.lib.input.FileInputFormat;
import org.apache.hadoop.mapreduce.lib.output.FileOutputFormat;

public class KMeansReducer extends Reducer<IntWritable, Text, IntWritable, Text> {

    /**
     * Reduce: Compute new centroid for each cluster.
     *
     * Input: centroid_id -> [feature_vector_1, feature_vector_2, ...]
     * Output: centroid_id -> new_centroid_features,point_count
     */
    @Override
    public void reduce(IntWritable key, Iterable<Text> values, Context context)
            throws IOException, InterruptedException {

        double[] sumFeatures = null;
        int count = 0;

        for (Text val : values) {
            String[] features = val.toString().split(",");
            if (sumFeatures == null) {
                sumFeatures = new double[features.length];
            }

            for (int i = 0; i < features.length; i++) {
                try {
                    sumFeatures[i] += Double.parseDouble(features[i].trim());
                } catch (NumberFormatException e) {
                    // Skip invalid values
                }
            }
            count++;
        }

        if (sumFeatures != null && count > 0) {
            // Compute mean (new centroid)
            StringBuilder sb = new StringBuilder();
            for (int i = 0; i < sumFeatures.length; i++) {
                if (i > 0) sb.append(",");
                sb.append(String.format("%.6f", sumFeatures[i] / count));
            }
            sb.append(",count=").append(count);

            context.write(key, new Text(sb.toString()));
        }
    }

    /**
     * Driver for the K-Means MapReduce job.
     *
     * This runs a SINGLE iteration of K-Means.
     * For full convergence, run this job multiple times
     * and update the centroids file between iterations.
     */
    public static void main(String[] args) throws Exception {
        if (args.length != 2) {
            System.err.println("Usage: KMeansReducer <input path> <output path>");
            System.err.println("");
            System.err.println("Before running, set centroids.path configuration:");
            System.err.println("  hadoop jar kmeans.jar KMeansReducer \\");
            System.err.println("    -Dcentroids.path=centroids.txt \\");
            System.err.println("    -files centroids.txt \\");
            System.err.println("    <input> <output>");
            System.exit(1);
        }

        Configuration conf = new Configuration();
        Job job = Job.getInstance(conf, "Movie K-Means Clustering");
        job.setJarByClass(KMeansReducer.class);
        job.setMapperClass(KMeansMapper.class);
        job.setReducerClass(KMeansReducer.class);

        job.setMapOutputKeyClass(IntWritable.class);
        job.setMapOutputValueClass(Text.class);
        job.setOutputKeyClass(IntWritable.class);
        job.setOutputValueClass(Text.class);

        FileInputFormat.addInputPath(job, new Path(args[0]));
        FileOutputFormat.setOutputPath(job, new Path(args[1]));

        System.exit(job.waitForCompletion(true) ? 0 : 1);
    }
}
