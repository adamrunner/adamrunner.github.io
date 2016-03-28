---
layout: post
title: Micro-service based architecture in IoT land.
---

In the [last post](/2016-02-27-esp8266-adventures) I made, we set up and ESP8266 to log the temperature in my apartment to the internet. One disadvantage that this has is that it's difficult to change any of the functionality that is programmed into the chip. For example: where you're sending the data, wanting to collect additional data, adding new sensors, etc. It was also difficult to retrieve the data on an ad-hoc basis, since I had to wait for the next interval to pass before the ESP8266 sent new data out from my sensors. I decided that it would be best to switch architectures at this point, and move to a system that was more modular.

These quotes about Unix seem to embody exactly what I was thinking about in solving this problem.

> This is the Unix philosophy: Write programs that do one thing and do it well. Write programs to work together. Write programs to handle text streams, because that is a universal interface.
[Salus] Peter H. Salus. A Quarter-Century of Unix. Addison-Wesley. 1994. ISBN 0-201-54777-5.

> Rule of Modularity: Write simple parts connected by clean interfaces.
  ~Unknown

### Planning/Design

In thinking down that road, I realized that I was muddling the concerns in the sensor module at that point. It was responsible for gathering the data, *and* sending the data out to be stored elsewhere. I was hitting a roadblock with wanting to introduce even more functionality by gathering outside temperature data from a web service. 

I realized this small sensor module should just have one single responsibility, gathering the indoor temperature of my apartment. Other data points should come from other nodes, sensors, or even external services.

I wanted to use [Forecast.IO](https://developer.forecast.io/) for gathering the outdoor temperature; because re-inventing the wheel of gathering the outdoor temperature seemed silly. Also by using an external weather source I can assume that the data is _reasonably_ accurate, and is isolated from adverse environmental affects. Whereas if I was attempting to do this on my own, there could be other factors (gathering temperature too close to the house, or in direct sunlight, etc) that could affect my readings.

Forecast.IO exposed a simple JSON API, and was free up to 1000 calls / day. It definitely seemed to fit the bill for this project.

Next I drew up my proposed modular architecture, it ended up looking something like this:

<img src="/img/esp8266_temperature_infastructure.svg" class="center-block img-thumbnail" alt="A horribly crude drawing of my micro-service style infrastructure.">

After thinking through this problem I was quite satisfied, using an architecture like this solved several problems that we run into in software engineering.

1. [Separation of concerns](https://en.wikipedia.org/wiki/Separation_of_concerns)
1. Not reinventing the wheel
1. Modular and able to be expanded on later (additional sensors, output methods, etc.)

### Implementation

There were several things to consider on the implementation side

1. Crafting a clean API / interface that would allow me to gather data from the sensors on a scheduled interval
1. Aggregation of the inside temperature data, outside temperature data, and ease of expansion in the future
1. Error handling if one of the services was not available

The first order of business was to reprogram the ESP8266 to just gather the temperature and allow something else to access the data. I opted to use HTTP for this task, it's fairly simple to implement and there is the added benefit that I could access the data from the node directly by using a web browser.  

My end product, after several iterations was a simple HTTP server that runs on the ESP8266 and checks the temperature about every 10 seconds or so. By using this type of interval I can ensure that the MCU isn't overwhelmed by constant communication with the temperature sensor, and at worst I get a temperature value that is 10 seconds old.

<script src="https://gist.github.com/adamrunner/700dda463f25ab56b97b.js"></script>

This gives me a very simple HTTP API to interact with, and I can even use the web browser on my computer or phone to check the current temperature.

~~~
curl -XGET http://192.168.1.110
Current Temp: 68.11°F

curl -XGET http://192.168.1.110/temp
68.11
~~~

Next I needed to build the aggregator script, the script that would run on the "hub" and manage the polling of data from sensors. I already have a server running Ubuntu Server 14.04 at home, so there wasn't much of a lift here. I originally toyed with the idea of tossing it on a Raspberry Pi, which I would have opted for if I didn't already have a fileserver running Ubuntu 14.04.

For this script I ended up with a fairly simple solution, though not elegant. I built a Ruby script that would interact with the sensor nodes, and then publish the data to an arbitrary service. Initially this was built for posting the data to [data.sparkfun.com](http://data.sparkfun.com). However recently I've been experimenting with ElasticSearch and am currently running my own node, so I'm also writing the data to the ElasticSearch index.

<script src="https://gist.github.com/adamrunner/05fd4af5da7728b9dfd7.js"></script>

### Do.. something with this data

If you've seen the [about me](/aboutme) page, you'll have a leg up on this section. I decided that an excellent way to represent the temperature data that I had been gathering was through a line graph. I settled on using the [Google Chart Javascript Library](https://developers.google.com/chart/) as it seemed to be fairly easy to work with. I have used [D3.js](https://d3js.org/) and also [HighCharts](http://www.highcharts.com/) so it was nice to check out another charting library. In retrospect Google Charts was an excellent decision for this project.

The implementation of Google Charts was basically painless

1. Request the data from the SparkFun JSON API
1. Add all of the rows of data to the data table object
1. Create a new chart, and pass in a reference to the DOM element where I wanted the chart rendered
1. Tell it to render the chart, and then done.

If you want to see the source code for the Google Chart implementation, check source of the [about me](/aboutme) page or [this Gist](https://gist.github.com/adamrunner/8221a232ac68bae90f48).

### Future Plans

1. Implement some date or filtering controls so I can use the chart for historical reporting, currently it just pulls the last "page" of data from the SparkFun API, this usually gives me a couple days worth of data; but it's not filterable.
1. Switch to using ElasticSearch to pull the data from. ElasticSearch is a powerful search index which could allow all sorts of fun things with the data.
1. Build an iOS app to pull the data directly from the sensor to my phone, in a widget.
1. Enhance the Ruby component of the application, so it's more resilient to failures. Currently if there is a problem it fails silently, and the execution of the script is not retried. Moving to a job queue could possibly solve this issue, but feels more complex than is needed.
1. Build a JavaScript application to interact with the ElasticSearch API to give us an interface for reading and working with the data.

Thanks for reading, and happy building!
