---
layout: post
title:  "colinholzman.xyz"
date:   2018-11-27 07:00:00 -0500
categories: meta
---

I've wanted to learn what it takes to run a website. Finally I've put together [colinholzman.xyz](https://colinholzman.xyz). This is based on knowledge found all over the internet and through trial and error. It's fitting to write down some instructions on how to reproduce it as the first post.

### get a host to serve your site

I used Amazon Lightsail for this. This site is currently running on the cheapest instance I could get (512 MB RAM, 1 vCPU, 20 GB SSD). It's running Debian 8.

### domain name

Buy a domain name from someone like <porkbun.com>. Once you have an account you can create a record that will return the static ip that you assign to your server when someone asks for the address of colinholzman.xyz or whatever.

### install node.js

Do this in whatever way is typical for your os. I think Amazon has images with node already installed.

### install express, forever, and probably some other things

`npm install express`
`npm install forever`
`...`

### create a file server.js 
  
Here is a simple static http server (a pretty trivial use of express I'm sure):

    // Dependencies
    const fs = require('fs');
    const http = require('http');
    const express = require('express');
    
    const app = express();
    
    app.use(express.static('/home/admin/site'))
    
    // Starting http server
    const httpServer = http.createServer(app);
    
    httpServer.listen(80, () => {
        //console.log('HTTP Server running on port 80');
    });

Run it like `sudo forever start server.js`. We want to use https though!

### Let's Encrypt

In order to get the nice secure looking green lock when you visit your site you'll have to obtain some on-the-level ssl certificates. To do this we go to [certbot.eff.org](https://certbot.eff.org/) and download the certbot-auto tool. There are pretty solid instructions there. It comes down to running something like `sudo ./path/to/certbot-auto certonly --webroot -d colinholzman.xyz`. With the certificate generated make `server.js` look like this:

    // Dependencies
    const fs = require('fs');
    const https = require('https');
    const express = require('express');
    
    const app = express();
    
    // Certificate
    const privateKey = fs.readFileSync('/etc/letsencrypt/live/colinholzman.xyz/privkey.pem', 'utf8');
    const certificate = fs.readFileSync('/etc/letsencrypt/live/colinholzman.xyz/cert.pem', 'utf8');
    const ca = fs.readFileSync('/etc/letsencrypt/live/colinholzman.xyz/chain.pem', 'utf8');
    
    const credentials = {
        key: privateKey,
        cert: certificate,
        ca: ca
    };
    
    app.use(express.static('/home/admin/site'))
    
    // Starting https server
    const httpsServer = https.createServer(credentials, app);
    
    httpsServer.listen(443, () => {
        //console.log('HTTPS Server running on port 443');
    });

### Jekyll

[Jekyll](https://jekyllrb.com/) is a static website generator. It takes a bunch of markdown content and puts it into place using templates and creates the html and other stuff that gets served from `/home/admin/site`.