/* Set Home Directory - where we install software */
%default HOME `echo \$HOME/Software/`

/* Avro uses json-simple, and is in piggybank until Pig 0.12, where AvroStorage and TrevniStorage are builtins */
REGISTER $HOME/pig/build/ivy/lib/Pig/avro-1.5.3.jar
REGISTER $HOME/pig/build/ivy/lib/Pig/json-simple-1.1.jar
REGISTER $HOME/pig/contrib/piggybank/java/piggybank.jar

DEFINE AvroStorage org.apache.pig.piggybank.storage.avro.AvroStorage();

/* Elasticsearch's own jars */
REGISTER $HOME/elasticsearch-0.20.2/lib/*.jar

/* Register wonderdog - elasticsearch integration */
REGISTER $HOME/wonderdog/target/wonderdog-1.0-SNAPSHOT.jar

/* Remove the old json */
rmf /tmp/sent_count_json

/* Nuke the elasticsearch sent_counts index, as we are about to replace it. */
sh curl -XDELETE 'http://localhost:9200/inbox/sent_counts'

/* Load Avros, and store as JSON */
sent_counts = LOAD '/tmp/sent_counts.txt' AS (from:chararray, to:chararray, total:long);
STORE sent_counts INTO '/tmp/sent_count_json' USING JsonStorage();

/* Now load the JSON as a single chararray field, and index it into ElasticSearch with Wonderdog from InfoChimps */
sent_count_json = LOAD '/tmp/sent_count_json' AS (sent_counts:chararray);
STORE sent_count_json INTO 'es://inbox/sentcounts?json=true&size=1000' USING com.infochimps.elasticsearch.pig.ElasticSearchStorage(
  '$HOME/elasticsearch-0.20.2/config/elasticsearch.yml', 
  '$HOME/elasticsearch-0.20.2/plugins');

/* Search for Hadoop to make sure we get a hit in our sent_count index */
sh curl -XGET 'http://localhost:9200/inbox/sentcounts/_search?q=russell&pretty=true&size=1'
