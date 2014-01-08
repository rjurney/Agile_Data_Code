/* Set Home Directory - where we install software */
%default HOME `echo \$HOME/Software/`

/* Avro uses json-simple, and is in piggybank until Pig 0.12, where AvroStorage and TrevniStorage are builtins */
REGISTER $HOME/pig/build/ivy/lib/Pig/avro-1.7.4.jar
REGISTER $HOME/pig/build/ivy/lib/Pig/json-simple-1.1.jar
REGISTER $HOME/pig/contrib/piggybank/java/piggybank.jar

DEFINE AvroStorage org.apache.pig.piggybank.storage.avro.AvroStorage();
DEFINE LENGTH org.apache.pig.piggybank.evaluation.string.LENGTH();

REGISTER $HOME/varaha/lib/*.jar /* Varaha has a good tokenizer */
REGISTER $HOME/varaha/target/varaha-1.0-SNAPSHOT.jar 

DEFINE TokenizeText varaha.text.TokenizeText('1', '1');

set default_parallel 20

rmf /tmp/tf_idf_scores.txt
rmf /tmp/ntf_idf_scores.txt
rmf /tmp/trimmed_tokens.txt

register 'udfs.py' using jython as funcs;
import 'ntfidf.macro';

/* Load emails and trim unneeded fields */
emails = load '/me/Data/test_mbox' using AvroStorage();
-- emails = FILTER emails BY body IS NOT NULL;
id_body_address = foreach emails generate message_id, body, from.address as address;

/* Project and latten to message_id/address/token and basic filter */
token_records_address = foreach id_body_address generate message_id, address, FLATTEN(TokenizeText(body)) as token;
trimmed_tokens = filter token_records_address by token is not null and token != '' and LENGTH(token) > 2;
store trimmed_tokens into '/tmp/trimmed_tokens.txt';

/* Run topics per message */
ntf_idf_scores_per_message = ntf_idf(trimmed_tokens, 'message_id', 'token');
store ntf_idf_scores_per_message into '/tmp/ntf_idf_scores_per_message.txt';

/* Run topics per email address */
ntf_idf_scores_per_address = ntf_idf(trimmed_tokens, 'address', 'token');
store ntf_idf_scores_per_address into '/tmp/ntf_idf_scores_per_address.txt';
