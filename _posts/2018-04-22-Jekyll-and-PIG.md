---
layout: post
title:  "Jekyll and pig.js"
date:  2019-04-22 08:00:00 -0500
categories: programming
tags: [website, blog, jekyll]
---

## Photo Gallery

I tried using [Jekyll Lens][Lens] for a photo gallery on [colinholzman.xyz][colinholzman.xyz]. It worked and was easy to use but was not exactly what I wanted. While looking for a better method I came across [this][Basurco] post by Sergio Basurco. In it he describes how he modified the [Jekyll Photo Gallery][JPG] plugin to use [pig.js] for loading images. Pig.js is a simple and lightweight JavaScript library to enable progressive loading of images as the user scrolls to them. The [example](https://feeding.schlosser.io/) is exactly the effect that I was looking for.

## Generating Assets

Pig.js expects to be able to load various sizes for each image. To do this the we must store the images in a manner that allows the pig.js function `urlForSize` to return the path to the image of a given size. I have chosen to store my images like so:

```
├── assets
│   ├── img
│   │   ├── 20
│   │   |   ├── blue.jpg
│   │   |   ...
│   │   ├── 100
│   │   |   ├── red.jpg
│   │   |   ...
│   │   ├── 250
│   │   |   ├── green.jpg
│   │   |   ...
│   │   ├── 500
│   │   │   ├── blue.jpg
...
```

Since my goal is to display potentially hundreds of images like this I need a tool to resize them all and generate the directory structure above.

## gallerybuilder

[gallerybuilder][gallerybuilder] is a simple python script I wrote to take a directory full of photos, resize them all to the sizes required by pig.js, and generate the html for my gallery page. It's a rough draft for now but it does the trick.

## Adding links

One last thing I did to enhance the gallery experience is make each image a link to a full size version. To get the link to the full size image I call `urlForSize` with size equal to 1024. Therefore when creating thumbnail images for the assets folder we have to create sizes 20, 100, 250, 500, (for original pig.js) and 1024 (for full size link). You can see the simple change to pig.js [here][clnhlzmn pig.js].

## Result

You can see what this looks like on my site [here][gallery]. TODO: add a lot more photos.

[Lens]: https://github.com/ElasticDesigns/jekyll-lens
[colinholzman.xyz]: https://colinholzman.xyz
[gallery]: https://colinholzman.xyz/gallery
[Basurco]: https://chuckleplant.github.io/2018/08/06/pig-img-gallery.html
[JPG]: https://github.com/aerobless/jekyll-photo-gallery
[pig.js]: https://github.com/schlosser/pig.js
[clnhlzmn pig.js]: https://github.com/schlosser/pig.js/compare/master...clnhlzmn:master#diff-ded216d1d585dc143459a4bdbbed4626R785
[gallerybuilder]: https://github.com/clnhlzmn/gallerybuilder/blob/master/main.py