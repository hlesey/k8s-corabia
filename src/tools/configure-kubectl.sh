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
GH=https://github.com

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

# unpack <archive> <file>: extract one file of a .tar.gz or .zip into bin/
unpack() {
    case "$1" in
        *.zip)
            if command -v unzip > /dev/null; then
                unzip -o -j -q "$1" "$2" -d bin
            else
                powershell -NoProfile -Command "Expand-Archive -Force '$1' bin_tmp; Move-Item -Force bin_tmp/$2 bin/; Remove-Item -Recurse bin_tmp"
            fi ;;
        *) tar -xzf "$1" -C bin "$2" ;;
    esac
    rm -f "$1"
}

v=$(version TRIVY_VERSION)
case "${os}/${arch}" in
    darwin/arm64) a="trivy_${v}_macOS-ARM64.tar.gz" ;;
    darwin/amd64) a="trivy_${v}_macOS-64bit.tar.gz" ;;
    linux/arm64)  a="trivy_${v}_Linux-ARM64.tar.gz" ;;
    linux/amd64)  a="trivy_${v}_Linux-64bit.tar.gz" ;;
    windows/*)    a="trivy_${v}_windows-64bit.zip" ;;
esac
curl -fsSL -o "bin/${a}" "${GH}/aquasecurity/trivy/releases/download/v${v}/${a}" && unpack "bin/${a}" "trivy${extension}"

v=$(version SYFT_VERSION)
if [[ "${os}" == "windows" ]]; then a="syft_${v}_windows_amd64.zip"; else a="syft_${v}_${os}_${arch}.tar.gz"; fi
curl -fsSL -o "bin/${a}" "${GH}/anchore/syft/releases/download/v${v}/${a}" && unpack "bin/${a}" "syft${extension}"

v=$(version COSIGN_VERSION)
curl -fsSL -o "bin/cosign${extension}" "${GH}/sigstore/cosign/releases/download/v${v}/cosign-${os}-${arch}${extension}"

v=$(version KUBE_LINTER_VERSION)
case "${os}/${arch}" in
    windows/*)   a="kube-linter.exe" ;;
    */arm64)     a="kube-linter-${os}_arm64" ;;
    *)           a="kube-linter-${os}" ;;
esac
curl -fsSL -o "bin/kube-linter${extension}" "${GH}/stackrox/kube-linter/releases/download/v${v}/${a}"

if [[ "${os}" == "windows" ]]; then
    echo "kubesec: no Windows release, skipped (use it on the control-plane node)."
else
    v=$(version KUBESEC_VERSION)
    a="kubesec_${os}_${arch}.tar.gz"
    curl -fsSL -o "bin/${a}" "${GH}/controlplaneio/kubesec/releases/download/v${v}/${a}" && unpack "bin/${a}" kubesec
fi

chmod +x bin/*

cat <<EOF >> "${env_path}"
export PATH="$PATH:$(pwd)/bin"
export KUBECONFIG="$(pwd)/config/kubeconfig.yaml"
alias kns='kubectl config set-context \$(kubectl config current-context) --namespace'
alias k='"$(pwd)/bin/kubectl${extension}"'
EOF
