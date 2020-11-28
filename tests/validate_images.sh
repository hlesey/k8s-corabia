#!/usr/bin/env bash

# no dockerhub images
images=$(grep -RniI 'image:' . --exclude-dir='dockerhub-mirror' --exclude-dir='tests' | cut -d ':' -f4,5 | sort -u  | sed 's/"//g' | sort -u | grep -v -f src/template/dockerhub-mirror/excluded.txt)

if [ "$images" != "" ]; then
    echo "The following dockerhub images are not synced to ghcr.io:"
    echo "---------------"
    for image in $images; do 
        echo $image
    done
    echo "---------------"
    exit 1;
fi

echo "No dockerhub image found"
exit 0;
