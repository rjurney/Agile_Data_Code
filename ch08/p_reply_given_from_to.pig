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

set default_parallel 20
set mapred.map.tasks.speculative.execution false
set mapred.reduce.tasks.speculative.execution false

rmf /tmp/sent_counts.txt
rmf /tmp/replies.txt
rmf /tmp/direct_replies.txt
rmf /tmp/reply_counts.txt
rmf /tmp/reply_ratios.txt
rmf /tmp/overall_replies.txt
rmf /tmp/smooth_distributions.avro

-- Count both from addresses and reply_to addresses as 
emails = load '/me/Data/test_mbox' using AvroStorage();
clean_emails = filter emails by (from.address is not null) and (reply_tos is null);
sent_emails = foreach clean_emails generate from.address as from, flatten(tos.address) as to, message_id;

sent_counts = foreach (group sent_emails by (from, to)) generate flatten(group) as (from, to), COUNT_STAR(sent_emails) as total;
store sent_counts into '/tmp/sent_counts.txt';

replies = filter emails by (from is not null) and (reply_tos is null) and (in_reply_to is not null);
replies = foreach replies generate from.address as from,
                                   flatten(tos.address) as to,
                                   in_reply_to;
replies = filter replies by in_reply_to != 'None';
store replies into '/tmp/replies.txt';

/* Now join a copy of the emails by message id to the in_reply_to of our emails */
replies = load '/tmp/replies.txt' as (from:chararray, to:chararray, in_reply_to:chararray);
with_reply = join sent_emails by message_id, replies by in_reply_to;

/* Filter out mailing lists - only direct replies where from/to match up */
direct_replies = filter with_reply by (sent_emails::from == replies::to) and (sent_emails::to == replies::from);
store direct_replies into '/tmp/direct_replies.txt';

trimmed_replies = foreach direct_replies generate sent_emails::from as from, sent_emails::to as to;
reply_counts = foreach (group trimmed_replies by (from, to)) generate flatten(group) as (from, to), 
                                                                      COUNT_STAR(trimmed_replies) as total;
store reply_counts into '/tmp/reply_counts.txt';

-- Join to get replies with sent mails
sent_replies = join sent_counts by (from, to), reply_counts by (from, to);

-- Calculate from/to reply ratios for each pair of from/to
reply_ratios = foreach sent_replies generate sent_counts::from as from, 
                                             sent_counts::to as to, 
                                             (double)reply_counts::total/sent_counts::total as ratio:double;
reply_ratios = foreach reply_ratios generate from, to, (ratio > 1.0 ? 1.0 : ratio) as ratio; -- Error cleaning
store reply_ratios into '/tmp/reply_ratios.txt';
store reply_ratios into 'mongodb://localhost/agile_data.reply_ratios' using MongoStorage();

-- Calculate the overall reply ratio - period.
overall_replies = foreach (group sent_replies all) generate 'overall' as key:chararray, 
                                                            SUM(sent_replies.sent_counts::total) as sent,
                                                            SUM(sent_replies.reply_counts::total) as replies,
                                                            (double)SUM(sent_replies.reply_counts::total)/(double)SUM(sent_replies.sent_counts::total) as reply_ratio; 
store overall_replies into '/tmp/overall_replies.txt';


