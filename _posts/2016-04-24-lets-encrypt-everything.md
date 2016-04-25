---
layout: post
title: Lets Encrypt, everything.
---

[Everything should be encrypted](http://www.wired.com/2014/04/https/), as software engineers we all know this. Anything transmitted over the wires of the internet should be encrypted. We use SSH for our server communications, and TLS/SSL (HTTPS) any other time we're sending data around. Even if you're not a technically minded person, you use HTTPS every single day. You're even reading this article over HTTPS. We've trained ourselves to look for the "green lock" any time you're submitting information over the internet. I think a better trend is to "look for the green lock" all of the time. I'd even suggest using an add-on like [HTTPS Everywhere](https://chrome.google.com/webstore/detail/https-everywhere/gcbommkclmclpchllfjekcdonpmejbdp?hl=en) to ensure that as much as possible is encrypted.

Historically one of the barriers to setting up a website to use HTTPS for everything, is cost. Since the beginning of the internet, hosting providers realized that they could sell SSL Certificates for a higher price, and integrate them with their hosting services. Usually that meant going through whichever SSL Certificate provider (certificate authority) your hosting company had partnered up with and paying them whatever they felt like charging.

But today, we have [LetsEncrypt](https://letsencrypt.org/about/). From their about page:

>Let’s Encrypt is a free, automated, and open certificate authority (CA), run for the public’s benefit. Let’s Encrypt is a service provided by the Internet Security Research Group (ISRG).

In this article we're going to use LetsEncrypt to obtain a free SSL Certificate to use with our Nginx web server. We're also going to configure Nginx to serve our site over HTTPS using that certificate, and we're going to configure Nginx to redirect anyone requesting the HTTP version of the site over to HTTPS. In addition to the initial configuration, we're also going to configure a cron job to run occasionally and renew our certificate automatically. This is required because LetsEncrypt certificates are only valid for 90 days.

This article assumes that you have a website that you want to serve up via Nginx, and that you have access to a server running Nginx. I personally suggest [DigitalOcean](https://m.do.co/c/b508d27b35f8) for your hosting needs, as you can quickly spin up a server and you have full control over it. There are other Hosting providers that work with LetsEncrypt, as documented [here](https://github.com/letsencrypt/letsencrypt/wiki/Web-Hosting-Supporting-LE) but I've had the best luck running my own servers. Also, any type of server would work for this. An AWS EC2 instance, a bare metal server some where. Whatever it is, provided it's publicly accessible by the internet, and is running Nginx - this article applies.

## Using LetsEncrypt  

LetsEncrypt has an excellent wrapper utility that allows us to use this on basically any operating system.

We'll start by SSHing into our web server, and running the following commands to get the LetsEncrypt application. We're also going to install LetsEncrypt to the `/usr/local` folder so it's not specific to any one user on the system. We'll eventually automate the renewal process as root, so `/usr/local` is a good location for the executables.

**NOTE**: LetsEncrypt requires `sudo` permissions, so make sure you're logged in as a sudoer.

~~~
user@webserver:~$ cd /usr/local
user@webserver:~$ sudo git clone https://github.com/letsencrypt/letsencrypt
user@webserver:~$ cd letsencrypt
user@webserver:/usr/local/letsencrypt$ ./letsencrypt-auto --help
~~~

This should install some dependencies, and then get the Python virtual environment prepped and ready to use. You'll see quite a bit of scroll back indicating some of these things.

To request the certificate we'll need to run this next command, using the "webroot" plugin. The webroot plugin allows us to not have to mess with our nginx configuration, stop the server, or anything else. LetsEncrypt simply uses the existing web server to handle the domain validation.

~~~
./letsencrypt-auto certonly -a webroot --webroot-path=/usr/share/nginx/html -d example.com
~~~

You'll need to change the value of `webroot-path` to the path where Nginx is serving your site from. You'll also need to change `example.com` to whatever domains you want to secure. If you want to secure both `www.example.com` and `example.com` on the same certificate you'll need to specify an additional domain by appending another `-d www.example.com` to the command above.

You'll get a congratulations message similar to this:

~~~
IMPORTANT NOTES:
 - Congratulations! Your certificate and chain have been saved at
   /etc/letsencrypt/live/adamrunner.com/fullchain.pem. Your cert will
   expire on 2016-07-23. To obtain a new version of the certificate in
   the future, simply run Let's Encrypt again.
~~~

### Generating strong Diffie-Hellman Params
The default key size for the Diffie-Hellman params is 1024, this will end up capping our SSL Labs grade to a B. It also could expose our server to [the Logjam attack.](https://weakdh.org/) So we're going to go ahead and generate a strong DH Group.

`sudo openssl dhparam -out /etc/ssl/certs/dhparam.pem 2048`

This will take a (long) while to generate, but we will be left with a strong DH param in `/etc/ssl/certs/dhparam.pem.`

## Configuring Nginx

Next, we'll need to configure Nginx to use these newly generated certificates. You'll do this by editing your Nginx configuration file for your site. Simply add the private key, and certificate directives to your config file. You'll want to change out your `listen` directives also, so they listen on the SSL ports.

~~~
server {
        listen 443 ssl;
        listen [::]:443 ssl; #NOTE: Comment this line out if you're not using IPv6
        ssl_certificate     /etc/letsencrypt/live/adamrunner.com/fullchain.pem;
        ssl_certificate_key /etc/letsencrypt/live/adamrunner.com/privkey.pem;
        ssl_protocols       TLSv1 TLSv1.1 TLSv1.2;
        ...
}
~~~

After that, we'll go ahead and add another server to redirect all traffic to the HTTPS version of the site. It's simple, only 4 lines. It just listens on the normal HTTP port (80), and then returns a 301 redirect to indicate that there is a permanent redirection to the HTTPS version of the site.

My simple server looks like this:

~~~
#NOTE: Redirect to HTTPS
server {
        listen 80;
        listen [::]:80; #NOTE: Comment this line out if you're not using IPv6
        server_name adamrunner.com;
        return 301 https://adamrunner.com$request_uri;
}
~~~

Then we'll need to configure Nginx's SSL behaviors. We'll create a new file at `/etc/nginx/conf.d/ssl.conf`

~~~
sudo vim /etc/nginx/conf.d/ssl.conf
~~~

You'll want to populate that file with these contents. These directives ensure that Nginx uses only the ciphers specified here, and only the TLSv1, TLSv1.1 and TLSv1.2 protocols. Also, we'll tell it to use our generated DH Param file. Also, we'll explicitly set the SSL session timeout, SSL session cache and add the Strict-Transport-Security header. [HTTP Strict Transport Security](https://en.wikipedia.org/wiki/HTTP_Strict_Transport_Security) (HSTS) is a web security policy mechanism which helps to protect websites against protocol downgrade attacks and cookie hijacking.

~~~
ssl_ciphers 'ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES256-GCM-SHA384:DHE-RSA-AES128-GCM-SHA256:DHE-DSS-AES128-GCM-SHA256:kEDH+AESGCM:ECDHE-RSA-AES128-SHA256:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA:ECDHE-ECDSA-AES128-SHA:ECDHE-RSA-AES256-SHA384:ECDHE-ECDSA-AES256-SHA384:ECDHE-RSA-AES256-SHA:ECDHE-ECDSA-AES256-SHA:DHE-RSA-AES128-SHA256:DHE-RSA-AES128-SHA:DHE-DSS-AES128-SHA256:DHE-RSA-AES256-SHA256:DHE-DSS-AES256-SHA:DHE-RSA-AES256-SHA:AES128-GCM-SHA256:AES256-GCM-SHA384:AES128-SHA256:AES256-SHA256:AES128-SHA:AES256-SHA:AES:CAMELLIA:DES-CBC3-SHA:!aNULL:!eNULL:!EXPORT:!DES:!RC4:!MD5:!PSK:!aECDH:!EDH-DSS-DES-CBC3-SHA:!EDH-RSA-DES-CBC3-SHA:!KRB5-DES-CBC3-SHA';

ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
ssl_prefer_server_ciphers on;
ssl_dhparam /etc/ssl/certs/dhparam.pem;
ssl_session_timeout 1d;
ssl_session_cache shared:SSL:50m;
add_header Strict-Transport-Security max-age=15768000;
~~~

Finally, we'll restart Nginx to ensure that our site is using the new configuration.

~~~
sudo service nginx restart
~~~

At this point, your site should be up and running using your freshly obtained LetsEncrypt certificate. Go ahead and check it out! You should also check the SSL Labs report for your domain. The LetsEncrypt certificates are usually given an A+ rating with this configuration.

~~~
# Open the following URL in a web browser (replacing my domain with yours)
https://www.ssllabs.com/ssltest/analyze.html?d=adamrunner.com
~~~

## Auto renewing certificates via cron

LetsEncrypt certificates are good for 90 days, however it makes sense to renew them at least every 60 days. This ensures that your certificates never expire. Logging into the server manually and renewing the certificate sounds very error-prone. Luckily, computers are excellent at repeating tasks on a schedule. We'll go ahead and automate this task as a cron job.

Run `sudo crontab -e` to edit the root crontab (we're using the root crontab because LetsEncrypt needs sudo permissions). Edit your crontab to look like this:

~~~cron
# New Crontab Contents
8 8 1 * * /usr/local/letsencrypt/letsencrypt-auto renew  >> /var/log/letsencrypt.log
45 8 1 * * service nginx restart
~~~

This will tell cron to run the renewal script at 8:08 on the 1st of every month, and append whatever output comes from the script to `/var/log/letsencrypt.log`. Also at 8:45 we'll go ahead and restart the Nginx web server, this will ensure that the new certificates get loaded by Nginx.

## Conclusion

After running through these steps, you should have a secured website that uses the LetsEncrypt CA to generate and renew SSL certificates. It will also automatically renew your certificates, ensuring that they're always up to date!
