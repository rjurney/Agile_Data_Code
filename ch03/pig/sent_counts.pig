/* Set Home Directory - where we install software */
%default HOME `echo \$HOME/Software/`

REGISTER $HOME/pig/pig-*.jar
REGISTER $HOME/pig/build/ivy/lib/Pig/avro-*.jar
REGISTER $HOME/pig/build/ivy/lib/Pig/json-simple-*.jar
DEFINE AvroStorage org.apache.pig.builtin.AvroStorage();

rmf /tmp/sent_counts.txt

/* Load the emails in avro format (edit the path to match where you saved them) using the AvroStorage UDF from Piggybank */
messages = LOAD '/Data/test_mbox' USING AvroStorage();

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
