#!/bin/bash

# This is a helper script that can be run on the control-plane to run Kubernetes
# conformance tests.  It is very slow.

set -x
set -o errexit
set -o nounset
set -o pipefail

export KUBECONFIG=~/admin.kubeconfig
export KUBERNETES_CONFORMANCE_TEST=y
export KUBERNETES_PROVIDER=skeleton
export KUBECTL_PATH=$(which kubectl)
export PATH=$PATH:$GOPATH/bin
export GOLANG_VERSION="1.15.2"
export KUBE_VERSION="v1.18.2"
export GOPATH=$HOME/go
export PATH=$PATH:/usr/local/go/bin:$GOPATH/bin
export E2E_FOCUS="\[Conformance\]"
export E2E_SKIP="Flaky|sig-storage|\[Slow\]"
export DRY_RUN=true
if [[ ! -d ~/conformance-setup ]] ; then

    if [[ ! -d /usr/local/go ]]; then

        wget "https://dl.google.com/go/go$GOLANG_VERSION.linux-amd64.tar.gz" -O /tmp/golang.tar.gz
        tar -xzf /tmp/golang.tar.gz -C /usr/local

        sudo chown -R root:root ./go
        sudo mv go /usr/local
    fi

    if [[ ! -d ~/go/src/k8s.io/kubernetes ]]; then
        mkdir -p ~/go/src/k8s.io
        cd ~/go/src/k8s.io
        git clone --depth 50 --branch $KUBE_VERSION https://github.com/kubernetes/kubernetes.git
    fi

  cd ~/go/src/k8s.io/kubernetes
  make ginkgo
  make WHAT='test/e2e/e2e.test' KUBE_VERBOSE=2
  mkdir ~/conformance-setup
else
  cd ~/go/src/k8s.io/kubernetes
fi



_output/bin/ginkgo -v -dryRun=$DRY_RUN -focus="$E2E_FOCUS" -skip="$E2E_SKIP" _output/bin/e2e.test -- \
    --report-dir=~/conformance-setup/results \
    --allowed-not-ready-nodes=1 \
    --node-schedulable-timeout=1s \
    --system-pods-startup-timeout=10s \
    -cluster-ip-range=192.168.234.0/24 > /src/output.txt
