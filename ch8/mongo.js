use agile_data
show collections
db.emails_per_address.findOne()
// {
//  "_id" : ObjectId("50f1cfe93004acab8d0340ea"),
//  "address" : "user@pig.apache.org",
//  "address_messages" : [
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
db.addresses_per_email.findOne()
// {
//  "_id" : ObjectId("50f1d57930043309e9c06304"),
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
