// Drop all relations, to recreate
db.overall_reply_ratio.drop();
db.from_to_reply_ratios.drop();
db.p_sent_from_to.drop();
db.hourly_from_reply_probs.drop();
db.p_sent_hour.drop();

db.from_to_reply_ratios.ensureIndex({from: 1, to: 1});
db.p_sent_from_to.ensureIndex({from: 1, to: 1});
db.p_hourly_from_reply_probs.ensureIndex({address: 1});
