### What's this:

This is meant to work on images "in memory".

This does not use FWT or SWT at all and thus can be more efficient and better to use on the server side.

It's currently quite limited and **very** much alpha and I'm not sure it will even get past this stage.

But here is what it does so far:

- Create "in memory" images
- Allow drawing on the image, currently only points, lines and rectangles(filled or not) and polygons
- It does support stroke size and colors including alpha (It does alpha blending)
- Some early support for antialiasing, so far only for straight lines
- Exporting/saving the image into Bmp format

Doesn't support yet :

- Saving the images in anything but BMP format.
- not even any circles / ovals yet
- drawing fonts

### FAQ:

- What is the use case for this nonsense ?

I use it to generate captcha images on the fly, see [https://bitbucket.org/status302/captcha302/](https://bitbucket.org/status302/captcha302/)



