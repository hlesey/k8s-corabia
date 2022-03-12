#!/usr/bin/env bash

# set -x
# set -o errexit
set -o nounset
set -o pipefail

allowed_registries="ghcr.io\|k8s.gcr.io\|quay.io"

# no dockerhub images
images=$(grep -RniI 'image:' . --exclude-dir='dockerhub' --exclude-dir='tests' | cut -d ':' -f4,5 | sort -u  | sed 's/"//g' | sort -u | grep -v $allowed_registries)

if [ "$images" != "" ]; then
    echo "The following dockerhub images found in docker hub and they might need to by synced to ghcr.io:"
    echo "---------------"
    for image in $images; do 
        echo $image
    done
    echo "---------------"
    exit 1;
fi

echo "No dockerhub image found;"
echo "Looks good;"
exit 0;
