import pyelasticsearch
elastic = pyelasticsearch.ElasticSearch('http://localhost:9200/inbox')
results = elastic.search("russell.jurney@gmail.com", index="sent_counts")
print results
