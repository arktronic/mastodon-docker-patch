#!/bin/bash

set -e
cd -- "$( dirname -- "${BASH_SOURCE[0]}" )"

[ "$#" -eq 1 ] || {
  echo "Usage: ${BASH_SOURCE[0]} new-character-limit"
  echo
  echo "Advanced usage: PATCH_BASE_IMAGE=my-image:version ${BASH_SOURCE[0]} new-character-limit"
  echo "(This will use a custom base Docker image instead of the default - be careful!)"
  exit 1
}

[[ $1 =~ ^[0-9]+$ ]] || {
  echo "The new character limit must be an integer."
  exit 1
}

PATCH_BASE_IMAGE=${PATCH_BASE_IMAGE:-tootsuite/mastodon:v4.0.2}

CHAR_LIMIT=$1

DOCKERFILE=$(cat <<EOF
FROM $PATCH_BASE_IMAGE
COPY ./compose_form.js /opt/mastodon/app/javascript/mastodon/features/compose/components/
COPY ./status_length_validator.rb /opt/mastodon/app/validators/
COPY ./instance_serializer.rb /opt/mastodon/app/serializers/rest/
RUN cd /opt/mastodon \
 && OTP_SECRET=precompile_placeholder SECRET_KEY_BASE=precompile_placeholder rails assets:precompile \
 && yarn cache clean
EOF
)

NEW_CONTAINER_NAME=mastodon-change-max-toot-length-tmp

echo "*** Creating new image with character limit set to $CHAR_LIMIT..."

sudo rm -rf tmpdata/* &>/dev/null || true
mkdir -p tmpdata
chmod 777 tmpdata

echo Copying files from Mastodon image...
docker run --rm -v $(pwd)/tmpdata:/data $PATCH_BASE_IMAGE bash -c 'cp app/javascript/mastodon/features/compose/components/compose_form.js /data && cp app/validators/status_length_validator.rb /data && cp app/serializers/rest/instance_serializer.rb /data && chmod 777 /data/*'

echo Patching files...
sed -i "s/length(fulltext) > [0-9]*/length(fulltext) > $CHAR_LIMIT/g" tmpdata/compose_form.js
sed -i "s/CharacterCounter max={[0-9]*}/CharacterCounter max={$CHAR_LIMIT}/g" tmpdata/compose_form.js

sed -i "s/MAX_CHARS = [0-9]*/MAX_CHARS = $CHAR_LIMIT/g" tmpdata/status_length_validator.rb

# Doing this idempotently isn't exactly straightforward...
grep -q :max_toot_chars tmpdata/instance_serializer.rb || sed -i "s/:registrations/:registrations, :max_toot_chars/g" tmpdata/instance_serializer.rb
sed -i "/def max_toot_chars()/d" tmpdata/instance_serializer.rb
sed -i "/^\s*private\s*/i \ \ def max_toot_chars() = $CHAR_LIMIT" tmpdata/instance_serializer.rb

PATCHED_IMAGE_TAG=${PATCH_BASE_IMAGE}-local-maxchars-$CHAR_LIMIT
echo "Creating new patched image named \"$PATCHED_IMAGE_TAG\"..."
echo "$DOCKERFILE" > tmpdata/Dockerfile
pushd tmpdata &>/dev/null
docker build . -t $PATCHED_IMAGE_TAG
popd &>/dev/null
