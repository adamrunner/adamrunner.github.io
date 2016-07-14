---
layout: post
title: Sinatra + AssetPipeline + Haml Coffee Assets = Completely Awesome
---

[Sinatra](http://sinatrarb.com) is my simple web framework of choice. It gets out of your way and doesn't make any assumptions for you. This is excellent for smaller web applications and APIs. Which is an excellent way to ensure that your web app is small, simple and serves the basic needs; however the downfall of the simplicity is dealing with your assets manually or through something like Compass.

Rails does an excellent job with implementing assets, adding libraries and making it straightforward and sometimes possibly too easy to get your assets compiled, fingerprinted and served.

We'll go over how I start a Sinatra project and integrate it with the asset pipeline - without using rails. There's an [excellent Ruby gem](https://github.com/kalasjocke/sinatra-asset-pipeline) that handles the majority of this for us. But I'll also cover some of the implementation details so we can understand what's happening. We'll also add JavaScript templates to the mix, and get Haml Coffee working in Sinatra (which was the inspiration for this post).

Start a new empty Sinatra project. Methods vary on how to do this, but you can clone my [demo repo from here](https://www.github.com/adamrunner/sinatra-websockets-assets). I use this as a starting point for my small web applications.

### The Sinatra App

The Gemfile, you'll definitely need it configured with the correct gems to use the asset pipeline, and Haml Coffee Assets.

~~~ruby
# ./Gemfile
source 'https://rubygems.org'

gem 'rake'
gem 'sinatra'
gem 'sinatra-partial'
gem 'sinatra-flash'
gem 'haml'
gem 'sinatra-asset-pipeline'
gem 'pry'
gem 'sinatra-websocket', '0.3.1'
gem 'bootstrap'
gem 'thin'
gem 'therubyracer'
gem 'haml_coffee_assets'
~~~

We'll start a fairly normal looking Sinatra application. But we'll toss in some goodies for the asset pipeline. I typically hate building the basics over and over again, so I [just copy and clone from here](https://www.github.com/adamrunner/sinatra-websockets-assets).

- `Bundler.require` will make sure that all of your gems are being loaded, and in the correct context also.

- `require 'sinatra/asset_pipeline'` includes the files for the asset pipeline. You'll need to make sure that the plugin is registered also.

Next we'll set some variables, the `assets_debug` and `digest_assets` should be self explanatory. The `assets_prefix` variable is the location of where the asset requests will be coming to. I like the location of `/assets` in my URLs.

Since we're also going to use Haml Coffee Assets, we'll need to do an extra tweak, which is to append the path for the helper files that need loaded.

In the `configure` block, we'll call the `sprockets` method (which is the current instance of the sprockets engine) and then append the path for the `HamlCoffeeAssets` helpers. This will include the other javascript files that we need to compile Haml Coffee files. This was the missing piece that eluded me for a couple of days.

~~~ruby
# ./app.rb
Bundler.require

require 'sinatra'
require 'sinatra/asset_pipeline'

class App < Sinatra::Base
  register Sinatra::Partial
  register Sinatra::AssetPipeline
  set :haml, format: :html5
  set :assets_prefix, '/assets'
  set :assets_debug, true
  set :digest_assets, false

  configure do
    sprockets.append_path File.dirname(HamlCoffeeAssets.helpers_path)
  end

  get '/' do
    haml :index
  end
end

~~~

### Configuring Your Templates

I'm going to assume that you're using HAML, and the standard Sinatra file/folder structure for it. Since we've registered the AssetPipeline helpers, we can then use automatically generated tags - just like in Rails. You can set `expand: true` to break out the file into its individual components.

~~~haml
-# views/layout.haml
!!!
%html
  %head
    %title Assets In Sinatra
    %link{rel:"stylesheet", href:stylesheet_path('application')}
    %script{src: javascript_path('application', expand: true)}
  %body
  .container
    .row
      =yield
~~~

### Asset Structure
Since the asset pipeline can be picky, we'll need to follow the conventions that it uses, this will ensure that our files are properly discovered and treated correctly. Including getting concatenated and digested.

~~~
sinatra-asset-app/
├── assets/
│   ├── images/
│   │    └── fancy_image.png
│   ├── stylesheets/
│   │    └── application.css.scss
│   └── javascripts/
│        ├── templates/
│        │    └── flash_message.hamlc
│        ├── jquery-2.1.4.min.js
│        └── application.js.coffee
├── views/
│   ├── index.haml
│   └── layout.haml
├── app.rb
├── config.ru
├── Gemfile
├── Gemfile.lock
└── Rakefile
~~~

#### Stylesheets / SCSS

In the `application.css.scss` file, you can use the `import` directive and have access to the files that your gems provide. In this case I'm using Bootstrap.

~~~scss
@import "bootstrap-flex";

.list-group {
  margin-bottom:1em;
}
~~~

#### Javascript / Coffeescript / Haml Coffee Templates

Using the standard asset pipeline directives, we'll require any of the Javascript or CoffeeScript files in our app that we want to load. You can use all of the Sprockets directives here. We'll require the `hamlcoffee` file at this point, be sure to require it _above_ your templates.

~~~coffeescript
#= require 'jquery-2.1.4.min'
#= require hamlcoffee
#= require_tree ./templates
#= require_self

$ ->
  string = "Hello from Haml Coffee!"
  $("#flash_message").html JST['flash_message'] string: string
~~~

### Conclusion

If you've created your own app or cloned the demo, you should be able to start up the app and get started with a good platform. From here you can add in more CoffeeScript (or Javascript), add WebSockets or anything else.

Hopefully this plugs some of the holes that I found in documentation when originally determining how to use the asset pipeline with Sinatra.
