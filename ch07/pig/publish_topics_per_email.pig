/* Set Home Directory - where we install software */
%default HOME `echo \$HOME/Software/`

/* MongoDB libraries and configuration */
REGISTER $HOME/mongo-hadoop/mongo-2.10.1.jar
REGISTER $HOME/mongo-hadoop/core/target/mongo-hadoop-core-1.1.0-SNAPSHOT.jar
REGISTER $HOME/mongo-hadoop/pig/target/mongo-hadoop-pig-1.1.0-SNAPSHOT.jar

DEFINE MongoStorage com.mongodb.hadoop.pig.MongoStorage();

per_document_scores = LOAD '/tmp/topics_per_document.txt' AS (message_id:chararray, topics:bag{topic:tuple(word:chararray, score:double)});
store per_document_scores into 'mongodb://localhost/agile_data.topics_per_email' using MongoStorage();
