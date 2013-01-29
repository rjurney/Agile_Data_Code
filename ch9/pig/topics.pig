/* Avro uses json-simple, and is in piggybank until Pig 0.12, where AvroStorage and TrevniStorage are builtins */
REGISTER /me/Software/pig/build/ivy/lib/Pig/avro-1.5.3.jar
REGISTER /me/Software/pig/build/ivy/lib/Pig/json-simple-1.1.jar
REGISTER /me/Software/pig/contrib/piggybank/java/piggybank.jar

DEFINE AvroStorage org.apache.pig.piggybank.storage.avro.AvroStorage();

REGISTER /me/Software/varaha/lib/*.jar /* */
REGISTER /me/Software/varaha/target/varaha-1.0-SNAPSHOT.jar 

DEFINE TokenizeText varaha.text.TokenizeText();
DEFINE StanfordTokenize varaha.text.StanfordTokenize();

set default_parallel 5
set mapred.map.tasks.speculative.execution false
set mapred.reduce.tasks.speculative.execution false

rmf /tmp/tf_idf_scores.txt

import 'tfidf.macro';

emails = load '/me/Data/test_mbox' using AvroStorage();
id_body = foreach emails generate message_id, body;

-- Not currently used!
define test_stream `token_extractor.py` SHIP ('../python/token_extractor.py');
cleaned_words = stream id_body through test_stream as (message_id:chararray, token_strings:chararray);
token_records = foreach cleaned_words generate message_id, FLATTEN(TokenizeText(token_strings)) as tokens;

tf_idf_scores = tf_idf(id_body, 'message_id', 'body');
store tf_idf_scores into '/tmp/tf_idf_scores.txt';
