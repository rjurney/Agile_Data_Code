/* Set Home Directory - where we install software */
%default HOME `echo \/me/Software/Software/`

/* Avro uses json-simple, and is in piggybank until Pig 0.12, where AvroStorage and TrevniStorage are builtins */
REGISTER /me/Software/pig/build/ivy/lib/Pig/avro-1.5.3.jar
REGISTER /me/Software/pig/build/ivy/lib/Pig/json-simple-1.1.jar
REGISTER /me/Software/pig/contrib/piggybank/java/piggybank.jar

DEFINE AvroStorage org.apache.pig.piggybank.storage.avro.AvroStorage();

REGISTER /me/Software/varaha/lib/*.jar /* */
REGISTER /me/Software/varaha/target/varaha-1.0-SNAPSHOT.jar 

DEFINE TokenizeText varaha.text.TokenizeText('1', '1')

rmf /tmp/reply_rates.txt
rmf /tmp/no_reply_rates.txt
rmf /tmp/p_token.txt

/* Load emails, trim fields to id/body */
emails = load '/me/Data/test_mbox' using AvroStorage();
id_body = foreach emails generate message_id, body;

/* Tokenize text, count of each token per document */
token_records = foreach id_body generate message_id, FLATTEN(TokenizeText(body)) as token;
doc_word_totals = foreach (group token_records by (message_id, token)) generate 
  FLATTEN(group) as (message_id, token), 
  COUNT_STAR(token_records) as doc_total;
  
/* Calculate the document size */
pre_term_counts = foreach (group doc_word_totals by message_id) generate
  group AS message_id,
  FLATTEN(doc_word_totals.(token, doc_total)) as (token, doc_total), 
  SUM(doc_word_totals.doc_total) as doc_size;

/* Calculate the Term Frequency */
term_freqs = foreach pre_term_counts generate 
  message_id as message_id,
  token as token,
  ((double)doc_total / (double)doc_size) AS term_freq;

/* By Term - Calculate the SENT COUNT */
total_term_freqs = foreach (group term_freqs by token) generate (chararray)group as token, 
                                                                SUM(term_freqs.term_freq) as total_freq_sent;

/* Calculate the probability of a given token occuring */
overall_total = foreach (group term_freqs all) generate SUM(term_freqs.term_freq) as total_freq_sent;
p_token = foreach (group term_freqs by token) generate group as token, (double)SUM(term_freqs.term_freq) / (double)overall_total.total_freq_sent as prob;
store p_token into '/tmp/p_token.txt';

replies = foreach emails generate message_id, in_reply_to;
with_replies = join term_freqs by message_id left outer, replies by in_reply_to;

/* Split, because we're going to calculate P(reply|token) and P(no reply|token) */
split with_replies into has_reply if (in_reply_to is not null), no_reply if (in_reply_to is null);

/* with_replies: 
{
  term_freqs::message_id: chararray,
  term_freqs::token: bytearray,
  term_freqs::term_freq: double,
  replies::message_id: chararray,
  replies::in_reply_to: chararray
} */

/* Calculate reply probability for all tokens */
total_replies = foreach (group has_reply by term_freqs::token) generate (chararray)group as token, 
                                                                        SUM(has_reply.term_freqs::term_freq) as total_freq_replied;
sent_totals_reply_totals = JOIN total_term_freqs by token, total_replies by token;
token_reply_rates = foreach sent_totals_reply_totals generate total_term_freqs::token as token, (double)total_freq_replied / (double)total_freq_sent as reply_rate;
store token_reply_rates into '/tmp/reply_rates.txt';

/* Calculate NO reply probability for all tokens */
total_no_reply = foreach (group no_reply by term_freqs::token) generate (chararray)group as token,
                                                                        SUM(no_reply.term_freqs::term_freq) as total_freq_no_reply;
sent_totals_no_reply_totals = JOIN total_term_freqs by token, total_no_reply by token;
token_no_reply_rates = foreach sent_totals_no_reply_totals generate total_term_freqs::token as token, (double)total_freq_no_reply / (double)total_freq_sent as reply_rate;
store token_no_reply_rates into '/tmp/no_reply_rates.txt';
