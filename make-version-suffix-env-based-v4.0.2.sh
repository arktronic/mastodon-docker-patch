#!/bin/bash

set -e
cd -- "$( dirname -- "${BASH_SOURCE[0]}" )"

[ "$#" -eq 0 ] || {
  echo "Usage: ${BASH_SOURCE[0]}"
  echo
  echo "Advanced usage: PATCH_BASE_IMAGE=my-image:version ${BASH_SOURCE[0]}"
  echo "(This will use a custom base Docker image instead of the default - be careful!)"
  exit 1
}

PATCH_BASE_IMAGE=${PATCH_BASE_IMAGE:-tootsuite/mastodon:v4.0.2}

DOCKERFILE=$(cat <<EOF
FROM $PATCH_BASE_IMAGE
COPY ./version.rb /opt/mastodon/lib/mastodon/
EOF
)

echo "*** Creating new image with version suffix modifiable by environment variable..."

sudo rm -rf tmpdata/* &>/dev/null || true
mkdir -p tmpdata
chmod 777 tmpdata

echo Copying files from Mastodon image...
docker run --rm -v $(pwd)/tmpdata:/data $PATCH_BASE_IMAGE bash -c 'cp lib/mastodon/version.rb /data && chmod 777 /data/*'

echo Patching files...
sed -z -i "s/def suffix\n[[:space:]]\+''\n[[:space:]]\+end/def suffix() = ENV.fetch('MASTODON_VERSION_SUFFIX', '')/" tmpdata/version.rb

PATCHED_IMAGE_TAG=${PATCH_BASE_IMAGE}-local-suffixmod
echo "Creating new patched image named \"$PATCHED_IMAGE_TAG\"..."
echo "$DOCKERFILE" > tmpdata/Dockerfile
pushd tmpdata &>/dev/null
docker build . -t $PATCHED_IMAGE_TAG
popd &>/dev/null
