/* Avro uses json-simple, and is in piggybank until Pig 0.12, where AvroStorage and TrevniStorage are builtins */
REGISTER /me/Software/pig/build/ivy/lib/Pig/avro-1.5.3.jar
REGISTER /me/Software/pig/build/ivy/lib/Pig/json-simple-1.1.jar
REGISTER /me/Software/pig/contrib/piggybank/java/piggybank.jar

DEFINE AvroStorage org.apache.pig.piggybank.storage.avro.AvroStorage();

REGISTER /me/Software/varaha/lib/*.jar /* */
REGISTER /me/Software/varaha/target/varaha-1.0-SNAPSHOT.jar 

DEFINE TokenizeText varaha.text.TokenizeText();
DEFINE StanfordTokenize varaha.text.StanfordTokenize();

/* Data Fu */
REGISTER /me/Software/datafu/dist/datafu-0.0.9-SNAPSHOT.jar
REGISTER /me/Software/datafu/lib/*.jar /* */

DEFINE Quantile datafu.pig.stats.Quantile('0.21','1.0');

set default_parallel 20

rmf /tmp/tf_idf_scores.txt
rmf /tmp/trimmed_tokens.txt

register 'udfs.py' using jython as funcs;
import 'tfidf.macro';

emails = load '/me/Data/test_mbox' using AvroStorage();
just_id_body = foreach emails generate message_id, body;

token_records_a = foreach just_id_body generate message_id, FLATTEN(TokenizeText(body)) as token;
token_counts = foreach (group token_records_a by token) generate (chararray)group as token:chararray, 
                                                                COUNT_STAR(token_records_a) as total;
quantiles = foreach (group token_counts all) {
  sorted = order token_counts by total;
  generate FLATTEN(Quantile(sorted.total)) as (low_filter, high_filter);
};

with_quantiles = cross quantiles, token_counts;
token_filter = filter with_quantiles by token_counts::total > quantiles::low_filter 
                                     and token_counts::total < quantiles::high_filter 
                                     and token_counts::total > 1
                                     and SIZE(token_counts::token) > 2;

filtered_tokens = join token_records_a by token, token_filter by token;
trimmed_tokens = foreach filtered_tokens generate token_records_a::message_id as message_id, 
                                                  funcs.remove_punctuation(token_records_a::token) as token;
trimmed_tokens = filter trimmed_tokens by token is not null and token != '' and SIZE(token) > 2;

store trimmed_tokens into '/tmp/trimmed_tokens.txt';

tf_idf_scores = tf_idf(trimmed_tokens, 'message_id', 'token');
tf_idf_scores = filter tf_idf_scores by score > 0.11 and token IS NOT NULL and token != '' and SIZE(token) > 2;

store tf_idf_scores into '/tmp/tf_idf_scores.txt';