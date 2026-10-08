/**
 * ============================================================
 * Big Data Movie Recommender - WordCount MapReduce
 * ============================================================
 * Counts word occurrences in movie tags/overview data.
 * 
 * This is a classic Hadoop MapReduce demonstration that
 * tokenizes movie descriptions and counts word frequencies.
 *
 * Environment: [CLOUDERA]
 *
 * Compilation:
 *   cd mapreduce
 *   javac -classpath $(hadoop classpath) -d . WordCount.java
 *   jar -cvf wordcount.jar WordCount*.class
 *
 * Execution:
 *   HDFS_USER=$(whoami)
 *   INPUT=/user/${HDFS_USER}/movie_recommender/processed/tags/movie_tags.tsv
 *   OUTPUT=/user/${HDFS_USER}/movie_recommender/processed/mapreduce/wordcount
 *   hdfs dfs -rm -r -f ${OUTPUT}
 *   hadoop jar wordcount.jar WordCount ${INPUT} ${OUTPUT}
 *
 * View Output:
 *   hdfs dfs -cat ${OUTPUT}/part-r-00000 | head -20
 * ============================================================
 */

import java.io.IOException;
import java.util.StringTokenizer;

import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.fs.Path;
import org.apache.hadoop.io.IntWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Job;
import org.apache.hadoop.mapreduce.Mapper;
import org.apache.hadoop.mapreduce.Reducer;
import org.apache.hadoop.mapreduce.lib.input.FileInputFormat;
import org.apache.hadoop.mapreduce.lib.output.FileOutputFormat;

public class WordCount {

    /**
     * Mapper: Tokenizes each line and emits (word, 1) pairs.
     * Skips the header line and extracts the tags column (3rd column in TSV).
     */
    public static class TokenizerMapper
            extends Mapper<Object, Text, Text, IntWritable> {

        private final static IntWritable one = new IntWritable(1);
        private Text word = new Text();
        private boolean headerSkipped = false;

        public void map(Object key, Text value, Context context)
                throws IOException, InterruptedException {

            String line = value.toString();

            // Skip header line
            if (!headerSkipped) {
                if (line.startsWith("movie_id") || line.startsWith("\"movie_id")) {
                    headerSkipped = true;
                    return;
                }
                headerSkipped = true;
            }

            // Extract tags field (3rd column in TSV: movie_id, title, tags)
            String[] parts = line.split("\t", 3);
            String text;
            if (parts.length >= 3) {
                text = parts[2]; // tags column
            } else {
                text = line;
            }

            // Tokenize and emit
            text = text.toLowerCase().replaceAll("[^a-z0-9\\s]", " ");
            StringTokenizer tokenizer = new StringTokenizer(text);
            while (tokenizer.hasMoreTokens()) {
                String token = tokenizer.nextToken().trim();
                if (token.length() > 1) { // Skip single characters
                    word.set(token);
                    context.write(word, one);
                }
            }
        }
    }

    /**
     * Reducer: Sums up counts for each word.
     */
    public static class IntSumReducer
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
            System.err.println("Usage: WordCount <input path> <output path>");
            System.exit(1);
        }

        Configuration conf = new Configuration();
        Job job = Job.getInstance(conf, "Movie Word Count");
        job.setJarByClass(WordCount.class);
        job.setMapperClass(TokenizerMapper.class);
        job.setCombinerClass(IntSumReducer.class);
        job.setReducerClass(IntSumReducer.class);
        job.setOutputKeyClass(Text.class);
        job.setOutputValueClass(IntWritable.class);

        FileInputFormat.addInputPath(job, new Path(args[0]));
        FileOutputFormat.setOutputPath(job, new Path(args[1]));

        System.exit(job.waitForCompletion(true) ? 0 : 1);
    }
}
