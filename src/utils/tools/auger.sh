#!/usr/bin/env bash
# This script instals auger tool
# Refs: https://github.com/jpbetz/auger

set -xe

# install auger
git clone https://github.com/jpbetz/auger
cd auger
make release
cp build/auger /usr/local/bin/
cd ..