/* Set Home Directory - where we install software */
%default HOME `echo \$HOME/Software/`

/* Avro uses json-simple, and is in piggybank until Pig 0.12, where AvroStorage and TrevniStorage are builtins */
REGISTER $HOME/pig/build/ivy/lib/Pig/avro-1.5.3.jar
REGISTER $HOME/pig/build/ivy/lib/Pig/json-simple-1.1.jar
REGISTER $HOME/pig/contrib/piggybank/java/piggybank.jar

DEFINE AvroStorage org.apache.pig.piggybank.storage.avro.AvroStorage();

/* MongoDB libraries and configuration */
REGISTER $HOME/mongo-hadoop/mongo-2.10.1.jar
REGISTER $HOME/mongo-hadoop/core/target/mongo-hadoop-core-1.1.0-SNAPSHOT.jar
REGISTER $HOME/mongo-hadoop/pig/target/mongo-hadoop-pig-1.1.0-SNAPSHOT.jar

DEFINE MongoStorage com.mongodb.hadoop.pig.MongoStorage();

set default_parallel 5
set mapred.map.tasks.speculative.execution false
set mapred.reduce.tasks.speculative.execution false

/* Macro to filter emails according to existence of header pairs: [from, to, cc, bcc, reply_to]
Then project the header part, message_id and subject, and emit them, lowercased. 

Note: you can't paste macros into Grunt as of Pig 0.11. You will have to execute this file. */
DEFINE headers_messages(email, col) RETURNS set { 
  filtered = FILTER $email BY ($col IS NOT NULL);
  flat = FOREACH filtered GENERATE FLATTEN($col.address) AS $col, message_id, subject, date;
  lowered = FOREACH flat GENERATE LOWER($col) AS address, message_id, subject, date;
  $set = FILTER lowered BY (address IS NOT NULL) and (address != '') and (date IS NOT NULL);
}

/* Nuke the Mongo stores, as we are about to replace it. */
-- sh mongo agile_data --quiet --eval 'db.emails_per_address.drop(); exit();'
-- sh mongo agile_data --quiet --eval 'db.addresses_per_email.drop(); exit();'

rmf /tmp/emails_per_address.json

emails = load '/me/Data/test_mbox' using AvroStorage();
froms = foreach emails generate LOWER(from.address) as address, message_id, subject, date;
froms = filter froms by (address IS NOT NULL) and (address != '') and (date IS NOT NULL);
tos = headers_messages(emails, 'tos');
ccs = headers_messages(emails, 'ccs');
bccs = headers_messages(emails, 'bccs');
reply_tos = headers_messages(emails, 'reply_tos');

address_messages = UNION froms, tos, ccs, bccs, reply_tos;

/* Messages per email address, sorted by date desc. Limit to 50 to ensure rapid access. */
emails_per_address = foreach (group address_messages by address) { 
                             address_messages = order address_messages by date desc;
                             top_50 = limit address_messages 50;
                             generate group as address, 
                                      top_50.(message_id, subject, date) as emails; 
                             }

store emails_per_address into 'mongodb://localhost/agile_data.emails_per_address' using MongoStorage();

/* Email addresses per email */
addresses_per_email = foreach (group address_messages by message_id) generate group as message_id, address_messages.(address) as addresses;
store addresses_per_email into 'mongodb://localhost/agile_data.addresses_per_email' using MongoStorage();
