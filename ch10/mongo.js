use agile_data
show collections
// ...
// p_
// ...
db.from_to_reply_ratios.ensureIndex({from: 1, to: 1});
db.from_to_reply_ratios.findOne();
// {
//  "_id" : ObjectId("5111653f3004769d48b77a5b"),
//  "from" : "russell.jurney@gmail.com",
//  "to" : "*******@hotmail.com",
//  "ratio" : 0.5
// }
db.hourly_from_reply_probs.ensureIndex({address: 1});
db.hourly_from_reply_probs.findOne();
// {
//  "_id" : ObjectId("5111644c3004641354d5ee5a"),
//  "address" : "russell.jurney@gmail.com",
//  "sent_distribution" : [
//    {
//      "hour" : "00",
//      "p_reply" : 0.452386044568
//    },
//    {
//      "hour" : "01",
//      "p_reply" : 0.419107010988
//    },
//    {
//      "hour" : "02",
//      "p_reply" : 0.376996004805
//    },
//    {
//      "hour" : "03",
//      "p_reply" : 0.373378364513
//    },
//    {
//      "hour" : "04",
//      "p_reply" : 0.384684325083
//    },
//    {
//      "hour" : "05",
//      "p_reply" : 0.36077309628
//    },
//    {
//      "hour" : "06",
//      "p_reply" : 0.334502638119
//    },
//    {
//      "hour" : "07",
//      "p_reply" : 0.35265450912
//    },
//    {
//      "hour" : "08",
//      "p_reply" : 0.393443865153
//    },
//    {
//      "hour" : "09",
//      "p_reply" : 0.413556502595
//    },
//    {
//      "hour" : "10",
//      "p_reply" : 0.41554459077
//    },
//    {
//      "hour" : "11",
//      "p_reply" : 0.424136664688
//    },
//    {
//      "hour" : "12",
//      "p_reply" : 0.426389776749
//    },
//    {
//      "hour" : "13",
//      "p_reply" : 0.42433862622
//    },
//    {
//      "hour" : "14",
//      "p_reply" : 0.430561787344
//    },
//    {
//      "hour" : "15",
//      "p_reply" : 0.4401130031
//    },
//    {
//      "hour" : "16",
//      "p_reply" : 0.441394882591
//    },
//    {
//      "hour" : "17",
//      "p_reply" : 0.429680151635
//    },
//    {
//      "hour" : "18",
//      "p_reply" : 0.412183264232
//    },
//    {
//      "hour" : "19",
//      "p_reply" : 0.401712032257
//    },
//    {
//      "hour" : "20",
//      "p_reply" : 0.417721335134
//    },
//    {
//      "hour" : "21",
//      "p_reply" : 0.431798982161
//    },
//    {
//      "hour" : "22",
//      "p_reply" : 0.420281556785
//    },
//    {
//      "hour" : "23",
//      "p_reply" : 0.394210023108
//    }
//  ]
// }