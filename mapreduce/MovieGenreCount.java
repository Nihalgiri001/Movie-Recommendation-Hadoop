/**
 * ============================================================
 * Big Data Movie Recommender - Movie Genre Count MapReduce
 * ============================================================
 * Counts the number of movies in each genre.
 *
 * Input: movie_genres.tsv (movie_id\tgenre)
 * Output: genre\tcount
 *
 * Environment: [CLOUDERA]
 *
 * Compilation:
 *   cd mapreduce
 *   javac -classpath $(hadoop classpath) -d . MovieGenreCount.java
 *   jar -cvf genrecount.jar MovieGenreCount*.class
 *
 * Execution:
 *   HDFS_USER=$(whoami)
 *   INPUT=/user/${HDFS_USER}/movie_recommender/processed/genres/movie_genres.tsv
 *   OUTPUT=/user/${HDFS_USER}/movie_recommender/processed/mapreduce/genre_count
 *   hdfs dfs -rm -r -f ${OUTPUT}
 *   hadoop jar genrecount.jar MovieGenreCount ${INPUT} ${OUTPUT}
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

public class MovieGenreCount {

    /**
     * Mapper: Reads genre records and emits (genre, 1).
     * Input format: movie_id\tgenre (TSV)
     */
    public static class GenreMapper
            extends Mapper<LongWritable, Text, Text, IntWritable> {

        private final static IntWritable one = new IntWritable(1);
        private Text genre = new Text();
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

            // Parse TSV: movie_id\tgenre
            String[] parts = line.split("\t");
            if (parts.length >= 2) {
                String genreName = parts[1].trim();
                if (!genreName.isEmpty()) {
                    genre.set(genreName);
                    context.write(genre, one);
                }
            }
        }
    }

    /**
     * Reducer: Sums the count for each genre.
     */
    public static class GenreCountReducer
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
            System.err.println("Usage: MovieGenreCount <input path> <output path>");
            System.exit(1);
        }

        Configuration conf = new Configuration();
        Job job = Job.getInstance(conf, "Movie Genre Count");
        job.setJarByClass(MovieGenreCount.class);
        job.setMapperClass(GenreMapper.class);
        job.setCombinerClass(GenreCountReducer.class);
        job.setReducerClass(GenreCountReducer.class);
        job.setOutputKeyClass(Text.class);
        job.setOutputValueClass(IntWritable.class);

        FileInputFormat.addInputPath(job, new Path(args[0]));
        FileOutputFormat.setOutputPath(job, new Path(args[1]));

        System.exit(job.waitForCompletion(true) ? 0 : 1);
    }
}
