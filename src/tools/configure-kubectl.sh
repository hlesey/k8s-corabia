#!/usr/bin/env bash

WINDOWS="MINGW64_NT"
MAC="Darwin"

extension=""
env_path="$HOME/.bash_profile"

if [[ $(uname | grep $WINDOWS) != "" ]]; then
    os="windows"
    extension=".exe"
elif [[ $(uname| grep $MAC) != "" ]]; then
	os="darwin"
	if [[ "${SHELL}" == *zsh ]]; then
	    env_path="$HOME/.zshrc"
    fi
else
	os="linux"
	env_path="$HOME/.bashrc"
fi

echo "Detected $os operating system."
echo "Detected $env_path as env path."

mkdir -p bin
curl -fsSL -o bin/kubetail https://raw.githubusercontent.com/johanhaleby/kubetail/master/kubetail

ENVS="$(dirname "$0")/../bootstrap/envs.sh"
version() { grep -m1 "^export $1=" "${ENVS}" | cut -d'"' -f2; }

case "$(uname -m)" in
    arm64|aarch64) arch=arm64 ;;
    *) arch=amd64 ;;
esac
[[ "${os}" == "windows" ]] && arch=amd64

# kubectl: same version as the cluster (K8S_VERSION + K8S_PATCH_VERSION in envs.sh)
K8S="v$(version K8S_VERSION).$(version K8S_PATCH_VERSION)"
curl -fsSL -o "bin/kubectl${extension}" "https://dl.k8s.io/release/${K8S}/bin/${os}/${arch}/kubectl${extension}"

# hey: amd64 builds only (runs through Rosetta on Apple Silicon); none for Linux arm64
if [[ "${os}" == "linux" && "${arch}" == "arm64" ]]; then
    echo "hey: no Linux arm64 build, skipped."
else
    curl -fsSL -o "bin/hey${extension}" "https://storage.googleapis.com/hey-releases/hey_${os}_amd64"
fi

chmod +x bin/*

cat <<EOF >> "${env_path}"
export PATH="$PATH:$(pwd)/bin"
export KUBECONFIG="$(pwd)/config/kubeconfig.yaml"
alias kns='kubectl config set-context \$(kubectl config current-context) --namespace'
alias k='"$(pwd)/bin/kubectl${extension}"'
EOF
