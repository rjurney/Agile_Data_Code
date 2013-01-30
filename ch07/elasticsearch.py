import pyelasticsearch
elastic = pyelasticsearch.ElasticSearch('http://localhost:9200/inbox')
results = elastic.search("hadoop", index="emails")
print results
results2 = elastic.search({'query': {"term": { "body": query}}, 'from': 0, 'size': 20}, index="emails")
print results2


