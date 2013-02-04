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
db.topics.ensureIndex({message_id: 1})
db.topics_per_document.findOne();
// {
//  "_id" : ObjectId("510dd696300487247c9e0a0c"),
//  "message_id" : "CANSvDjrA-dea9T-iZ6wJOLBP_Kqriae3FMDasU2OxO0gfzxJjg@mail.gmail.com",
//  "topics" : [
//    {
//      "word" : "grass",
//      "score" : 0.31845143365191986
//    },
//    {
//      "word" : "plant",
//      "score" : 0.2810330077326449
//    },
//    {
//      "word" : "rye",
//      "score" : 0.20285020154575548
//    },
//    {
//      "word" : "sack",
//      "score" : 0.19571670266698085
//    },
//    {
//      "word" : "topsoil",
//      "score" : 0.19381049907089434
//    },
//    {
//      "word" : "warms",
//      "score" : 0.19207027153110176
//    },
//    {
//      "word" : "turf",
//      "score" : 0.1889872579345566
//    },
//    {
//      "word" : "weeds",
//      "score" : 0.16849717160426886
//    },
//    {
//      "word" : "winter",
//      "score" : 0.13641124134559518
//    },
//    {
//      "word" : "dad",
//      "score" : 0.12483962902570728
//    }
//  ]
// }
