REGISTER /me/Software/pig/build/ivy/lib/Pig/avro-1.5.3.jar
REGISTER /me/Software/pig/build/ivy/lib/Pig/json-simple-1.1.jar
REGISTER /me/Software/pig/contrib/piggybank/java/piggybank.jar

DEFINE AvroStorage org.apache.pig.piggybank.storage.avro.AvroStorage();

rmf /tmp/sent_counts

messages = LOAD '/tmp/test_mbox' USING AvroStorage();
messages = FILTER messages BY (from IS NOT NULL) AND (tos IS NOT NULL);
addresses = FOREACH messages GENERATE from.address AS from, FLATTEN(tos.(address)) AS to;
lowers = FOREACH addresses GENERATE LOWER(from) AS from, LOWER(to) AS to;

sent_counts = FOREACH (GROUP lowers BY (from, to)) GENERATE FLATTEN(group) AS (from, to), COUNT($1) AS total;
sent_counts = ORDER sent_counts BY total DESC;

STORE sent_counts INTO '/tmp/sent_counts';
