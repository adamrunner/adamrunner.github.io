---
layout: post
title: Adventures in programming the ESP8266
---
![Picture of ESP8266](/img/esp8266-01.jpg)

The ESP8266 has been out for a little over a year now, and even when it was first released it was making waves. $4-$5 USD cost, Wireless 802.11b/g/n, microprocessor with GPIOs and analog inputs, oh my! I was an early-ish adopter of the ESP8266 - though it always confused me exactly *what* I was going to do with it.

### Adapting

Not to mention *how* to build it because the ESP8266 (specifically the ESP-01) has a very odd footprint; and isn't breadboard-able. At least not without a special adapter. I eventually was able to build up an adapter of my own - it works pretty well. The one pictured here (which was not the one I made), was $7 USD at the time of writing. More costly than the ESP8266 board in the first place!

<img src="/img/esp01-breadboard.jpg" style="margin: 10px auto; display: block;" />

### It's what temperature in here?

One of my favorite applications for the ESP8266 is the wireless sensor applications - my goto is usually temperature (it's like the Hello World of IoT). But being kind of a data nerd I enjoy anything that will collect data and store it.

Initially I had used the [NodeMCU](https://github.com/nodemcu/nodemcu-firmware) firmware on the ESP8266, and it was fine. Initially it was a bit buggy, but workable, and you needed to know Lua to program it. It was very easy to upload new scripts to the device, which was certainly a plus. But working with the NodeMCU interface was odd to say the least.

Recently, the Arduino IDE has started supporting the ESP8266 boards. This allows you to use the Arduino libraries on the ESP8266, along with using the Arduino programming language (which is really just C). This makes integrating with other devices - like ones that are already supported on the Arduino platform fairly trivial.

### Sensing things

![Picture of DS18B20](/img/ds18b20.jpg)

For this project I was going to integrate a DS18S20 - a OneWire Temperature sensor, with the ESP8266 and have it report the temperature to an endpoint at a configurable interval. The endpoint should be an arbitrary web endpoint - something similar to [ThingSpeak](https://thingspeak.com/) or [data.sparkfun.com](https://data.sparkfun.com) (aka Phant).

### Putting it all together
![Breadboard with all the components](/img/esp-temp-data-breadboard.jpg)
_From bottom left: 3.3v regulator, ESP8266 - ESP-01 version, USB FTDI Cable, DS18S20 Breakout Board. Reset button is on the left, GPIO 1 / programming button is on the right_

Using some pre-assembled modules made this process significantly simpler to deal with. On the breadboard I have a 3.3v regulator (came with my ESP8266) - which is good to up to 500ma @ 3.3v, and can accept voltage up to 6-9v (I typically run it at 6v).

I've got a trusty FTDI USB Adapter - that runs at either 3.3v or 5v (obviously using 3.3v for the ESP8266). This allows me to communicate with the ESP8266 via Serial.

Also wired up a couple of buttons to my ESP8266, reset and GPIO 1. Both of these are required for getting the ESP8266 into programming mode. (You reset the ESP8266 and hold the button connected to GPIO 1 - which is connected to ground - to kick the ESP8266 into programming mode for flashing.)

### Some code!
Here's the whole code that I'm using to send the temperature of my apartment to the internet every 10 minutes.

Not too shabby! Thank goodness for libraries. This code doesn't currently use the [Dallas Temperature Control library](http://milesburton.com/Dallas_Temperature_Control_Library) which would make this even easier to read and understand. The only real complex portion of this code is reading from and writing to the OneWire temperature sensor. The implementation here was taken from the example files for the DS18x20 sensor libraries on Arduino.

The code isn't overly complex - connects to wifi initially, then every 10 minutes it reads the sensor, gets back the temperature (in celsius), converts it to fahrenheit, and then sends the value to data.sparkfun.com.

It tracks the interval by checking the output of `millis()` instead of using `delay()`, this frees up the microprocessor to do other things in between sends. If you were running this sensor off battery - you'd want to deep sleep here.

<script src="https://gist.github.com/adamrunner/7200f6fa58c7ad3d4633.js"></script>

### Go Build something

I hope you enjoyed learning about the ESP8266 as much as I have, for future plans I've got a few different applications in mind.

* More temperature sensors
* Wirelessly controlled relay
* Humidity / Temperature sensor - for the bathroom
* Outdoor weather station. Might need more GPIOs for that one!
