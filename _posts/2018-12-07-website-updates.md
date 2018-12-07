---
layout: post
title:  "website updates"
date:   2018-12-07 16:24:00 -0500
categories: internet
---

### Photos

There are some really neat themes for Jekyll for all sorts of things. I found one for a photo gallery and set it up at [colinholzman.xyz/photos](https://colinholzman.xyz/photos). Not a lot of photos up there at the moment, but that'll change.  

The theme I used is called [Lens](https://github.com/ElasticDesigns/jekyll-lens). It works similarly to default Jekyll. Put your photos in one place, run `jekyll build` and you'll have the static site ready to serve, in my case, with `app.use('/photos', express.static('/home/admin/photos'));`.

### Resume

[colinholzman.xyz/resume](https://colinholzman.xyz/resume) has a pdf of my resume. This is simply 
```
const resume = fs.readFileSync(path.join(__dirname, 'resume.pdf'));
app.get('/resume.pdf', (req, res) => {
    res.send(resume);
});
```
on the server.  

I should probably update my resume.

### Webcam

I used an old USB webcam, a rasberry pi 3 B, and [motionEyeOs](https://github.com/ccrisan/motioneyeos) to set up a stream of my backyard at [colinholzman.xyz/cam](http://colinholzman.xyz/cam). Download the latest image of motionEyeOs for your device from [here](https://github.com/ccrisan/motioneyeos/wiki/Supported-Devices). For a RPi burn the image on a sd card (I used etcher on my mac). Plug in the camera, insert the sd card, and connect the Pi to the network and power. Then go to the Pi's address in your browser to set up all the options. There are a lot of options to configure but the camera and stream worked out of the box.  

I forwarded the video streaming port through my router and that enabled me to access the stream from the internet. On the colinholzman.xyz server I added 
```
app.get('/cam', (req, res) => {
    res.sendFile(path.join(__dirname, 'cam.html'));
});
```
where cam.html just has an iframe pointing to my home router on the motionEyeOs streaming port. It seems to work OK. It doesn't work over https though. I wonder why?