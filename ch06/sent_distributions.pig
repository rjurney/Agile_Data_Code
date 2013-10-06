/* Set Home Directory - where we install software */
%default HOME `echo \$HOME/Software/`

/* Avro uses json-simple, and is in piggybank until Pig 0.12, where AvroStorage and TrevniStorage are builtins */
REGISTER $HOME/pig/build/ivy/lib/Pig/avro-1.5.3.jar
REGISTER $HOME/pig/build/ivy/lib/Pig/json-simple-1.1.jar
REGISTER $HOME/pig/contrib/piggybank/java/piggybank.jar

DEFINE AvroStorage org.apache.pig.piggybank.storage.avro.AvroStorage();
DEFINE substr org.apache.pig.piggybank.evaluation.string.SUBSTRING();
DEFINE tohour org.apache.pig.piggybank.evaluation.datetime.truncate.ISOToHour();

/* MongoDB libraries and configuration */
REGISTER $HOME/mongo-hadoop/mongo-2.10.1.jar
REGISTER $HOME/mongo-hadoop/core/target/mongo-hadoop-core-1.1.0-SNAPSHOT.jar
REGISTER $HOME/mongo-hadoop/pig/target/mongo-hadoop-pig-1.1.0-SNAPSHOT.jar

DEFINE MongoStorage com.mongodb.hadoop.pig.MongoStorage();

set default_parallel 10
set mapred.map.tasks.speculative.execution false
set mapred.reduce.tasks.speculative.execution false

/* Macro to extract the hour portion of an iso8601 datetime string */
define extract_time(relation, field_in, field_out) RETURNS times {
  $times = foreach $relation generate flatten($field_in.(address)) as $field_out,
                             substr(tohour(date), 11, 13) as sent_hour;
};

rmf /tmp/sent_distributions.avro

emails = load '/me/Data/test_mbox' using AvroStorage();
filtered = filter emails BY (from is not null) and (date is not null);

/* Some emails that users send to have no from entries, list email lists.  These addresses
   have reply_to's associated with them.  Here we split reply_to processing off to ensure
   reply_to addresses get credit for sending emails. */
split filtered into has_reply_to if (reply_tos is not null), froms if (reply_tos is null);

/* For emails with a reply_to, count both the from and the reply_to as a sender. */
reply_to = extract_time(has_reply_to, reply_tos, from);
reply_to_froms = extract_time(has_reply_to, from, from);
froms = extract_time(froms, from, from);
all_froms = union reply_to, reply_to_froms, froms;

pairs = foreach all_froms generate LOWER(from) as sender_email_address, 
                                   sent_hour;

sent_times = foreach (group pairs by (sender_email_address, sent_hour)) generate flatten(group) as (sender_email_address, sent_hour), 
                                                                                 COUNT_STAR(pairs) as total;

/* Note the use of a sort inside a foreach block */
sent_distributions = foreach (group sent_times by sender_email_address) { 
    solid = filter sent_times by (sent_hour is not null) and (total is not null);
    sorted = order solid by sent_hour;
    generate group as address, sorted.(sent_hour, total) as sent_distribution;
};
                                                        
store sent_distributions into '/tmp/sent_distributions.avro' using AvroStorage();
store sent_distributions into 'mongodb://localhost/agile_data.sent_distributions' using MongoStorage();
