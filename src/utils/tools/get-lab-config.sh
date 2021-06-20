#!/usr/bin/env bash

if [[ "$USER" == "" || "$TOKEN" == "" ]]; then
    echo "USER and TOKEN environment variables not set."
    exit 1
fi

# download private key file
curl -H "Authorization: token $TOKEN" \
  -H "Accept: application/vnd.github.v4.raw" \
  -o id_rsa \
  -L https://api.github.com/repos/hlesey/k8s-labs-config/contents/data/common/id_rsa_lab

# TODO: copy id_rsa_lab to ~/.ssh/id_rsa
# Check if the folder exist and create it + check if the key exists and do a backup

# download kubeconfig file
curl -H "Authorization: token $TOKEN" \
  -H "Accept: application/vnd.github.v4.raw" \
  -O \
  -L https://api.github.com/repos/hlesey/k8s-labs-config/contents/data/output/$USER/kubeconfig.yaml


# download lab-docker info
curl -H "Authorization: token $TOKEN" \
  -H "Accept: application/vnd.github.v4.raw" \
  -O \
  -L https://api.github.com/repos/hlesey/k8s-labs-config/contents/data/output/$USER/lab-docker.yaml

# download lab-k8s info
curl -H "Authorization: token $TOKEN" \
  -H "Accept: application/vnd.github.v4.raw" \
  -O \
  -L https://api.github.com/repos/hlesey/k8s-labs-config/contents/data/output/$USER/lab-k8s.yaml

# download lab-k8s-empty info
curl -H "Authorization: token $TOKEN" \
  -H "Accept: application/vnd.github.v4.raw" \
  -O \
  -L https://api.github.com/repos/hlesey/k8s-labs-config/contents/data/output/$USER/lab-k8s-empty.yaml
