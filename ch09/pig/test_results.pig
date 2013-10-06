/* Set Home Directory - where we install software */
%default HOME `echo \$HOME/Software/`

/* Avro uses json-simple, and is in piggybank until Pig 0.12, where AvroStorage and TrevniStorage are builtins */
REGISTER $HOME/pig/build/ivy/lib/Pig/avro-1.5.3.jar
REGISTER $HOME/pig/build/ivy/lib/Pig/json-simple-1.1.jar
REGISTER $HOME/pig/contrib/piggybank/java/piggybank.jar

DEFINE AvroStorage org.apache.pig.piggybank.storage.avro.AvroStorage();
DEFINE ABS org.apache.pig.piggybank.evaluation.math.ABS();

rmf /tmp/final_answer.txt 

results = load '../results.txt' as (message_id:chararray, p_tokens_weight:double, p_from_to_reply_weight:double, p_reply:double);

emails = load '/me/Data/test_mbox' using AvroStorage();
emails = foreach emails generate message_id, in_reply_to;

with_results = join results by message_id left outer, emails by in_reply_to;

test_results = foreach with_results generate (double)((emails::message_id is not null) ? 1 : 0) as result:double, *;
errors = foreach test_results generate p_tokens_weight as p_tokens_weight,
                                      p_from_to_reply_weight as p_from_to_reply_weight,
                                      (double)ABS(result - p_reply) as error:double;
answer = foreach (group errors by (p_tokens_weight, p_from_to_reply_weight)) generate flatten(group) as (p_tokens_weight, p_from_to_reply_weight),
                                                                                         SUM(errors.error)/COUNT(errors.error) as avg_error;
final_answer = order answer by avg_error desc;
store final_answer into '/tmp/final_answer.txt';
