/**
 * ============================================================
 * Big Data Movie Recommender - Movie Year Count MapReduce
 * ============================================================
 * Counts the number of movies released per year.
 *
 * Input: movies.tsv
 * Output: year\tmovie_count
 *
 * Handles missing/invalid dates safely.
 *
 * Environment: [CLOUDERA]
 *
 * Compilation:
 *   cd mapreduce
 *   javac -classpath $(hadoop classpath) -d . MovieYearCount.java
 *   jar -cvf yearcount.jar MovieYearCount*.class
 *
 * Execution:
 *   HDFS_USER=$(whoami)
 *   INPUT=/user/${HDFS_USER}/movie_recommender/processed/movies/movies.tsv
 *   OUTPUT=/user/${HDFS_USER}/movie_recommender/processed/mapreduce/year_count
 *   hdfs dfs -rm -r -f ${OUTPUT}
 *   hadoop jar yearcount.jar MovieYearCount ${INPUT} ${OUTPUT}
 *
 * View Output:
 *   hdfs dfs -cat ${OUTPUT}/part-r-00000
 * ============================================================
 */

import java.io.IOException;

import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.fs.Path;
import org.apache.hadoop.io.IntWritable;
import org.apache.hadoop.io.LongWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Job;
import org.apache.hadoop.mapreduce.Mapper;
import org.apache.hadoop.mapreduce.Reducer;
import org.apache.hadoop.mapreduce.lib.input.FileInputFormat;
import org.apache.hadoop.mapreduce.lib.output.FileOutputFormat;

public class MovieYearCount {

    /**
     * Mapper: Extracts release year from movies.tsv and emits (year, 1).
     * movies.tsv columns: movie_id, title, overview, release_date,
     *                     release_year, vote_average, vote_count,
     *                     popularity, original_language, runtime, revenue
     * release_year is at index 4 (0-based).
     */
    public static class YearMapper
            extends Mapper<LongWritable, Text, Text, IntWritable> {

        private final static IntWritable one = new IntWritable(1);
        private Text yearText = new Text();
        private boolean headerSkipped = false;

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

            // Parse TSV
            String[] parts = line.split("\t");
            if (parts.length >= 5) {
                String year = parts[4].trim(); // release_year column

                // Validate year
                if (!year.isEmpty()) {
                    try {
                        int yearInt = Integer.parseInt(year);
                        if (yearInt >= 1800 && yearInt <= 2030) {
                            yearText.set(year);
                            context.write(yearText, one);
                        }
                    } catch (NumberFormatException e) {
                        // Skip invalid years
                    }
                }
            }
        }
    }

    /**
     * Reducer: Sums the movie count for each year.
     */
    public static class YearCountReducer
            extends Reducer<Text, IntWritable, Text, IntWritable> {

        private IntWritable result = new IntWritable();

        public void reduce(Text key, Iterable<IntWritable> values, Context context)
                throws IOException, InterruptedException {
            int sum = 0;
            for (IntWritable val : values) {
                sum += val.get();
            }
            result.set(sum);
            context.write(key, result);
        }
    }

    public static void main(String[] args) throws Exception {
        if (args.length != 2) {
            System.err.println("Usage: MovieYearCount <input path> <output path>");
            System.exit(1);
        }

        Configuration conf = new Configuration();
        Job job = Job.getInstance(conf, "Movie Year Count");
        job.setJarByClass(MovieYearCount.class);
        job.setMapperClass(YearMapper.class);
        job.setCombinerClass(YearCountReducer.class);
        job.setReducerClass(YearCountReducer.class);
        job.setOutputKeyClass(Text.class);
        job.setOutputValueClass(IntWritable.class);

        FileInputFormat.addInputPath(job, new Path(args[0]));
        FileOutputFormat.setOutputPath(job, new Path(args[1]));

        System.exit(job.waitForCompletion(true) ? 0 : 1);
    }
}
