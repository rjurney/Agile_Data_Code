/* Avro uses json-simple, and is in piggybank until Pig 0.12, where AvroStorage and TrevniStorage are builtins */
REGISTER /me/Software/pig/build/ivy/lib/Pig/avro-1.5.3.jar
REGISTER /me/Software/pig/build/ivy/lib/Pig/json-simple-1.1.jar
REGISTER /me/Software/pig/contrib/piggybank/java/piggybank.jar

DEFINE AvroStorage org.apache.pig.piggybank.storage.avro.AvroStorage();
DEFINE LENGTH org.apache.pig.piggybank.evaluation.string.LENGTH();

/* MongoDB libraries and configuration */
REGISTER /me/Software/mongo-hadoop/mongo-2.10.1.jar
REGISTER /me/Software/mongo-hadoop/core/target/mongo-hadoop-core-1.1.0-SNAPSHOT.jar
REGISTER /me/Software/mongo-hadoop/pig/target/mongo-hadoop-pig-1.1.0-SNAPSHOT.jar

DEFINE MongoStorage com.mongodb.hadoop.pig.MongoStorage();

set default_parallel 10
set mapred.map.tasks.speculative.execution false
set mapred.reduce.tasks.speculative.execution false

rmf /tmp/p_reply_given_length.avro

register 'udfs.py' using jython as funcs;

emails = load '/me/Data/test_mbox' using AvroStorage();

clean_emails = filter emails by (body is not null) and (reply_tos is null);
sent_emails = foreach clean_emails generate message_id, LENGTH(body) as body_length;


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