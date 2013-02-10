/* MongoDB libraries and configuration */
REGISTER /me/Software/mongo-hadoop/mongo-2.10.1.jar
REGISTER /me/Software/mongo-hadoop/core/target/mongo-hadoop-core-1.1.0-SNAPSHOT.jar
REGISTER /me/Software/mongo-hadoop/pig/target/mongo-hadoop-pig-1.1.0-SNAPSHOT.jar

DEFINE MongoStorage com.mongodb.hadoop.pig.MongoStorage();

token_reply_rates = LOAD '/tmp/reply_rates.txt' AS (token:chararray, reply_rate:double);
store token_reply_rates into 'mongodb://localhost/agile_data.token_reply_rates' using MongoStorage();
