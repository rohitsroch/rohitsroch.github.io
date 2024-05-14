# Using

Install `ImageMagick` by running the command `apt-get install imagemagick` or `brew install imagemagick` 

Run `sudo chmod 777 resize.sh` (Only need once for the first time)

Now, whenever you create a new post:

1. Put the featured image (must be .jpg file) in the same folder with `resize.sh`
2. Run `bash ./resize.sh`
3. Done

It will create a new folder called `resized` contains all resized-named images (i.e, `*_lg.jpg`, `*_md.jpg`, `*_placehold.jpg`,...) for your post.

The remaining thing to do is to copy the resized-named images to `assets/img/posts/`