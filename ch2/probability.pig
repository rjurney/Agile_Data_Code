REGISTER /me/Software/pig/build/ivy/lib/Pig/avro-1.5.3.jar
REGISTER /me/Software/pig/build/ivy/lib/Pig/json-simple-1.1.jar
REGISTER /me/Software/pig/contrib/piggybank/java/piggybank.jar

DEFINE AvroStorage org.apache.pig.piggybank.storage.avro.AvroStorage();

rmf /tmp/from_counts.txt
rmf /tmp/sent_counts.txt
rmf /tmp/from_to_cc_counts.txt

/* Load the emails in avro format (edit the path to match where you saved them) using the AvroStorage UDF from Piggybank */
messages = LOAD '/me/Data/test_mbox' USING AvroStorage();

/* Filter nulls, they won't help */
messages = FILTER messages BY (from IS NOT NULL) AND (tos IS NOT NULL);

/* Get the total emails sent by an email address */
just_froms = FOREACH messages GENERATE from.address as from;
from_counts = FOREACH (GROUP just_froms BY from) GENERATE group as from, COUNT_STAR(just_froms) as total;
STORE from_counts INTO '/tmp/from_counts.txt';

/* Emails can be 'to' more than one person. FLATTEN() will project our from with each 'to' that exists. */
addresses = FOREACH messages GENERATE from.address AS from, 
                                      FLATTEN(tos.(address)) AS to;

/* Lowercase the email addresses, so we don't count MiXed case of the same address as multiple addresses */
lowercase_addresses = FOREACH addresses GENERATE LOWER(from) AS from, 
                                    LOWER(to) AS to;

/* GROUP BY each from/to pair into a bag (array), then count the bag's contents ($1 means the 2nd field) to get a total.
   Same as SQL: SELECT from, to, COUNT(*) FROM lowers GROUP BY (from, to);
   Note: COUNT_STAR differs from COUNT in that it counts nulls. */
by_from_to = GROUP lowercase_addresses BY (from, to);
sent_counts = FOREACH by_from_to GENERATE 
                FLATTEN(group) AS (from, to), 
                COUNT_STAR(lowercase_addresses) AS total;

/* Sort the data, highest sent count first */
sent_counts = ORDER sent_counts BY total DESC;
STORE sent_counts INTO '/tmp/sent_counts.txt';

/* Now split out emails that have both to and cc addresses */
to_ccs = FILTER messages BY (from IS NOT NULL) AND (tos IS NOT NULL) AND (ccs IS NOT NULL);

/* Project all unique combinations of from, to and cc. */
from_to_cc = FOREACH to_ccs GENERATE from.address AS from, 
                                    FLATTEN(tos.(address)) AS to, 
                                    FLATTEN(ccs.(address)) AS cc;
                                    
/* Lowercase again */
lower_from_to_cc = FOREACH from_to_cc GENERATE 
                                      LOWER(from) as from,
                                      LOWER(to) as to,
                                      LOWER(cc) as cc;

/* Now group and take counts */
from_to_cc_counts = FOREACH (GROUP lower_from_to_cc BY (from, to, cc)) GENERATE FLATTEN(group) AS (from, to, cc), 
                                                                       COUNT_STAR(lower_from_to_cc) AS total;
/* Sort from largest count to smallest */
from_to_cc_counts = ORDER from_to_cc_counts BY total DESC;
                                                                       
STORE from_to_cc_counts INTO '/tmp/from_to_cc_counts.txt';
