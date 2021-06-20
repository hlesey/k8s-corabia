#!/usr/bin/env bash

if [[ "${USER_LAB}" == "" || "${TOKEN_LAB}" == "" ]]; then
    echo "USER_LAB and/or TOKEN_LAB environment variables not set."
    exit 1
fi

# download private key file
curl -H "Authorization: token ${TOKEN_LAB}" \
  -H "Accept: application/vnd.github.v4.raw" \
  -o id_rsa \
  -L https://api.github.com/repos/hlesey/k8s-labs-config/contents/data/common/id_rsa_lab

# TODO: copy id_rsa_lab to ~/.ssh/id_rsa
# Check if the folder exist and create it + check if the key exists and do a backup

# download kubeconfig file
curl -H "Authorization: token ${TOKEN_LAB}" \
  -H "Accept: application/vnd.github.v4.raw" \
  -O \
  -L https://api.github.com/repos/hlesey/k8s-labs-config/contents/data/output/"${USER_LAB}"/kubeconfig.yaml


# download lab-docker info
curl -H "Authorization: token ${TOKEN_LAB}" \
  -H "Accept: application/vnd.github.v4.raw" \
  -O \
  -L https://api.github.com/repos/hlesey/k8s-labs-config/contents/data/output/"${USER_LAB}"/lab-docker.yaml

# download lab-k8s info
curl -H "Authorization: token ${TOKEN_LAB}" \
  -H "Accept: application/vnd.github.v4.raw" \
  -O \
  -L https://api.github.com/repos/hlesey/k8s-labs-config/contents/data/output/"${USER_LAB}"/lab-k8s.yaml

# download lab-k8s-empty info
curl -H "Authorization: token ${TOKEN_LAB}" \
  -H "Accept: application/vnd.github.v4.raw" \
  -O \
  -L https://api.github.com/repos/hlesey/k8s-labs-config/contents/data/output/"${USER_LAB}"/lab-k8s-empty.yaml
