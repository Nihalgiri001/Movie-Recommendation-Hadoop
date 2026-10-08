/**
 * ============================================================
 * Big Data Movie Recommender - Frequent Words MapReduce
 * ============================================================
 * Identifies the most frequent words in movie descriptions/tags.
 *
 * This program takes the output of WordCount and sorts it by
 * frequency to find the most common terms in the movie corpus.
 *
 * Environment: [CLOUDERA]
 *
 * Compilation:
 *   cd mapreduce
 *   javac -classpath $(hadoop classpath) -d . FrequentWords.java
 *   jar -cvf frequentwords.jar FrequentWords*.class
 *
 * Execution:
 *   HDFS_USER=$(whoami)
 *   INPUT=/user/${HDFS_USER}/movie_recommender/processed/mapreduce/wordcount
 *   OUTPUT=/user/${HDFS_USER}/movie_recommender/processed/mapreduce/frequent_words
 *   hdfs dfs -rm -r -f ${OUTPUT}
 *   hadoop jar frequentwords.jar FrequentWords ${INPUT} ${OUTPUT}
 *
 * View Output:
 *   hdfs dfs -cat ${OUTPUT}/part-r-00000 | head -20
 * ============================================================
 */

import java.io.IOException;
import java.util.TreeMap;
import java.util.Map;

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

public class FrequentWords {

    /**
     * Mapper: Reads word-count pairs and emits (count, word) to sort by frequency.
     * Uses a local top-N buffer to reduce data sent to the reducer.
     */
    public static class FrequencyMapper
            extends Mapper<LongWritable, Text, IntWritable, Text> {

        private TreeMap<Integer, String> topWords = new TreeMap<>();
        private static final int TOP_N = 100;

        public void map(LongWritable key, Text value, Context context)
                throws IOException, InterruptedException {

            String line = value.toString().trim();
            if (line.isEmpty()) return;

            // Input format: word\tcount
            String[] parts = line.split("\t");
            if (parts.length == 2) {
                try {
                    String word = parts[0].trim();
                    int count = Integer.parseInt(parts[1].trim());

                    topWords.put(count, word);

                    // Keep only top N in memory
                    if (topWords.size() > TOP_N) {
                        topWords.remove(topWords.firstKey());
                    }
                } catch (NumberFormatException e) {
                    // Skip malformed lines
                }
            }
        }

        @Override
        protected void cleanup(Context context)
                throws IOException, InterruptedException {
            for (Map.Entry<Integer, String> entry : topWords.entrySet()) {
                context.write(
                    new IntWritable(entry.getKey()),
                    new Text(entry.getValue())
                );
            }
        }
    }

    /**
     * Reducer: Collects and outputs the top N most frequent words.
     * Output is sorted by frequency (descending).
     */
    public static class FrequencyReducer
            extends Reducer<IntWritable, Text, Text, IntWritable> {

        private TreeMap<Integer, String> topWords = new TreeMap<>();
        private static final int TOP_N = 50;

        public void reduce(IntWritable key, Iterable<Text> values, Context context)
                throws IOException, InterruptedException {
            for (Text val : values) {
                topWords.put(key.get(), val.toString());

                if (topWords.size() > TOP_N) {
                    topWords.remove(topWords.firstKey());
                }
            }
        }

        @Override
        protected void cleanup(Context context)
                throws IOException, InterruptedException {
            // Output in descending order of frequency
            for (Map.Entry<Integer, String> entry : topWords.descendingMap().entrySet()) {
                context.write(
                    new Text(entry.getValue()),
                    new IntWritable(entry.getKey())
                );
            }
        }
    }

    public static void main(String[] args) throws Exception {
        if (args.length != 2) {
            System.err.println("Usage: FrequentWords <input path> <output path>");
            System.err.println("  Input should be the output of WordCount.");
            System.exit(1);
        }

        Configuration conf = new Configuration();
        Job job = Job.getInstance(conf, "Most Frequent Words in Movies");
        job.setJarByClass(FrequentWords.class);
        job.setMapperClass(FrequencyMapper.class);
        job.setReducerClass(FrequencyReducer.class);

        // Mapper output types
        job.setMapOutputKeyClass(IntWritable.class);
        job.setMapOutputValueClass(Text.class);

        // Final output types
        job.setOutputKeyClass(Text.class);
        job.setOutputValueClass(IntWritable.class);

        FileInputFormat.addInputPath(job, new Path(args[0]));
        FileOutputFormat.setOutputPath(job, new Path(args[1]));

        System.exit(job.waitForCompletion(true) ? 0 : 1);
    }
}
