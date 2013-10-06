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

rmf /tmp/pairs.txt
rmf /tmp/node_list.avro
rmf /tmp/node_list.txt
rmf /tmp/edge_list.txt
rmf /tmp/edge_list.avro

emails = load '/me/Data/test_mbox' using AvroStorage();

-- Prepare edge list

/* Filter emails according to existence of header pairs, from and [to, cc, bcc]
project the pairs (may be more than one to/cc/bcc), then emit them, lowercased. */
DEFINE header_pairs(email, col1, col2) RETURNS pairs { 
  filtered = FILTER $email BY ($col1 IS NOT NULL) AND ($col2 IS NOT NULL);
  flat = FOREACH filtered GENERATE FLATTEN($col1.address) AS $col1, FLATTEN($col2.address) AS $col2;
  $pairs = FOREACH flat GENERATE LOWER($col1) AS ego1, LOWER($col2) AS ego2;
}

/* Automate calling the above. */
DEFINE count_headers(emails) RETURNS pairs {
  from_to = header_pairs($emails, from, tos);
  from_cc = header_pairs($emails, from, ccs);
  from_bcc = header_pairs($emails, from, bccs);
  $pairs = UNION from_to, from_cc, from_bcc;
}

/* Get email address pairs for each type of connection, and union them together */
emails1 = LOAD '/me/Data/test_mbox' USING AvroStorage();
pairs1 = count_headers(emails1);
store pairs1 into '/tmp/pairs.txt';

emails2 = LOAD '/me/Data/test_mbox' USING AvroStorage();
pairs2 = count_headers(emails2);

/* Get a count of emails over these edges. */
edge_list = FOREACH (GROUP pairs1 BY (ego1, ego2)) GENERATE FLATTEN(group) AS (ego1, ego2), 
                                                            COUNT_STAR(pairs1) AS total;
filtered_edge_list = filter edge_list by total > 1;
store filtered_edge_list into '/tmp/simple_edge_list.txt';
second_edge_list = FOREACH (GROUP pairs2 BY (ego1, ego2)) GENERATE FLATTEN(group) AS (ego1, ego2), 
                                                          COUNT_STAR(pairs2) AS total;
second_edge_list = filter second_edge_list by total > 1;

together = join filtered_edge_list by (ego1, ego2), second_edge_list by (ego2, ego1);
filtered_together = filter together by filtered_edge_list.total >= 1 AND second_edge_list.total >= 1;
final_edge_list = foreach filtered_together generate filtered_edge_list.ego1 as source, 
                                                     filtered_edge_list.ego2 as target,
                                                     filtered_edge_list.total as value;
store final_edge_list into '/tmp/edge_list.txt' using PigStorage(',');
-- store final_edge_list into '/tmp/edge_list.avro' using AvroStorage();                        

-- Prepare node list
nodes = foreach filtered_edge_list generate ego1 as sender, total as total, ego2 as recipient;
sent_totals = foreach (group nodes by sender) generate group as sender, 
                                                       SUM(nodes.total) as total_sent;
rcvd_totals = foreach (group nodes by recipient) generate group as recipient,
                                                          SUM(nodes.total) as total_rcvd;
sent_rcvd = join sent_totals by sender, rcvd_totals by recipient;
node_list = foreach sent_rcvd generate sender as address,
                                       (int)total_sent as total_sent:int,
                                       (int)total_rcvd as total_rcvd:int;
                                       
/* Filter by weight > 1 in both directions - actual 'reply' relationships. 
   Single email connections overwhelm visualization otherwise. */
node_list = filter node_list by total_sent >= 1 and total_rcvd >= 1;

store node_list into '/tmp/node_list.txt' using PigStorage();
-- store node_list into '/tmp/node_list.avro' using AvroStorage();