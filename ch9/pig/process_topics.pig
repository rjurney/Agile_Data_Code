/* MongoDB libraries and configuration */
REGISTER /me/Software/mongo-hadoop/mongo-2.10.1.jar
REGISTER /me/Software/mongo-hadoop/core/target/mongo-hadoop-core-1.1.0-SNAPSHOT.jar
REGISTER /me/Software/mongo-hadoop/pig/target/mongo-hadoop-pig-1.1.0-SNAPSHOT.jar

DEFINE MongoStorage com.mongodb.hadoop.pig.MongoStorage();

rmf /tmp/topics_per_document.txt

topic_scores = LOAD '/tmp/tf_idf_scores' as (message_id:chararray, topic:chararray, score:double);
per_document = foreach (group topic_scores by message_id) {
  sorted = order topic_scores by score desc;
  limited = limit sorted 10;
  generate group as message_id, limited.(topic, score);
};
store per_document into '/tmp/topics_per_document.txt';
-- store per_document into 'mongodb://localhost/agile_data.topics_per_document' using MongoStorage();
