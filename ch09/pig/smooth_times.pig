/* Set Home Directory - where we install software */
%default HOME `echo \$HOME/Software/`

/* Avro uses json-simple, and is in piggybank until Pig 0.12, where AvroStorage and TrevniStorage are builtins */
REGISTER $HOME/pig/build/ivy/lib/Pig/avro-1.5.3.jar
REGISTER $HOME/pig/build/ivy/lib/Pig/json-simple-1.1.jar
REGISTER $HOME/pig/contrib/piggybank/java/piggybank.jar

DEFINE AvroStorage org.apache.pig.piggybank.storage.avro.AvroStorage();

/* MongoDB libraries and configuration */
REGISTER $HOME/mongo-hadoop/mongo-2.10.1.jar
REGISTER $HOME/mongo-hadoop/core/target/mongo-hadoop-core-1.1.0-SNAPSHOT.jar
REGISTER $HOME/mongo-hadoop/pig/target/mongo-hadoop-pig-1.1.0-SNAPSHOT.jar

DEFINE MongoStorage com.mongodb.hadoop.pig.MongoStorage();

set default_parallel 10
set mapred.map.tasks.speculative.execution false
set mapred.reduce.tasks.speculative.execution false

rmf /tmp/smoothed_sent_dists.avro
rmf /tmp/smoothed_sent_dists.txt

time_dists_per_email = LOAD '/tmp/date_filled_dist.avro' using AvroStorage(); -- as (address:chararray, sent_distribution:bag{t:tuple(hour:chararray, p_reply:double)});

DEFINE smooth_stream `hamming.py` SHIP ('hamming.py');
smoothed_time_dists_per_email = STREAM time_dists_per_email THROUGH smooth_stream as (address:chararray, hour:chararray, p_reply:double);

answer = foreach (group smoothed_time_dists_per_email by address) {
  sorted = order smoothed_time_dists_per_email by hour;
  generate group as address, sorted.(hour, p_reply) as sent_distribution;
};
store answer into '/tmp/smoothed_sent_dists.avro' using AvroStorage();
store answer into '/tmp/smoothed_sent_dists.txt';
store answer into 'mongodb://localhost/agile_data.hourly_from_reply_probs' using MongoStorage();

/*p_sent_hour = load '/tmp/p_sent_hour.txt' as (from:chararray, distribution:bag{t:tuple(sent_hour:chararray, ratio:double)});
store p_sent_hour into 'mongodb://localhost/agile_data.p_sent_hour' using MongoStorage();

*/