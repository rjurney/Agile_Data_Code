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

rmf /tmp/hour_sent_counts.txt
rmf /tmp/date_replies.txt
rmf /tmp/date_reply_counts.txt
rmf /tmp/reply_ratios_by_hour.txt
rmf /tmp/date_filled_dist.txt
rmf /tmp/all_ratio.txt

register 'udfs.py' using jython as funcs;

emails = load '/me/Data/test_mbox' using AvroStorage();
clean_emails = filter emails by (from.address is not null) and (reply_tos is null);
sent_emails = foreach clean_emails generate from.address as from, 
                                            substr(tohour(date), 11, 13) as sent_hour, 
                                            message_id;

sent_counts = foreach (group sent_emails by (from, sent_hour)) generate flatten(group) as (from, sent_hour), 
                                                                        COUNT_STAR(sent_emails) as total;
-- store sent_counts into '/tmp/hour_sent_counts.txt';

replies = filter emails by (from is not null) and (reply_tos is null) and (in_reply_to is not null);
replies = foreach replies generate from.address as from,
                                   in_reply_to;
replies = filter replies by in_reply_to != 'None';
-- store replies into '/tmp/date_replies.txt';

/* Now join a copy of the emails by message id to the in_reply_to of our emails */
replies = load '/tmp/date_replies.txt' as (from:chararray, in_reply_to:chararray);
with_reply = join sent_emails by message_id, replies by in_reply_to;

trimmed_replies = foreach with_reply generate sent_emails::from as from, sent_emails::sent_hour as sent_hour;
reply_counts = foreach (group trimmed_replies by (from, sent_hour)) generate flatten(group) as (from, sent_hour), 
                                                                             COUNT_STAR(trimmed_replies) as total;
-- store reply_counts into '/tmp/date_reply_counts.txt';

-- Join to get replies with sent mails
sent_replies = join sent_counts by (from, sent_hour), reply_counts by (from, sent_hour);


-- Calculate from/to reply ratios for each pair of from/to
reply_ratios = foreach sent_replies generate sent_counts::from as from, 
                                             sent_counts::sent_hour as sent_hour, 
                                             (double)reply_counts::total / (double)sent_counts::total as ratio:double;
reply_ratios = foreach reply_ratios generate from, sent_hour, (ratio > 1.0 ? 1.0 : ratio) as ratio;
store reply_ratios into '/tmp/reply_ratios_by_hour.txt';

by_from = group reply_ratios by from;
per_from = foreach by_from {
  sorted = order reply_ratios by sent_hour;
  generate group as from,
           sorted.(sent_hour, ratio) as sent_distribution;
};
filled_dist = foreach per_from generate from, funcs.fill_in_blanks(sent_distribution) as sent_distribution;
store filled_dist into '/tmp/date_filled_dist.txt';

-- All ratio by hour
all_ratio = foreach (group sent_replies by sent_hour) generate 'overall' as key, 
  (double)SUM(sent_replies.reply_counts::total) / (double)SUM(sent_replies.sent_counts::total) as ratio;
store all_ratio into '/tmp/all_ratio.txt';
