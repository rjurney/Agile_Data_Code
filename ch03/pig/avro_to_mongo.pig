/* Set Home Directory - where we install software */
%default HOME `echo \$HOME/Software/`

/* Load Avro jars and define shortcut */
REGISTER $HOME/pig/build/ivy/lib/Pig/avro-*.jar
REGISTER /$HOME/pig/build/ivy/lib/Pig/json-simple-*.jar
DEFINE AvroStorage org.apache.pig.builtin.AvroStorage();

/* MongoDB libraries and configuration */
REGISTER $HOME/mongo-java-driver*.jar
REGISTER $HOME/mongo-hadoop/core/target/mongo-hadoop-core_2.2.0-1.2.0.jar
REGISTER $HOME/mongo-hadoop/pig/target/mongo-hadoop-pig_2.2.0-1.2.0.jar

/* Set speculative execution off so we don't have the chance of duplicate records in Mongo */
set mapred.map.tasks.speculative.execution false
set mapred.reduce.tasks.speculative.execution false
define MongoStorage com.mongodb.hadoop.pig.MongoStorage(); /* Shortcut */

avros = load '/tmp/sent_counts.txt' using AvroStorage(); /* For example, 'enron.avro' */
store avros into 'mongodb://localhost/agile_date.sent_counts' using MongoInsertStorage(); /* For example, 'mongodb://localhost/enron.emails' */
