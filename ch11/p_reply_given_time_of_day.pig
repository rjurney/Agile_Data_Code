/* Avro uses json-simple, and is in piggybank until Pig 0.12, where AvroStorage and TrevniStorage are builtins */
REGISTER /me/Software/pig/build/ivy/lib/Pig/avro-1.5.3.jar
REGISTER /me/Software/pig/build/ivy/lib/Pig/json-simple-1.1.jar
REGISTER /me/Software/pig/contrib/piggybank/java/piggybank.jar

DEFINE AvroStorage org.apache.pig.piggybank.storage.avro.AvroStorage();
DEFINE substr org.apache.pig.piggybank.evaluation.string.SUBSTRING();
DEFINE tohour org.apache.pig.piggybank.evaluation.datetime.truncate.ISOToHour();

/* MongoDB libraries and configuration */
REGISTER /me/Software/mongo-hadoop/mongo-2.10.1.jar
REGISTER /me/Software/mongo-hadoop/core/target/mongo-hadoop-core-1.1.0-SNAPSHOT.jar
REGISTER /me/Software/mongo-hadoop/pig/target/mongo-hadoop-pig-1.1.0-SNAPSHOT.jar

DEFINE MongoStorage com.mongodb.hadoop.pig.MongoStorage();

set default_parallel 10
set mapred.map.tasks.speculative.execution false
set mapred.reduce.tasks.speculative.execution false

rmf /tmp/sent_counts_by_hour.avro
rmf /tmp/sent_by_hour_reply_ratios.avro
rmf /tmp/reply_counts_by_hour.avro
rmf /tmp/sent_replies.txt
rmf /tmp/replies.txt
rmf /tmp/reply_ratios_by_hour.txt
rmf /tmp/reply_counts.txt
rmf /tmp/sent_counts.txt

emails = load '/me/Data/test_mbox' using AvroStorage();
clean_emails = filter emails by (from.address is not null) and (reply_tos is null);
sent_emails = foreach clean_emails generate from.address as from, 
                                            substr(tohour(date), 11, 13) as hour, 
                                            message_id;

sent_counts = foreach (group sent_emails by (from, hour)) generate flatten(group) as (from, hour), 
                                                                   COUNT_STAR(sent_emails) as total;
store sent_counts into '/tmp/sent_counts.txt';

replies = filter emails by (from is not null) and (reply_tos is null) and (in_reply_to is not null);
replies = foreach replies generate from.address as from,
                                   in_reply_to;
replies = filter replies by in_reply_to != 'None';
store replies into '/tmp/replies.txt';

/* Now join a copy of the emails by message id to the in_reply_to of our emails */
replies = load '/tmp/replies.txt' as (from:chararray, to:chararray, in_reply_to:chararray);
with_reply = join sent_emails by message_id, replies by in_reply_to;

trimmed_replies = foreach with_reply generate sent_emails::from as from, sent_emails::hour as hour;
reply_counts = foreach (group trimmed_replies by (from, hour)) generate flatten(group) as (from, hour), 
                                                                        COUNT_STAR(trimmed_replies) as total;
store reply_counts into '/tmp/reply_counts.txt';

-- Join to get replies with sent mails
sent_replies = join sent_counts by (from, hour), reply_counts by (from, hour);

-- Calculate from/to reply ratios for each pair of from/to
reply_ratios = foreach sent_replies generate sent_counts::from as from, 
                                             sent_counts::hour as hour, 
                                             (double)reply_counts::total/sent_counts::total as ratio:double;
store reply_ratios into '/tmp/reply_ratios_by_hour.txt';
