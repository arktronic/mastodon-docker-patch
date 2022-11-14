# mastodon-docker-patch: script(s) to patch Mastodon Docker images

### This is *highly* experimental. It might eat all of your data. Proceed with extreme caution.

## Change your Mastodon character limit (max toot length)

### Instructions

Assuming you have Docker installed, you can simply clone this repo and run the script:
```bash
git clone https://github.com/arktronic/mastodon-docker-patch.git
cd mastodon-docker-patch

# For v3.5.3
./change-max-toot-length-v3.5.3.sh 10000

# For v4.0.1
./change-max-toot-length-v4.0.1.sh 10000

# For another version (no guarantees of compatibility!)
PATCH_BASE_IMAGE=tootsuite/mastodon:v4.0.0rc3 ./change-max-toot-length-v3.5.3.sh 10000
```

This will create a new local image with the tag `tootsuite/mastodon:v3.5.3-local-maxchars-10000`. You can then use this image instead of the default one. Specify another number if you would like a different limit.
