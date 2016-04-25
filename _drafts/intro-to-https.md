---
layout: post
title: Intro to HTTPS 
---

What is encryption? The basic ideas behind HTTPS are these:
1. I want to be sure that the website (or server) that I'm sending information to (or requesting information from) is _exactly_ who it claims to be.
1. I want the information that goes between my web browser and the website I am interacting with to only be readable by the two of us. No eavesdropping here!

By using HTTPS you're getting the assurance that both of those things are true. HTTPS uses Transport Layer Security (or TLS), previously HTTPS used SSL, so you'll frequently hear the terms interchanged. It's worth noting that TLS supersedes SSL, and that SSL is __not__ considered secure anymore. TLS (and SSL) use Public-key cryptography to establish a secure connection between the server (typically a website) and the client (your web browser).

Public-key cryptography relies on a public and private pair of keys. The public key is (as noted in its name) public facing, and is readable by anyone. By encrypting data with a public key, you're ensuring that only the entity with the private key can _decrypt_ that data.

The reason that you can be sure that the website that you are sending information to (and receiving information from) is who it claims to be is because of Certificate Authorities (and root certificates). The Certificate Authority is a **trusted** 3rd party organization that validates whoever claims to own "example.com" actually owns "example.com". They essentially provide their stamp of approval, and sign your certificate with it (their root certificate is what's used to do this). Since they're a valid, trusted 3rd party. It means your browser can recognize that the CA (certificate authority) has approved the certificate.

A simplified version of how this works between web servers ad web browsers is similar to this:

1. My web browser makes a request to https://example.com
1. The web server responds with the public key, so my web browser can encrypt the request.
1. My web browser encrypts the request that it is making with the public key.
1. My web browser then sends the encrypted request to the web server. At this point the request is unreadable by anyone (even my web browser).
1. The example.com web server receives an encrypted payload from my browser.
1. Finally the example.com web server decrypts the information from my browser, and then responds accordingly.
