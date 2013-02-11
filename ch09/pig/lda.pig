/* Set Home Directory - where we install software */
%default HOME `echo \$HOME/Software/`

/* Avro uses json-simple, and is in piggybank until Pig 0.12, where AvroStorage and TrevniStorage are builtins */
REGISTER $HOME/pig/build/ivy/lib/Pig/avro-1.5.3.jar
REGISTER $HOME/pig/build/ivy/lib/Pig/json-simple-1.1.jar
REGISTER $HOME/pig/contrib/piggybank/java/piggybank.jar

DEFINE AvroStorage org.apache.pig.piggybank.storage.avro.AvroStorage();

REGISTER $HOME/varaha/lib/*.jar /* */
REGISTER $HOME/varaha/target/varaha-1.0-SNAPSHOT.jar

define TokenizeText varaha.text.TokenizeText();
define LDATopics varaha.topic.LDATopics();
define RangeConcat org.pygmalion.udf.RangeBasedStringConcat('0', ' ');

set default_parallel 10
set mapred.map.tasks.speculative.execution false
set mapred.reduce.tasks.speculative.execution false

-- 
-- Load the docs
-- 
emails = load '/me/Data/test_mbox' using AvroStorage();
raw_documents = foreach emails generate message_id, body;
--
-- Tokenize text to remove stopwords
--
tokenized = foreach raw_documents generate message_id, flatten(TokenizeText(body)) as (token:chararray);
 
--
-- Concat the text for a given doc with spaces
--
documents = foreach (group tokenized by message_id) generate group as message_id, RangeConcat(tokenized.token) as text;
 
--
-- Ensure all our documents are sane
--
for_lda = filter documents by message_id IS NOT NULL and text IS NOT NULL;
 
--
-- Group the docs by all and find topics
--
-- WARNING: This is, in general, not appropriate in a production environment.
-- Instead it is best to group by some piece of metadata which partitions
-- the documents into smaller groups.
--
topics = foreach (group for_lda all) generate
           FLATTEN(LDATopics(20, for_lda)) as (
           topic_num:int,
           keywords:bag {t:tuple(keyword:chararray, weight:int)}
         );
 
 
store topics into '/tmp/lda_topics.txt';