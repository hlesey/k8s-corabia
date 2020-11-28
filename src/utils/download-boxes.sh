#!/usr/bin/env bash
# Dowload boxes for 

UBUNTU_BOX_IMAGE="ubuntu/bionic64"
UBUNTU_BOX_VERSION="20200429.0.0"

KUBERNETES_BOX_IMAGE="hlesey/k8s-base"
KUBERNETES_BOX_VERSION="1.18.2.1"

# ubuntu
vagrant box add $UBUNTU_BOX_IMAGE --box-version $UBUNTU_BOX_VERSION --provider virtualbox

# kubernetes
vagrant box add $KUBERNETES_BOX_IMAGE --box-version $KUBERNETES_BOX_VERSION --provider virtualbox
