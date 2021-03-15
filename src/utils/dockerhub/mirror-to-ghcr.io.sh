#!/usr/bin/env bash
set -e

while read -r line; do
    old_image=$(echo "$line" | cut -d ' ' -f1)
    new_image=$(echo "$line" | cut -d ' ' -f2)  # or "ghcr.io/hlesey/$(echo $old_image | sed 's/hlesey\///g')"
    docker pull "$old_image"
    docker tag "$old_image" "$new_image"
    docker push "$new_image"
    echo "$old_image mirrored in ghcr as $new_image"
done < mappings.txt
