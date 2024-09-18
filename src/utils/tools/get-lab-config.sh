#!/usr/bin/env bash

# Check if both parameters are provided as arguments
if [ $# -eq 2 ]; then
    CLUSTER_NUMBER=$1
    TOKEN=$2
else
    # Prompt the user for input if not provided
    read -p "Enter cluster number: " CLUSTER_NUMBER
    read -p "Enter token: " TOKEN
fi

# Validate that the parameters are not empty
if [ -z "$CLUSTER_NUMBER" ] || [ -z "$TOKEN" ]; then
    echo "Error: Both cluster-number and token must be provided."
    echo "Usage: $0 [cluster-number] [token]"
    exit 1
fi

# Output the values to verify
echo "Cluster Number: $CLUSTER_NUMBER"
echo "Token: $TOKEN"

# Check if config folder exists
if [ ! -d "config" ]; then
    echo "Config folder doesn't exist. Creating it..."
    mkdir config
fi

cd config

# Download private key file
curl -H "Authorization: token ${TOKEN}" \
  -H "Accept: application/vnd.github.v4.raw" \
  -O \
  -L https://api.github.com/repos/hlesey/k8s-labs-config/contents/data/common/id_rsa_lab

# Download kubeconfig file
curl -H "Authorization: token ${TOKEN}" \
  -H "Accept: application/vnd.github.v4.raw" \
  -O \
  -L https://api.github.com/repos/hlesey/k8s-labs-config/contents/data/output/"user${CLUSTER_NUMBER}"/kubeconfig.yaml

# Download lab-docker info
curl -H "Authorization: token ${TOKEN}" \
  -H "Accept: application/vnd.github.v4.raw" \
  -O \
  -L https://api.github.com/repos/hlesey/k8s-labs-config/contents/data/output/"user${CLUSTER_NUMBER}"/lab-docker.yaml

# Download lab-k8s info
curl -H "Authorization: token ${TOKEN}" \
  -H "Accept: application/vnd.github.v4.raw" \
  -O \
  -L https://api.github.com/repos/hlesey/k8s-labs-config/contents/data/output/"user${CLUSTER_NUMBER}"/lab-k8s.yaml

# Download lab-k8s-empty info
curl -H "Authorization: token ${TOKEN}" \
  -H "Accept: application/vnd.github.v4.raw" \
  -O \
  -L https://api.github.com/repos/hlesey/k8s-labs-config/contents/data/output/"user${CLUSTER_NUMBER}"/lab-k8s-empty.yaml

cd ..
