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

set default_parallel 20

register 'udfs.py' using jython as funcs;

rmf /tmp/topics_per_document.txt
rmf /tmp/topics_per_address.txt
rmf /tmp/emails_per_topic.txt
rmf /tmp/message_vector_per_topic.txt
rmf /tmp/compare_topics.txt
rmf /tmp/cosine_similarities.txt
rmf /tmp/related_topics.txt

-- Topics Per Document
topic_scores = LOAD '/tmp/ntf_idf_scores_per_message.txt' as (message_id:chararray, topic:chararray, score:double);
per_document = foreach (group topic_scores by message_id) {
  sorted = order topic_scores by score desc;
  limited = limit sorted 10;
  generate group as message_id, limited.(topic, score);
};
store per_document into '/tmp/topics_per_document.txt';

-- Topic Per Sender
emails = load '/me/Data/test_mbox' using AvroStorage();
emails = foreach emails generate message_id, from.address as address;

topic_scores_emails = join emails by message_id, topic_scores by message_id;
topic_scores_emails = foreach topic_scores_emails generate emails::message_id as message_id,
                                                           emails::address as address, 
                                                           topic_scores::topic as topic, 
                                                           topic_scores::score as score;
per_address_topic = foreach (group topic_scores_emails by (address, topic)) generate FLATTEN(group) as (address, topic), 
                                                                                     SUM(topic_scores_emails.score) as score_total;
per_address = foreach (group per_address_topic by address) {
  by_score_total = order per_address_topic by score_total desc;
  top_20 = limit by_score_total 20;
  generate group as address, top_20.(topic, score_total) as topics;
}
-- store per_address into '/tmp/topics_per_address.txt';
-- store per_address into 'mongodb://localhost/agile_data.topics_per_document' using MongoStorage();

-- Emails per Topic
emails_per_topic = foreach (group topic_scores_emails by topic) {
  sorted = order topic_scores_emails by score desc;
  top_20 = limit sorted 20;
  generate group as topic, top_20.(message_id, score, address) as message_scores;
}
-- store emails_per_topic into '/tmp/emails_per_topic.txt';

-- Related Topics via Cosine Similarity
email_scores_per_topic = foreach (group topic_scores_emails by topic) generate group as topic, 
                                                                               topic_scores_emails as message_scores;

-- Get all terms for an index - cosine similarity requires feature vectors be the same
topic_scores_all = foreach topic_scores generate topic;
all_topics = DISTINCT topic_scores_all;
topic_vector = join all_topics by topic LEFT OUTER, topic_scores by topic;
topic_vector = foreach topic_vector generate all_topics::topic as topic, topic_scores::message_id as message_id, topic_scores::score as score;
message_vector_per_topic = foreach (group topic_vector by topic) {
  sorted = order topic_vector by topic;
  generate group as topic, sorted as sorted_message_vector;
}
-- store message_vector_per_topic into '/tmp/message_vector_per_topic.txt';
second_vector_per_topic = LOAD '/tmp/message_vector_per_topic.txt' as (topic:chararray, sorted_message_vector:bag{vector:tuple(score:double)});
compare_topics = CROSS message_vector_per_topic, second_vector_per_topic;
-- store compare_topics into '/tmp/compare_topics.txt';
cosine_similarities = foreach compare_topics generate funcs.cosineSimilarity(message_vector_per_topic::topic, 
                                                                             message_vector_per_topic::sorted_message_vector, 
                                                                             second_vector_per_topic::topic,
                                                                             second_vector_per_topic::sorted_message_vector);
-- store cosine_similarities into '/tmp/cosine_similarities.txt';

/*related_topics = foreach (group cosine_similarities by topic1) {
  sorted = order cosine_similarities by score;
  top_10 = limit sorted 10;
  generate topic1 as topic, top_10.(topic2, cosine_similarity) as related_topics;
}
store related_topics into '/tmp/related_topics.txt';*/