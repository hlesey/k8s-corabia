#!/usr/bin/env bash

# Install the security tools used for CKS
# trivy, kube-bench, syft, cosign, kube-linter and sysdig.

set -u
source "${ENVS_FILE:-/src/bootstrap/envs.sh}"

: "${TRIVY_VERSION:?missing in envs.sh}"
: "${KUBE_BENCH_VERSION:?missing in envs.sh}"
: "${SYFT_VERSION:?missing in envs.sh}"
: "${COSIGN_VERSION:?missing in envs.sh}"
: "${KUBE_LINTER_VERSION:?missing in envs.sh}"
: "${SYSDIG_VERSION:?missing in envs.sh}"

export DEBIAN_FRONTEND=noninteractive
export NEEDRESTART_MODE=l  # never let needrestart restart kubelet or crio
MARKERS=/usr/local/share/security-tools
WORK=$(mktemp -d)
trap 'rm -rf "${WORK}"' EXIT
mkdir -p "${MARKERS}"

case "$(dpkg --print-architecture)" in
    arm64) ARCH=arm64; UNAME_M=aarch64; TRIVY_ARCH=ARM64; KUBE_LINTER_SUFFIX=_arm64 ;;
    amd64) ARCH=amd64; UNAME_M=x86_64; TRIVY_ARCH=64bit; KUBE_LINTER_SUFFIX= ;;
    *) echo "security-tools: unsupported architecture $(dpkg --print-architecture)" >&2; exit 1 ;;
esac

# fetch <owner/repo> <tag> <asset>: download to ${WORK}/<asset> and verify its SHA-256
fetch() {
    local repo=$1 tag=$2 asset=$3 digest
    digest=$(curl -fsSL "https://api.github.com/repos/${repo}/releases/tags/${tag}" \
        | jq -r --arg n "${asset}" '.assets[] | select(.name == $n) | .digest // empty') || return 1
    if [[ "${digest}" != sha256:* ]]; then
        echo "security-tools: no SHA-256 digest for ${repo} ${tag} ${asset}" >&2
        return 1
    fi
    curl -fsSL -o "${WORK}/${asset}" "https://github.com/${repo}/releases/download/${tag}/${asset}" || return 1
    echo "${digest#sha256:}  ${WORK}/${asset}" | sha256sum -c --quiet - || return 1
}

install_trivy() {
    local a="trivy_${TRIVY_VERSION}_Linux-${TRIVY_ARCH}.tar.gz"
    fetch aquasecurity/trivy "v${TRIVY_VERSION}" "${a}" &&
        tar -xzf "${WORK}/${a}" -C "${WORK}" trivy &&
        install -m 0755 "${WORK}/trivy" /usr/local/bin/trivy
}

install_kube_bench() {
    local a="kube-bench_${KUBE_BENCH_VERSION}_linux_${ARCH}.deb"
    fetch aquasecurity/kube-bench "v${KUBE_BENCH_VERSION}" "${a}" &&
        apt-get install -y -qq "${WORK}/${a}" > /dev/null
}

install_syft() {
    local a="syft_${SYFT_VERSION}_linux_${ARCH}.tar.gz"
    fetch anchore/syft "v${SYFT_VERSION}" "${a}" &&
        tar -xzf "${WORK}/${a}" -C "${WORK}" syft &&
        install -m 0755 "${WORK}/syft" /usr/local/bin/syft
}

install_cosign() {
    local a="cosign-linux-${ARCH}"
    fetch sigstore/cosign "v${COSIGN_VERSION}" "${a}" &&
        install -m 0755 "${WORK}/${a}" /usr/local/bin/cosign
}

install_kube_linter() {
    local a="kube-linter-linux${KUBE_LINTER_SUFFIX}"
    fetch stackrox/kube-linter "v${KUBE_LINTER_VERSION}" "${a}" &&
        install -m 0755 "${WORK}/${a}" /usr/local/bin/kube-linter
}

install_sysdig() {
    local a="sysdig-${SYSDIG_VERSION}-${UNAME_M}.deb"
    fetch draios/sysdig "${SYSDIG_VERSION}" "${a}" &&
        apt-get install -y -qq "${WORK}/${a}" > /dev/null
}

failed=()
for tool in trivy:TRIVY_VERSION kube-bench:KUBE_BENCH_VERSION syft:SYFT_VERSION \
            cosign:COSIGN_VERSION kube-linter:KUBE_LINTER_VERSION sysdig:SYSDIG_VERSION; do
    name=${tool%%:*}
    var=${tool#*:}
    version=${!var}
    marker="${MARKERS}/${name}-${version}"
    if [[ -f "${marker}" ]] && command -v "${name}" > /dev/null; then
        echo "security-tools: ${name} ${version} already installed"
        continue
    fi
    if "install_${name//-/_}"; then
        rm -f "${MARKERS}/${name}"-*
        touch "${marker}"
        echo "security-tools: ${name} ${version} installed"
    else
        echo "security-tools: ${name} ${version} FAILED" >&2
        failed+=("${name}")
    fi
done

if (( ${#failed[@]} )); then
    echo "security-tools: failed: ${failed[*]}" >&2
    exit 1
fi
