---
layout: post
title: Curl::Easy - maybe not.
---
## Curl::Easy - are we sure?

I think most people who've worked with the `Curl::Easy` ruby wrapper for `libcurl` have found it's [documentation](https://github.com/taf2/curb) to be a bit lacking.

So I'm going to give some examples here that will hopefully clear stuff up for people; and that I've found to be useful.

This example was notably absent from their GitHub readme.

POST to a server with an arbitrary XML (or JSON) string.

Do note - these don't handle the CSRF tokens that Rails typically requires, however that can be added.

## XML
~~~ ruby
  xml_string = File.read('xml_test.xml') #NOTE: Or just an XML string....
  c = Curl::Easy.http_post("http://myapp.dev/item", xml_string) do |curl|
        curl.headers['Accept']       = 'application/xml'
        curl.headers['Content-Type'] = 'application/xml'
      end

  #NOTE: To inspect your response - you have to ask the object about it...
  c.body
  #=> "<?xml version="1.0"?><response stat="ok"><method>Message#create</method></response>"
  #NOTE: You can also see the headers too!
  c.headers
  #=> {"Accept"=>"application/xml", "Content-Type"=>"application/xml"}
~~~

## JSON
~~~ ruby
  json_string = {setting: {do_something_ridiculous: true} }.to_json
  #NOTE: If you don't call #to_json on your hash - it will fail to be serialized properly

  c = Curl::Easy.http_put("http://myapp.dev/setting.json", json_string
      ) do |curl|
        curl.headers['Accept']       = 'application/json'
        curl.headers['Content-Type'] = 'application/json'
      end
  #NOTE: To inspect your response - you have to ask the object about it...    
  c.body
  #=>"{"some_key":["some_value"],"another_key":true,"different_key":1234567}"

  #NOTE: You can also see the headers too!
  c.headers
  #=> {"Accept"=>"application/json", "Content-Type"=>"application/json"}
~~~

## JSON w/CSRF token
You'll need to get the CSRF Token from somewhere - loading up a page in your browser should get you there.
If you inspect the page with Chrome Dev Tools, you'll find a `<meta>` tag with the appropriate CSRF token in it.

~~~ html
  <head>
  ...other things...
    <meta name="csrf-token" content="CSRF_TOKENS_ARE_LONG">
  </head>
~~~

Now go ahead and use that in your Ruby script with the `Curl::Easy` client. You'll also need to get the contents of your cookie, luckily that is fairly easy to do with the client. (Curl supports this on the command line application as well.)

~~~ ruby
  # Get the cookie from the CURL client
  # also grabbing the cookie from your browser would work
  curl = Curl::Easy.new('http://myapp.dev')
  curl.enable_cookies = true
  curl.cookiejar = 'cookie.txt'
  curl.http_get

  json_string = {setting: {do_something_ridiculous: true} }.to_json
  c = Curl::Easy.http_put("http://myapp.dev/setting.json", json_string
      ) do |curl|
        curl.enable_cookies          = true
        curl.cookiejar               = 'cookie.txt'
        curl.cookiefile              = 'cookie.txt'
        curl.headers['Accept']       = 'application/json'
        curl.headers['Content-Type'] = 'application/json'
        curl.headers['X-CSRF-TOKEN'] = 'CSRF_TOKENS_ARE_LONG'
      end
~~~

Hopefully this ends up saving someone a few minutes of time!
