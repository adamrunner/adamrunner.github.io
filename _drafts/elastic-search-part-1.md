---
layout: post
title: Installing ElasticSearch on Ubuntu 14.04 Server (part 1)
---

This is going to be the first part in a multi-part series about ElasticSearch, I've recently started using it and researching it on some projects and I've been very interested so far. Just this fact alone seemed to make it a good candidate for a blog post. This first post is mainly about setting up the environment, if you'd like to skip ahead to the meat of the ElasticSearch stuff, [I've got a post for that](/2016-05-20-elastic-search-part-2).

### Installing ElasticSearch

Naturally, we're going to have to install ElasticSearch if we want to use it, there are plenty of guides that tell you how to do this; but they all seemed a bit older. I'm going to be using a [DigitalOcean droplet](https://m.do.co/c/b508d27b35f8) to run ElasticSearch on, but you can run it on whatever you want.

An old desktop that's been refurbished into a "server" would work fine. You could also use a Vagrant instance to host it, or another type of Virtual Machine. The main reason that I'm using DigitalOcean is that I want my ElasticSearch instance to be accessible from the internet.

Why DigitalOcean?

1. It's cheap. They've got servers starting out at $5/mo.
2. It's fast. Their provisioning process is very quick, and even the least expensive server is still quick to use.
3. It's simple. The control panel is very easy to navigate and use.
4. They've got a great community, and they definitely care about open source.
5. You can try it for free.

### Setup that environment.

If you're interested in following along on DigitalOcean, you can sign up using [my referral link](https://m.do.co/c/b508d27b35f8), and you'll get $10 of credit. That's enough to run a server for two months! (or for a few hours if you pick a giant instance).

We're going to start on the "Create Droplet" screen at DigitalOcean. At this screen you'll choose the operating system that you want to run on your server. I'm partial to Ubuntu, so that's what I'm going to choose here.

<img src="/img/digital_ocean_step1.png" class="center-block img-thumbnail" alt="Choose your operating system version, we're using Ubuntu 14.04.4 x64">

Next we're going to choose a size for our droplet, in theory just about any size would work however ElasticSearch does like to gobble up memory, and doesn't like to swap. I'd suggest using the $10/mo or higher size. My server that I chose was the 2GB version.

<img src="/img/digital_ocean_step2.png" class="center-block img-thumbnail" alt="Choose your size, at least 1GB of memory or greater">

Choosing a datacenter region. You'll want to choose whichever location is closest to you geographically, in my case it's the San Francisco datacenter.

<img src="/img/digital_ocean_step3.png" class="center-block img-thumbnail" alt="Choose the location closet to you, for me that's SFO">

Just a couple of other things. The final couple of steps you'll want to select IPv6 and enable it (I suppose you don't _have_ to but it seems silly not to) and you'll also want to import your SSH key! This part is very important! **You shouldn't use password authentication for SSH, pretty much ever.** SSH Keys are much more secure and much easier to deal with. I mean who likes passwords anyways?

<img src="/img/digital_ocean_step4.png" class="center-block img-thumbnail" alt="Please use SSH keys for login! No one likes passwords!">

You'll want to copy your *public* SSH key and paste it into the box. Give it a name, and then click the green "Add SSH Key" button. Use the command `cat ~/.ssh/id_rsa.pub` to view your public SSH key, select it and copy it (without any extra spaces).

~~~
cat ~/.ssh/id_rsa.pub
ssh-rsa BB3NzaC1yRur7QWFTFoMzSKc2EAAAADAQABAAABAQCZLgtS9GHJ5vdXDcpTOOy2FsIXMYO8F29aot5eYJz2pTrZsBhrKLrq8kzkck9rGXHi8p5r//kZ7FLhj5nglI7DXaaBBn7lQceF7pQtRdkFiCxKzPFdJ+ilklt+1WSzhAZngcs0+NKv64Kt92BfPXnM+AIqQDaMXBdHTevUQ39h9No0WYNd902e1hyZkn6zURvz3U1oMuqXP5MLpMAqQXWXmt5RgxygYfOWDUbIcTRapb7IZDQ5SCQGvBZ59cq+n9 someone@example.com
~~~

Choose a hostname: This hostname is (I believe) just for your machine locally / on your account. You should just be able to put whatever you want here.

Create it! Click the button and watch it do it's thing, you should get an email when it's all up and running.

[Next we'll log into the instance, set it up and get ElasticSearch installed.](/2016-03-25-elastic-search-part-2)
