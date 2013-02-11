/* Set Home Directory - where we install software */
%default HOME `echo \$HOME/Software/`

/* Avro uses json-simple, and is in piggybank until Pig 0.12, where AvroStorage and TrevniStorage are builtins */
REGISTER $HOME/pig/build/ivy/lib/Pig/avro-1.5.3.jar
REGISTER $HOME/pig/build/ivy/lib/Pig/json-simple-1.1.jar
REGISTER $HOME/pig/contrib/piggybank/java/piggybank.jar

DEFINE AvroStorage org.apache.pig.piggybank.storage.avro.AvroStorage();

REGISTER $HOME/varaha/lib/*.jar /* */
REGISTER $HOME/varaha/target/varaha-1.0-SNAPSHOT.jar 

DEFINE TokenizeText varaha.text.TokenizeText();
DEFINE StanfordTokenize varaha.text.StanfordTokenize();

rmf /tmp/test_lucene.txt
rmf /tmp/test_stanford.txt

set default_parallel 5
set mapred.map.tasks.speculative.execution false
set mapred.reduce.tasks.speculative.execution false

emails = load '/me/Data/test_mbox' using AvroStorage();
emails = limit emails 10;
id_body = foreach emails generate message_id, body;

token_records = foreach id_body generate message_id, FLATTEN(TokenizeText(body)) as tokens;
token_records_2 = foreach id_body generate message_id, FLATTEN(StanfordTokenize(body)) as tokens;
store token_records into '/tmp/test_lucene.txt';
store token_records_2 into '/tmp/test_stanford.txt';