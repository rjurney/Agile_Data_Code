/* Set Home Directory - where we install software */
%default HOME `echo \$HOME/Software/`

REGISTER $HOME/mongo-hadoop/mongo-2.10.1.jar
REGISTER $HOME/mongo-hadoop/core/target/mongo-hadoop-core-1.1.0-SNAPSHOT.jar
REGISTER $HOME/mongo-hadoop/pig/target/mongo-hadoop-pig-1.1.0-SNAPSHOT.jar

set mapred.map.tasks.speculative.execution false
set mapred.reduce.tasks.speculative.execution false

sent_counts = LOAD '/tmp/sent_counts.txt' AS (from:chararray, to:chararray, total:long);
STORE sent_counts INTO 'mongodb://localhost/agile_data.sent_counts' USING com.mongodb.hadoop.pig.MongoStorage();
