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
	if [[ "${SHELL}" == */zsh ]]; then
	    env_path="$HOME/.zshrc"
    fi
else
	os="linux"
	# If bash is not opened with interactive login, .bash_profile won't be loaded
	# See https://askubuntu.com/a/121075 for a good explanation
	env_path="$HOME/.bashrc"
fi

echo "Detected $os operating system."
echo "Detected $env_path as env path."

mkdir -p bin
curl -o bin/kubectl -LO "https://dl.k8s.io/release/$(curl -sL https://dl.k8s.io/release/stable.txt)/bin/${os}/amd64/kubectl${extension}"
curl -o bin/kubetail -LO https://raw.githubusercontent.com/johanhaleby/kubetail/master/kubetail
curl -o bin/hey -LO "https://hey-release.s3.us-east-2.amazonaws.com/hey_${os}_amd64"
chmod +x bin/*

cat <<EOF >> "${env_path}"
export PATH="$PATH:$(pwd)/bin"
export KUBECONFIG="$(pwd)/k8s-corabia/output/kubeconfig.yaml:$(pwd)/config/kubeconfig.yaml"
alias kns='kubectl config set-context \$(kubectl config current-context) --namespace'
EOF
