/* Set Home Directory - where we install software */
%default HOME `echo \$HOME/Software/`

/* Avro uses json-simple, and is in piggybank until Pig 0.12, where AvroStorage and TrevniStorage are builtins */
REGISTER $HOME/pig/build/ivy/lib/Pig/avro-1.5.3.jar
REGISTER $HOME/pig/build/ivy/lib/Pig/json-simple-1.1.jar
REGISTER $HOME/pig/contrib/piggybank/java/piggybank.jar

DEFINE AvroStorage org.apache.pig.piggybank.storage.avro.AvroStorage();
DEFINE LENGTH org.apache.pig.piggybank.evaluation.string.LENGTH();

REGISTER $HOME/varaha/lib/*.jar /* */
REGISTER $HOME/varaha/target/varaha-1.0-SNAPSHOT.jar 

DEFINE TokenizeText varaha.text.TokenizeText();
DEFINE StanfordTokenize varaha.text.StanfordTokenize();

/* Data Fu */
REGISTER $HOME/datafu/dist/datafu-0.0.9-SNAPSHOT.jar
REGISTER $HOME/datafu/lib/*.jar /* */

DEFINE Quantile datafu.pig.stats.Quantile('0.11','1.0');

set default_parallel 20

rmf /tmp/tf_idf_scores.txt
rmf /tmp/ntf_idf_scores.txt
rmf /tmp/trimmed_tokens.txt

register 'udfs.py' using jython as funcs;
import 'ntfidf.macro';

emails = load '/me/Data/test_mbox' using AvroStorage();
id_body_address = foreach emails generate message_id, body, from.address as address;

token_records_address = foreach id_body_address generate message_id, address, FLATTEN(TokenizeText(body)) as token;
/*token_counts = foreach (group token_records_address by token) generate (chararray)group as token:chararray, 
                                                                COUNT_STAR(token_records_address) as total;
quantiles = foreach (group token_counts all) {
  sorted = order token_counts by total;
  generate FLATTEN(Quantile(sorted.total)) as (low_filter, high_filter);
};

with_quantiles = cross quantiles, token_counts;
token_filter = filter with_quantiles by token_counts::total > quantiles::low_filter 
                                     and token_counts::total < quantiles::high_filter 
                                     and token_counts::total > 1
                                     and SIZE(token_counts::token) > 2;

filtered_tokens = join token_records_address by token, token_filter by token;
trimmed_tokens = foreach filtered_tokens generate token_records_address::message_id as message_id, 
                                                  funcs.remove_punctuation(token_records_address::token) as token;*/
trimmed_tokens = filter token_records_address by token is not null and token != '' and LENGTH(token) > 2;
store trimmed_tokens into '/tmp/trimmed_tokens.txt';

ntf_idf_scores_per_message = ntf_idf(trimmed_tokens, 'message_id', 'token');
store ntf_idf_scores_per_message into '/tmp/ntf_idf_scores_per_message.txt';

ntf_idf_scores_per_address = ntf_idf(trimmed_tokens, 'address', 'token');
store ntf_idf_scores_per_address into '/tmp/ntf_idf_scores_per_address.txt';
