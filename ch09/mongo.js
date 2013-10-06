// Drop all relations, to recreate
db.overall_reply_ratio.drop();
db.from_to_reply_ratios.drop();
db.p_sent_from_to.drop();
db.hourly_from_reply_probs.drop();
db.p_sent_hour.drop();
db.token_reply_rates.drop();

db.p_token.ensureIndex({'token': 1})
db.token_reply_rates.ensureIndex({'token': 1})
db.token_no_reply_rates.ensureIndex({'token': 1})
db.from_to_reply_ratios.ensureIndex({from: 1, to: 1})
db.from_to_no_reply_ratios.ensureIndex({from: 1, to: 1})

// {
//  "_id" : ObjectId("511700c330048b60597e7c04"),
//  "token" : "public",
//  "reply_rate" : 0.6969366812896153
// }