#!/usr/bin/env bash

WINDOWS="MINGW64_NT"
MAC="Darwin"

extension=""
env_path="$HOME/.bash_profile"

if [[ $(uname | grep $WINDOWS) != "" ]]; then
    os="windows"
    extension=".exe"
elif [[ $(uname| grep $MAC) != "" ]]; then
	os="mac"
else
	os="linux"
	# If bash is not opened with interactive login, .bash_profile won't be loaded
	# See https://askubuntu.com/a/121075 for a good explanation
	env_path="$HOME/.bashrc"
fi

echo "Detected $os operating system."

mkdir -p bin
curl -o bin/kubectl -LO "https://dl.k8s.io/release/$(curl -sL https://dl.k8s.io/release/stable.txt)/bin/$os/amd64/kubectl${extension}"
curl -o bin/kubetail -LO https://raw.githubusercontent.com/johanhaleby/kubetail/master/kubetail
chmod +x bin/kube*

cat <<EOF >> "${env_path}"
export PATH="$PATH:$(pwd)/bin"
export KUBECONFIG="$(pwd)/k8s-corabia/src/output/kubeconfig.yaml:$(pwd)/config/kubeconfig.yaml"
alias kns='kubectl config set-context \$(kubectl config current-context) --namespace'
EOF
