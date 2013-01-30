use agile_data
show collections
db.emails_per_address.ensureIndex({address: 1});
db.emails_per_address.findOne()
// {
//  "_id" : ObjectId("50f1cfe93004acab8d0340ea"),
//  "address" : "user@pig.apache.org",
//  "messages" : [
//    {
//      "message_id" : "2CC96549-8E00-46BF-998E-5606B6952467@gmail.com",
//      "subject" : "Re: Group by with count",
//      "date" : "2012-12-27T15:36:58"
//    },
//    {
//      "message_id" : "2CC96549-8E00-46BF-998E-5606B6952467@gmail.com",
//      "subject" : "Re: Group by with count",
//      "date" : "2012-12-27T15:36:58"
//    },
//    {
//      "message_id" : "2CC96549-8E00-46BF-998E-5606B6952467@gmail.com",
//      "subject" : "Re: Group by with count",
//      "date" : "2012-12-27T15:36:58"
//    },
//    ...
db.addresses_per_email.ensureIndex({message_id: 1});
db.addresses_per_email.findOne()
// {
//  "_id" : ObjectId("50f1d8453004db7be37cffb0"),
//  "message_id" : "kl59ip.iuzmp1@",
//  "addresses" : [
//    {
//      "address" : "artifacts@computerhistory.org"
//    },
//    {
//      "address" : "russell.jurney@gmail.com"
//    },
//    {
//      "address" : "russell.jurney@gmail.com"
//    }
//  ]
// }
db.sent_distributions.ensureIndex({address: 1})
db.sent_distributions.findOne()
// {
//  "_id" : ObjectId("50f365ba30042ade8f22cb86"),
//  "address" : "russell.jurney@gmail.com",
//  "sent_distribution" : [
//    {
//      "sent_hour" : "00",
//      "total" : NumberLong(435)
//    },
//    {
//      "sent_hour" : "01",
//      "total" : NumberLong(307)
//    },
//    ...
//  ]
// }
