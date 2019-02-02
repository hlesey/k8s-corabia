
# Cluster Setup

## Bring the cluster up

a) For Mac/Linux - open the terminal and go to `labs/kubeadm-vagrant`.
   For Windows - open Git-bash and go to the `labs/kubeadm-vagrant` folder (Ex. `cd /c/Users/<user name>/Desktop/labs/kubeadm-vagrant`).

b) Power on the VMs:

- master node: `vagrant up master`. Afer the VM finish the initialization, the output sould end with the message: `“Enjoi.”`.
- worker nodes: `vagrant up node01` and `vagrant up node02`

c) In order to test the cluster, from your local machine open the browser and go to: [https://k8s.local:30443](https://k8s.local:30443). You should see the K8s Dashboard:

![K8s Dashboard login](./images/k8s_dashboard_login.png)

d) To authenticate to this dashboard, use the token from this file: `kubeadm-vagrant/src/output/cluster_admin_token.txt`.

![K8s Dashboard](./images/k8s_dashboard.png)

Enjoi;
