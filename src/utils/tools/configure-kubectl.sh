#!/usr/bin/env bash

WINDOWS="MINGW64_NT"
MAC="Darwin"

if [[ $(uname | grep $WINDOWS) != "" ]]; then
	os="windows"
elif [[ $(uname| grep $MAC) != "" ]]; then
	os="mac"
else
	os="linux"
fi

echo "Detected $os operating system."

mkdir -p bin
curl -o bin/kubectl -LO https://dl.k8s.io/release/"$(curl -sL https://dl.k8s.io/release/stable.txt)"/bin/$os/amd64/kubectl.exe

cat <<EOF > ~/.bash_profile
export PATH="$PATH:$(pwd)/bin"
export KUBECONFIG="$(pwd)/kubeadm-vagrant/src/output/kubeconfig.yaml:$(pwd)/config/kubeconfig.yaml"
alias kns='kubectl config set-context \$(kubectl config current-context) --namespace'
EOF

. ~/.bash_profile
kubectl version
