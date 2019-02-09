#!/usr/bin/env bash
# Verify your quota limit in dockerhub for your user

if [ "$DOCKER_USER" == "" ]; then 
    read -p "Enter your dockerhub username:" DOCKER_USER
fi 

if [ "$DOCKER_PW" == "" ]; then 
    read -p "Enter your dockerhub password:" DOCKER_PW
fi 



TOKEN=$(curl --user "$DOCKER_USER:$DOCKER_PW" "https://auth.docker.io/token?service=registry.docker.io&scope=repository:ratelimitpreview/test:pull" | jq -r .token)
curl --head -H "Authorization: Bearer $TOKEN" https://registry-1.docker.io/v2/ratelimitpreview/test/manifests/latest
