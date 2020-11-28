#!/usr/bin/env bash
set -e

# if [ !GIT_TOKEN ]; then
#     echo "Env var GIT_TOKEN not set"
# fi

# Place to find k8s manifests
LOOKUP_MANIFEST_PATH="../../../../"

# exlude everything, but dockerhub images

found_images=$(grep -RniI 'image:' "$LOOKUP_MANIFEST_PATH" --exclude-dir='dockerhub-mirror' | cut -d ':' -f4,5 | sort -u  | sed 's/"//g' | sort -u | grep -v -f excluded.txt)

for image in $found_images; do
    new_image="ghcr.io/hlesey/$(echo $image | sed 's/hlesey\///g')"
    docker pull $image
    docker tag $image $new_image
    docker push $new_image
    echo $image $new_image >> out.txt
done