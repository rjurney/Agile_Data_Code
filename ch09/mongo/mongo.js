use agile_data
show collections
// ...
// related_addresses
// ...
db.related_addresses.ensureIndex({address: 1});
db.related_addresses.find();
// {
//  "_id" : ObjectId("510310973004067183acaf5f"),
//  "address" : "dev@pig.apache.org",
//  "related_addresses" : [
//    {
//      "to" : "pig-dev@hadoop.apache.org"
//    },
//    {
//      "to" : "dev@pig.apache.org"
//    },
//    {
//      "to" : "daijyc@gmail.com"
//    },
//    {
//      "to" : "julien@ledem.net"
//    },
//    {
//      "to" : "dvryaboy@gmail.com"
//    },
//    {
//      "to" : "jcoveney@gmail.com"
//    },
//    {
//      "to" : "cheolsoo@cloudera.com"
//    },
//    {
//      "to" : "thejas.nair@yahoo.com"
//    },
//    {
//      "to" : "rding@yahoo-inc.com"
//    },
//    {
//      "to" : "sms@apache.org"
//    }
//  ]
// }
show collections
// ...
// topics_per_email
// ...
db.topics_per_document.ensureIndex({message_id: 1})
db.topics_per_document.findOne();

