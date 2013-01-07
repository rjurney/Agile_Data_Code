import pyelasticsearch
elastic = pyelasticsearch.ElasticSearch('http://localhost:9200/inbox')
results = elastic.search("from:russell.jurney@gmail.com", index="sentcounts")
print results
