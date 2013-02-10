/* Avro uses json-simple, and is in piggybank until Pig 0.12, where AvroStorage and TrevniStorage are builtins */
REGISTER /me/Software/pig/build/ivy/lib/Pig/avro-1.5.3.jar
REGISTER /me/Software/pig/build/ivy/lib/Pig/json-simple-1.1.jar
REGISTER /me/Software/pig/contrib/piggybank/java/piggybank.jar

DEFINE AvroStorage org.apache.pig.piggybank.storage.avro.AvroStorage();

REGISTER /me/Software/varaha/lib/*.jar /* */
REGISTER /me/Software/varaha/target/varaha-1.0-SNAPSHOT.jar 

DEFINE TokenizeText varaha.text.TokenizeText();

rmf /tmp/reply_rates.txt

emails = load '/me/Data/test_mbox' using AvroStorage();
id_body = foreach emails generate message_id, body;

token_records = foreach id_body generate message_id, FLATTEN(TokenizeText(body)) as token;
doc_word_totals = foreach (group token_records by (message_id, token)) generate 
  FLATTEN(group) as (message_id, token), 
  COUNT_STAR(token_records) as doc_total;
  
/* Calculate the document size */
pre_term_counts = foreach (group doc_word_totals by message_id) generate
  group AS message_id,
  FLATTEN(doc_word_totals.(token, doc_total)) as (token, doc_total), 
  SUM(doc_word_totals.doc_total) as doc_size;

/* Calculate the TF */
term_freqs = foreach pre_term_counts generate 
  message_id as message_id,
  token as token,
  ((double)doc_total / (double)doc_size) AS term_freq;

/* By Term - Calculate the SENT COUNT */
total_term_freqs = foreach (group term_freqs by token) generate (chararray)group as token, 
                                                                SUM(term_freqs.term_freq) as total_freq_sent;
  
replies = foreach emails generate message_id, in_reply_to;
with_replies = join term_freqs by message_id, replies by in_reply_to;

/* with_replies: 
{
  term_freqs::message_id: chararray,
  term_freqs::token: bytearray,
  term_freqs::term_freq: double,
  replies::message_id: chararray,
  replies::in_reply_to: chararray
} */

total_replies = foreach (group with_replies by term_freqs::token) generate (chararray)group as token, 
                                                                           SUM(with_replies.term_freqs::term_freq) as total_freq_replied;
sent_totals_reply_totals = JOIN total_term_freqs by token, total_replies by token;
token_reply_rates = foreach sent_totals_reply_totals generate total_term_freqs::token as token, (double)total_freq_replied / (double)total_freq_sent as reply_rate;

store token_reply_rates into '/tmp/reply_rates.txt';
