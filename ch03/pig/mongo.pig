/* Set Home Directory - where we install software */
%default HOME `echo \$HOME/Software/`
REGISTER $HOME/mongo-java-driver*.jar
REGISTER $HOME/mongo-hadoop/core/target/mongo-hadoop-core_2.2.0-1.2.0.jar
REGISTER $HOME/mongo-hadoop/pig/target/mongo-hadoop-pig_2.2.0-1.2.0.jar

set mapred.map.tasks.speculative.execution false
set mapred.reduce.tasks.speculative.execution false

sent_counts = LOAD '/tmp/sent_counts.txt' AS (from:chararray, to:chararray, total:long);
STORE sent_counts INTO 'mongodb://127.0.0.1:27017/agile_data.sent_counts' USING com.mongodb.hadoop.pig.MongoInsertStorage('','');
