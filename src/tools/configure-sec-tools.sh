#!/usr/bin/env bash

extension=""
case "$(uname)" in
    MINGW64_NT*) os="windows"; extension=".exe" ;;
    Darwin)      os="darwin" ;;
    *)           os="linux" ;;
esac

case "$(uname -m)" in
    arm64|aarch64) arch=arm64 ;;
    *) arch=amd64 ;;
esac
[[ "${os}" == "windows" ]] && arch=amd64

echo "Detected ${os}/${arch}."

ENVS="$(dirname "$0")/../bootstrap/envs.sh"
version() { grep -m1 "^export $1=" "${ENVS}" | cut -d'"' -f2; }
GH=https://github.com

mkdir -p bin

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
echo "Installed in $(pwd)/bin: trivy, syft, cosign, kube-linter$([[ ${os} != windows ]] && echo ", kubesec")."
