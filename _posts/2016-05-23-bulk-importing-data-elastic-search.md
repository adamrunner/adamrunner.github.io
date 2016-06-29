---
layout: post
title: Bulk Importing Data Into ElasticSearch
---

### Bulk Actions in ElasticSearch
Bulk actions in ElasticSearch are an excellent solution to the problem of.. "How on earth do I get all of this data into the index?". In this case, we're going to be moving the data from [data.sparkfun.com](https://data.sparkfun.com/streams/ZGRYvQ5b3gHl5rwqbKoj) over to an ElasticSearch instance. We're running the cluster locally in these examples, but anywhere that you have access to send commands to the cluster should work.

If we wanted to enter all of our JSON by hand, we could do it this way with a Curl command. We could also make the data span many many lines and records - this way we wouldn't have to make so many calls to our ElasticSearch cluster. If we were importing data single record at a time. 

~~~ bash
curl -XPOST 'localhost:9200/temperature/data/_bulk?pretty' -d '
{ "index" : { "_id" : null } }
{"outside_temp":48.27,"indoor_temp":"69.35","timestamp":"2016-03-27T07:49:56.392Z"}
'
~~~

Notice that the JSON looks formatted a bit different than normal JSON? If you thought that was the case, you're certainly correct. Because of how ElasticSearch imports data (or does "bulk" creates) we'll need to reformat our JSON a bit to fit their specification. ElasticSearch requires a "header" row that tells it what to do with the next line. In this case we're telling it to add the next line to the index; also ElasticSearch uses the literal line breaks (`\n`) to delineate rows. The format looks like this:

~~~ text
{header_information_including_action}
{source_document_to_be_processed}
{header_information_including_action}
{source_document_to_be_processed}

A header for the ElasticSearch bulk action looks like this:
{ "index" : { "_id" : null } }
~~~
This tells ElasticSearch to add the next object to the index, and to generate an ID for it. These are the default actions, there are other things you can do also while importing the data. This [post](https://www.elastic.co/guide/en/elasticsearch/reference/current/docs-bulk.html) from the ElasticSearch documentation gives much more detail on the ways you can upload bulk data.

Unfortunately for us, the data from [data.sparkfun.com](https://data.sparkfun.com/streams/ZGRYvQ5b3gHl5rwqbKoj) doesn't fit this specification, so we'll need to do some preparation for it to be moved into ElasticSearch. First, we'll need to collect the input data, we'll save it to `temp_data.json`.

~~~
wget -O temp_data.json https://data.sparkfun.com/output/ZGRYvQ5b3gHl5rwqbKoj.json
~~~

Next, we'll use the following Ruby code snippet to remove the JSON array notation, break each object onto it's own line, and also add in the header detail that ElasticSearch needs to process each row correctly. After processing the JSON, the script will write the data back to `temp_data.json`, where then we can copy it or send it to our ElasticSearch server.

~~~ ruby
  data = File.read("temp_data.json");
  #NOTE: Remove JSON array notation, it's not used with ElasticSearch
  data.gsub!(/\[\]/, "");
  #NOTE: Break each object onto it's own line
  data.gsub!("},{", "}\n{");

  new_data = [];
  #NOTE: Add the header data that ElasticSearch needs to process each line
  data.each_line {|s| new_data.push("{ \"index\" : { \"_id\" : null } }\n" + s) };

  File.open("temp_data.json", "w") {|file| file.write(new_data.join()) }
~~~

After running the above snippet, my `temp_data.json` file looks like this:
(exactly how ElasticSearch wants it)

~~~  json
{ "index" : { "_id" : null } }
{"outside_temp":48.27,"indoor_temp":"69.35","timestamp":"2016-03-27T07:49:56.392Z"}
...
~~~

### Importing our data into ElasticSearch
Next (on our ElasticSearch server), we run this one liner (after copying the `temp_data.json` file to our server) to bulk insert the data into the index. This command will return a giant JSON result indicating if each document was added to the index or not. If you're really interested in reading the result, you'll want to redirect the output of this command to a file, or pipe it to `less` or something similar.

~~~ bash
curl -XPOST 'localhost:9200/temperature/data/_bulk?pretty' --data-binary "@temp_data.json"
~~~
After the command runs, we should get a response.

~~~ json
{"took":7,"items":[{"create":{"_index":"temperature","_type":"data","_id":"1","_version":1}}....]}

~~~

### Verifying our success
We're going to be a bit extra paranoid now and ask ElasticSearch about the documents that it has for us, we should be able to assume that they were added to the index correctly; but it doesn't hurt to be a little paranoid. (And to double check our work)

~~~ bash
curl 'localhost:9200/_cat/indices?v'
~~~

You should get a response that looks like this. It describes everything going on with our indices (or index in this case).

~~~
health status index       pri rep docs.count docs.deleted store.size pri.store.size
yellow open   temperature   5   1       2980            0    437.3kb        437.3kb
~~~

* `health` - `green`, `yellow`, or `red`. This is the health of your cluster, `yellow` indicates that everything is fine, but there isn't a a high availability replica available. Since we are only running 1 node, this is expected. If we were to add another node to the cluster the status would eventually shift to `green` after the node was populated.
* `status` - If the index is accessible
* `index` - The name of your index
* `pri` - The number of primary shards
* `rep` - The number of replicas / nodes in the cluster for this index.
* `docs.count` - Number of documents
* `docs.deleted` - Presumably the number of documents deleted

### Success!

Well we got our data into ElasticSearch, now we just need to figure out what to do with it from there. Check back for another post where we figure out _how_ to do things with the data.
