# Verify your quota limit in dockerhub for your user

```bash
DOCKER_USER="" # your dockerhub username
DOCKER_PW="" # your dockerhub password

TOKEN=$(curl --user "$DOCKER_USER:$DOCKER_PW" "https://auth.docker.io/token?service=registry.docker.io&scope=repository:ratelimitpreview/test:pull" | jq -r .token)
curl --head -H "Authorization: Bearer $TOKEN" https://registry-1.docker.io/v2/ratelimitpreview/test/manifests/latest
```
