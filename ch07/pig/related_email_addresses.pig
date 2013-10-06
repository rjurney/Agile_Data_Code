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

set default_parallel 5
set mapred.map.tasks.speculative.execution false
set mapred.reduce.tasks.speculative.execution false

rmf /tmp/related_addresses.txt

emails = load '/me/Data/test_mbox' using AvroStorage();
/* We need to insert reply_to as a valid from or email addresses will miss in our index */
split emails into has_reply_to if (reply_tos is not null), just_froms if (reply_tos is null);

/* Count both the from and reply_to as valid froms if there is a reply_tos field */
reply_tos = foreach has_reply_to generate FLATTEN(reply_tos.address) as from, tos, ccs, bccs;
reply_to_froms = foreach has_reply_to generate from.address as from, tos, ccs, bccs;
/* Treat emails without reply_to as normal */
just_froms = foreach just_froms generate from.address as from, tos, ccs, bccs;
/* Now union them all and we have our dataset to compute on */
all_froms = union reply_tos, reply_to_froms, just_froms;
/* Now pair up our froms/reply_tos with all recipient types, 
   and union them to get a sender/recipient connection list. */
tos = foreach all_froms generate flatten(from) as from, flatten(tos.address) as to;
ccs = foreach all_froms generate flatten(from) as from, flatten(ccs.address) as to;
bccs = foreach all_froms generate flatten(from) as from, flatten(bccs.address) as to;
pairs = union tos, ccs, bccs;

counts = foreach (group pairs by (from, to)) generate flatten(group) as (from, to), 
                                                      COUNT(pairs) as total;

top_pairs = foreach (group counts by from) {
  filtered = filter counts by (to is not null);
  sorted = order filtered by total desc;
  top_8 = limit sorted 8;
  generate group as address, top_8.(to) as related_addresses;
}

store top_pairs into '/tmp/related_addresses.txt';
store top_pairs into 'mongodb://localhost/agile_data.related_addresses' using MongoStorage();
