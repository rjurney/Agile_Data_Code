use agile_data
show collections
db.emails_per_address.ensureIndex({address: 1});
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
db.addresses_per_email.ensureIndex({address: 1});
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
db.sent_distributions.findOne()
// {
//  "_id" : ObjectId("50f365ba30042ade8f22cb86"),
//  "sender_email_address" : "russell.jurney@gmail.com",
//  "sent_distribution" : [
//    {
//      "sent_hour" : "00",
//      "total" : NumberLong(435)
//    },
//    {
//      "sent_hour" : "01",
//      "total" : NumberLong(307)
//    },
//    {
//      "sent_hour" : "02",
//      "total" : NumberLong(196)
//    },
//    {
//      "sent_hour" : "03",
//      "total" : NumberLong(147)
//    },
//    {
//      "sent_hour" : "04",
//      "total" : NumberLong(144)
//    },
//    {
//      "sent_hour" : "05",
//      "total" : NumberLong(120)
//    },
//    {
//      "sent_hour" : "06",
//      "total" : NumberLong(102)
//    },
//    {
//      "sent_hour" : "07",
//      "total" : NumberLong(142)
//    },
//    {
//      "sent_hour" : "08",
//      "total" : NumberLong(188)
//    },
//    {
//      "sent_hour" : "09",
//      "total" : NumberLong(293)
//    },
//    {
//      "sent_hour" : "10",
//      "total" : NumberLong(410)
//    },
//    {
//      "sent_hour" : "11",
//      "total" : NumberLong(503)
//    },
//    {
//      "sent_hour" : "12",
//      "total" : NumberLong(657)
//    },
//    {
//      "sent_hour" : "13",
//      "total" : NumberLong(698)
//    },
//    {
//      "sent_hour" : "14",
//      "total" : NumberLong(755)
//    },
//    {
//      "sent_hour" : "15",
//      "total" : NumberLong(730)
//    },
//    {
//      "sent_hour" : "16",
//      "total" : NumberLong(713)
//    },
//    {
//      "sent_hour" : "17",
//      "total" : NumberLong(745)
//    },
//    {
//      "sent_hour" : "18",
//      "total" : NumberLong(655)
//    },
//    {
//      "sent_hour" : "19",
//      "total" : NumberLong(607)
//    },
//    {
//      "sent_hour" : "20",
//      "total" : NumberLong(555)
//    },
//    {
//      "sent_hour" : "21",
//      "total" : NumberLong(589)
//    },
//    {
//      "sent_hour" : "22",
//      "total" : NumberLong(514)
//    },
//    {
//      "sent_hour" : "23",
//      "total" : NumberLong(482)
//    }
//  ]
// }
