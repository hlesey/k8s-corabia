#!/usr/bin/env bash

############################### PRE-PULL DOCKER IMAGES  ###############################
# kube-system images
kubeadm config images pull

## grep -Rni 'image:' src/manifests/ | cut -d ':' -f4,5 | sort -u  | sed 's/"//g' | sort -u
docker pull docker.io/cilium/cilium:v1.6.5
docker pull docker.io/cilium/operator:v1.6.5
docker pull hlesey/toolbox:1.0
docker pull k8s.gcr.io/metrics-server-amd64:v0.3.6
docker pull kubernetesui/dashboard:v2.0.0-rc3
docker pull kubernetesui/metrics-scraper:v1.0.3
docker pull quay.io/coreos/flannel:v0.10.0-amd64
docker pull quay.io/kubernetes-ingress-controller/nginx-ingress-controller:0.28.0

# other usefull images
## grep -Rni 'image:' ../k8s-labs/ | cut -d ':' -f4,5  | grep -v '{' | sed 's/"//g' | sort -u  | grep -v 'arm\|arm64\|ppc64le\|s390x'
docker pull busybox
docker pull debian
docker pull docker.io/istio/citadel:1.2.2
docker pull docker.io/istio/galley:1.2.2
docker pull docker.io/istio/kubectl:1.2.2
docker pull docker.io/istio/mixer:1.2.2
docker pull docker.io/istio/pilot:1.2.2
docker pull docker.io/istio/proxyv2:1.2.2
docker pull docker.io/istio/sidecar_injector:1.2.2
docker pull docker.io/jaegertracing/all-in-one:1.9
docker pull docker.io/prom/prometheus:v2.8.0
docker pull grafana/grafana:6.1.6
docker pull hlesey/html-app:1.0
docker pull hlesey/html-app:2.0
docker pull hlesey/phippy-api:1.0
docker pull hlesey/proxy:1.0
docker pull hlesey/redis:latest
docker pull k8s.gcr.io/nginx-slim:0.8
docker pull k8s.gcr.io/serve_hostname
docker pull mysql
docker pull nginx
docker pull nginx:1.10.0
docker pull nginx:1.7.6
docker pull nginx:1.7.9
docker pull perl
docker pull prom/prometheus:v2.12.0
docker pull qedzone/debug-container
docker pull quay.io/coreos/flannel:v0.10.0-amd64
docker pull quay.io/coreos/kube-state-metrics:v1.9.3
docker pull quay.io/kiali/kiali:v0.20
docker pull redis
