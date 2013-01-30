/* Avro uses json-simple, and is in piggybank until Pig 0.12, where AvroStorage and TrevniStorage are builtins */
REGISTER /me/Software/pig/build/ivy/lib/Pig/avro-1.5.3.jar
REGISTER /me/Software/pig/build/ivy/lib/Pig/json-simple-1.1.jar
REGISTER /me/Software/pig/contrib/piggybank/java/piggybank.jar

DEFINE AvroStorage org.apache.pig.piggybank.storage.avro.AvroStorage();

/* MongoDB libraries and configuration */
REGISTER /me/Software/mongo-hadoop/mongo-2.10.1.jar
REGISTER /me/Software/mongo-hadoop/core/target/mongo-hadoop-core-1.1.0-SNAPSHOT.jar
REGISTER /me/Software/mongo-hadoop/pig/target/mongo-hadoop-pig-1.1.0-SNAPSHOT.jar

DEFINE MongoStorage com.mongodb.hadoop.pig.MongoStorage();

set default_parallel 10
set mapred.map.tasks.speculative.execution false
set mapred.reduce.tasks.speculative.execution false

rmf /tmp/sent_counts.txt
rmf /tmp/smooth_distributions.avro

-- Count both from addresses and reply_to addresses as 
emails = load '/me/Data/test_mbox' using AvroStorage();
split emails into has_reply_to if (reply_tos is not null), froms if (reply_tos is null);

-- Cast reply_to addresses as new from addresses and union back our from/reply_tos
reply_tos_trimmed = foreach has_reply_to generate flatten(reply_tos.address) as from, flatten(tos.address) as to;
froms_trimmed = foreach froms generate from.address as from, flatten(tos.address) as to;
sent_mails = union reply_tos_trimmed, froms_trimmed;

sent_counts = foreach (group sent_mails by (from, to)) generate flatten(group) as (from, to), COUNT_STAR(sent_mails) as total;
store sent_counts into '/tmp/sent_counts.txt';