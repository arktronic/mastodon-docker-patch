# mastodon-docker-patch: scripts to patch Mastodon Docker images

### This is *highly* experimental. It might eat all of your data. Proceed with extreme caution.

## Change your Mastodon character limit (max toot length)

### Instructions

Assuming you have Docker installed, you can simply clone this repo and run the script:
```bash
git clone https://github.com/arktronic/mastodon-docker-patch.git
cd mastodon-docker-patch

# For v4.0.2
./change-max-toot-length-v4.0.2.sh 10000

# For another version (no guarantees of compatibility, but appears to work with v3.5.3 and up)
PATCH_BASE_IMAGE=tootsuite/mastodon:v4.0.0rc3 ./change-max-toot-length-v4.0.2.sh 10000
```

This will create a new local image with the tag `tootsuite/mastodon:v4.0.2-local-maxchars-10000`. You can then use this image instead of the default one. Specify another number if you would like a different limit.

## Change your Mastodon version suffix

Similar to how the [Glitch fork](https://github.com/glitch-soc/mastodon/) uses a `+glitch` suffix, it might be useful to show that you have modified your instance.

### Instructions

Very similar to the above.
```bash
git clone https://github.com/arktronic/mastodon-docker-patch.git
cd mastodon-docker-patch

# For v4.0.2
./make-version-suffix-env-based-v4.0.2.sh

# For another version (no guarantees of compatibility!)
PATCH_BASE_IMAGE=tootsuite/mastodon:v4.0.2-local-maxchars-10000 ./make-version-suffix-env-based-v4.0.2.sh
```

This will create a new local image with the tag `tootsuite/mastodon:v4.0.2-local-suffixmod`. You can then use this image instead of the default one.

To change your version suffix, modify the environment (usually a `.env.production` file) and add the following line, replacing `+changes` with your choice of text:
```
MASTODON_VERSION_SUFFIX="+changes"
```
