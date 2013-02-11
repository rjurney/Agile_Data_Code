/* Set Home Directory - where we install software */
%default HOME `echo \$HOME/Software/`

REGISTER $HOME/pig/build/ivy/lib/Pig/avro-1.5.3.jar
REGISTER $HOME/pig/build/ivy/lib/Pig/json-simple-1.1.jar
REGISTER $HOME/pig/contrib/piggybank/java/piggybank.jar

DEFINE AvroStorage org.apache.pig.piggybank.storage.avro.AvroStorage();

/* MongoDB libraries and configuration */
REGISTER $HOME/mongo-hadoop/mongo-2.10.1.jar
REGISTER $HOME/mongo-hadoop/core/target/mongo-hadoop-core-1.1.0-SNAPSHOT.jar
REGISTER $HOME/mongo-hadoop/pig/target/mongo-hadoop-pig-1.1.0-SNAPSHOT.jar

/* Set speculative execution off so we don't have the chance of duplicate records in Mongo */
set mapred.map.tasks.speculative.execution false
set mapred.reduce.tasks.speculative.execution false
define MongoStorage com.mongodb.hadoop.pig.MongoStorage(); /* Shortcut */

rmf /tmp/sent_counts.txt

/* Load the emails in avro format (edit the path to match where you saved them) using the AvroStorage UDF from Piggybank */
messages = LOAD '/me/Data/test_mbox' USING AvroStorage();

/* Filter nulls, they won't help */
messages = FILTER messages BY (from IS NOT NULL) AND (tos IS NOT NULL);

/* Emails can be 'to' more than one person. FLATTEN() will project our from with each 'to' that exists. */
addresses = FOREACH messages GENERATE from.address AS from, FLATTEN(tos.(address)) AS to;

/* Lowercase the email addresses, so we don't count MiXed case of the same address as multiple addresses */
lowers = FOREACH addresses GENERATE LOWER(from) AS from, LOWER(to) AS to;

/* GROUP BY each from/to pair into a bag (array), then count the bag's contents ($1 means the 2nd field) to get a total.
   Same as SQL: SELECT from, to, COUNT(*) FROM lowers GROUP BY (from, to);
   Note: COUNT_STAR differs from COUNT in that it counts nulls. */
by_from_to = GROUP lowers BY (from, to);
sent_counts = FOREACH by_from_to GENERATE FLATTEN(group) AS (from, to), COUNT_STAR(lowers) AS total;

/* Sort the data, highest sent count first */
sent_counts = ORDER sent_counts BY total DESC;
STORE sent_counts INTO '/tmp/sent_counts.txt';
STORE sent_counts INTO 'mongodb://jack:OpenSesame@testola-rjurney-data-0.azva.dotcloud.net:40961/agile_data.sent_counts' using MongoStorage();
