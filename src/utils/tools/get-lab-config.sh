#!/usr/bin/env bash

USER="$1"
TOKEN="$2"

if [[ "$USER" == "" || "$TOKEN" == "" ]]; then
    echo "usage: $0 STUD_X GIT_TOKEN"
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


# download lab info
curl -H "Authorization: token $TOKEN" \
  -H "Accept: application/vnd.github.v4.raw" \
  -O \
  -L https://api.github.com/repos/hlesey/k8s-labs-config/contents/data/output/$USER/lab.yaml
