---
layout: post
title: Installing ElasticSearch on Ubuntu 14.04 Server (part 2)
---

[In my last post](/2016-03-24-elastic-search-part-1) we got our environment all setup and running at DigitalOcean, or you setup your own server however you'd like. Regardless, I'm assuming that you have SSH access to your server currently. We're going to go over some best practices for servers, and also configuration and installation of ElasticSearch.

### Installing dependencies for ElasticSearch
ElasticSearch runs on Java, and Ubuntu doesn't ship with Java installed. So we'll need to fix that, the version of Java I'm using is Oracle Java 8 JDK. It's the latest stable version at the time of this writing. To install it via a repository we'll have to add the PPA for Java (provided by the [webupd8team](http://www.webupd8.org/)) to Ubuntu.

~~~
sudo add-apt-repository ppa:webupd8team/java
sudo apt-get update
sudo apt-get install oracle-java8-installer
~~~

The last command there will install the installer for Oracle Java 8, you'll get a prompt to accept the license agreement, and then it should be installed successfully.
To check, we'll just ask `java` what version it is:

~~~
adamrunner@ubuntu:~$ java -version
java version "1.8.0_77"
Java(TM) SE Runtime Environment (build 1.8.0_77-b03)
Java HotSpot(TM) 64-Bit Server VM (build 25.77-b03, mixed mode)
~~~

Well we've got Java up and running, time to move on to ElasticSearch. ElasticSearch also offers a repository to allow us to quickly install ElasticSearch, and get updates as they're published. To install it, we'll need to import Elastic.co's GPG Key, and add the repository URL to our `sources.list`.

~~~
sudo ls
wget -qO - https://packages.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -
echo "deb http://packages.elastic.co/elasticsearch/2.x/debian stable main" | sudo tee -a /etc/apt/sources.list.d/elasticsearch-2.x.list
sudo apt-get update && sudo apt-get install elasticsearch
~~~

These commands will:

1. Call the `ls` command with `sudo`, just to make sure `sudo` hasn't timed out. (you might end up waiting at a weird prompt if `sudo` has timed out.)
1. Pull the GPG key from Elastic.co, and then subsequently import it
1. Add the ElasticSearch package to our sources.
1. Update the sources so `apt-get` knows about the new `elasticsearch` package.
1. Install ElasticSearch.

### Changing configuration
At this point we'll want to change some of the default configuration for ElasticSearch to values that will work better for us. ElasticSearch's configuration is stored in a `.yml` file under the `/etc/elasticsearch` folder. We're going to change the cluster name, the node name, and the IP address that ElasticSearch binds to.

Use this command to open the ElasticSearch config file in vim. `sudo vim /etc/elasticsearch/elasticsearch.yml`

You'll want to change these values in that configuration file, the cluster name and node name can be whatever you want. But the binding IP address should be changed to 0.0.0.0 if you want to be able to access your ElasticSearch cluster from anywhere besides `localhost`.

~~~yml
#Change these values in /etc/elasticsearch/elasticsearch.yml
cluster.name: Adam's ElasticSearch App
node.name: node-1
network.host: 0.0.0.0
~~~

Next, we'll want to configure ElasticSearch to start at boot time, then we'll go ahead and start ElasticSearch and get to know it.

~~~
sudo update-rc.d elasticsearch defaults 95 10
sudo service elasticsearch start
~~~

Finally, we'll query ElasticSearch and verify that it is up and running.

~~~
adamrunner@ubuntu:~$ curl -XGET http://localhost:9200
{
  "name" : "node-1",
  "cluster_name" : "Adam's ElasticSearch App",
  "version" : {
    "number" : "2.2.1",
    "build_hash" : "d045fc29d1932bce18b2e65ab8b297fbf6cd41a1",
    "build_timestamp" : "2016-03-09T09:38:54Z",
    "build_snapshot" : false,
    "lucene_version" : "5.4.1"
  },
  "tagline" : "You Know, for Search"
}
~~~

The cluster name and node name that you set should be reflected here, if you'd like to test and verify that your server is accessible from the internet. You can run the same Curl command from your local terminal, just replace `localhost` with the IP address of your server.
