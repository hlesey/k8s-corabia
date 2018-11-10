#!/usr/bin/env bash

if [ $# -lt 1 ]; then
    echo "Usage: ${0} <namespace>"
    exit 1
fi

kubectl config set-context $(kubectl config current-context) --namespace="${1}"
