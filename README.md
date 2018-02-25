# Kuberntes cluster setup with Kubeadm, Vagrant, VirtualBox

This repository provides a bunch of scripts necessary to run a minimum local K8s cluster for testing and learning purpose. The following software are used:
- [VirtualBox](https://www.virtualbox.org/) for virtualization
- [Vagrant](https://www.vagrantup.com/) for Virtual Machines template deployment
- [Kubeadm](https://github.com/kubernetes/kubeadm) for K8s cluster boostrap

![Cluster diagram](./docs/images/cluster_diagram.png)

In order to run this cluster on your local laptop or PC, please go thought the following docs:
- [prerequisites](./docs/prerequisites.md)
- [cluster setup](./docs/cluster_setup.md)