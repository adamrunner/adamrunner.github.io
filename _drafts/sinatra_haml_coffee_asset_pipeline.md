---
layout: post
title: Sinatra + AssetPipeline + Haml Coffee Assets
---

Sinatra is my simple web framework of choice. It gets out of your way and doesn't make any assumptions for you. This is excellent for smaller web applications and APIs. This is an excellent way to ensure that your web app is small and serves basic needs; however the downfall of this is dealing with manual or alternate processes to manage your assets. 

Rails does an excellent job with implementing assets, adding libraries and making it straightforward and sometimes possibly too easy to get your assets compiled, fingerprinted and served. 

We'll go over how I start a Sinatra project and integrate it with the asset pipeline - without using rails. There's an excellent Ruby gem that handles the majority of this for us. But I'll also cover some of the implementation details so we can understand what's happening. We'll also add JavaScript templates to the mix, and get Haml Coffee working in Sintra (which was the inspiration for this post).

1. Start a new empty Sinatra project. Methods vary on how to do this, but you can clone my demo repo from here. I use this as a starting point for my small web applications. 
2. Get all of our gems installed.
3. Create the required files. Assets, folders, etc. 
4. 

Cover asset pipeline in Sinatra 

Settings, and examples and how to use things like Haml Coffee

Use the [Sinatra AssetPipeline Gem](https://github.com/kalasjocke/sinatra-asset-pipeline) - which simplifies much of the implementation of the asset pipeline. 
