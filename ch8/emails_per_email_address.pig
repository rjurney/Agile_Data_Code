/* Avro uses json-simple, and is in piggybank until Pig 0.12, where AvroStorage and TrevniStorage are builtins */
REGISTER /me/Software/pig/build/ivy/lib/Pig/avro-1.5.3.jar
REGISTER /me/Software/pig/build/ivy/lib/Pig/json-simple-1.1.jar
REGISTER /me/Software/pig/contrib/piggybank/java/piggybank.jar

DEFINE AvroStorage org.apache.pig.piggybank.storage.avro.AvroStorage();

/* MongoDB libraries and configuration */
REGISTER /me/Software/mongo-hadoop/mongo-2.10.1.jar
REGISTER /me/Software/mongo-hadoop/core/target/mongo-hadoop-core-1.1.0-SNAPSHOT.jar
REGISTER /me/Software/mongo-hadoop/pig/target/mongo-hadoop-pig-1.1.0-SNAPSHOT.jar

DEFINE MongoStorage com.mongodb.hadoop.pig.MongoStorage();

set default_parallel 5
set mapred.map.tasks.speculative.execution false
set mapred.reduce.tasks.speculative.execution false

/* Filter emails according to existence of header pairs: [from, to, cc, bcc, reply_to]
Then project the header part, message_id and subject, and emit them, lowercased. */
DEFINE headers_messages(email, col) RETURNS set { 
  filtered = FILTER $email BY ($col IS NOT NULL);
  flat = FOREACH filtered GENERATE FLATTEN($col.address) AS $col, message_id, subject, date;
  lowered = FOREACH flat GENERATE LOWER($col) AS address, message_id, subject, date;
  $set = FILTER lowered BY (address IS NOT NULL) and (address != '') and (date IS NOT NULL);
}

/* Nuke the email/address index, as we are about to replace it. */
sh curl -XDELETE 'http://localhost:9200/address/emails'
/* Nuke the Mongo store, as we are about to replace it. */
-- sh mongo agile_data --eval 'db.emails_per_address.drop\(\)'

rmf /tmp/emails_per_address.json

emails = load '/me/Data/test_mbox' using AvroStorage();
froms = foreach emails generate LOWER(from.address) as address, message_id, subject, date;
froms = filter froms by (address IS NOT NULL) and (address != '') and (date IS NOT NULL);
tos = headers_messages(emails, 'tos');
ccs = headers_messages(emails, 'ccs');
bccs = headers_messages(emails, 'bccs');
reply_tos = headers_messages(emails, 'reply_tos');

address_messages = UNION froms, tos, ccs, bccs, reply_tos;

emails_per_address = group address_messages by address;
emails_per_address = foreach emails_per_address { address_messages = order address_messages by date desc;
                                                  generate group as address, 
                                                                    address_messages as address_messages; }

store emails_per_address into 'mongodb://localhost/agile_data.emails_per_address' using MongoStorage();
