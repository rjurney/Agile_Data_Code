/* Set Home Directory - where we install software */
%default HOME `echo \$HOME/Software/`

/* MongoDB libraries and configuration */
REGISTER $HOME/mongo-hadoop/mongo-2.10.1.jar
REGISTER $HOME/mongo-hadoop/core/target/mongo-hadoop-core-1.1.0-SNAPSHOT.jar
REGISTER $HOME/mongo-hadoop/pig/target/mongo-hadoop-pig-1.1.0-SNAPSHOT.jar

DEFINE MongoStorage com.mongodb.hadoop.pig.MongoStorage();

token_reply_rates = LOAD '/tmp/reply_rates.txt' AS (token:chararray, reply_rate:double);
store token_reply_rates into 'mongodb://localhost/agile_data.token_reply_rates' using MongoStorage();

token_no_reply_rates = LOAD '/tmp/no_reply_rates.txt' AS (token:chararray, reply_rate:double);
store token_no_reply_rates into 'mongodb://localhost/agile_data.token_no_reply_rates' using MongoStorage();

p_token = LOAD '/tmp/p_token.txt' AS (token:chararray, prob:double);
store p_token into 'mongodb://localhost/agile_data.p_token' using MongoStorage();
