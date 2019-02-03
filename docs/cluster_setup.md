
# Cluster Setup

## Bring the cluster up

a) For Mac/Linux - open the terminal and go to `labs/kubeadm-vagrant`. For
   Windows - open Git-bash and go to the `labs/kubeadm-vagrant` folder (Ex. `cd
   /c/Users/<user name>/Desktop/labs/kubeadm-vagrant`).

b) Power on the VMs:

- control-plane node: `vagrant up control-plane`. After the VM finish the
  initialization, the output should end with the message: `“Enjoy”`.
- worker nodes: `vagrant up node01` and `vagrant up node02`

c) In order to test the cluster, from your local machine open the browser and go
to: [https://k8s.local:30443](https://k8s.local:30443). You should see the K8s
Dashboard:

<img alt="K8s Dashboard login" src="../docs/images/k8s_dashboard_login.png" width="600px" />

Note: If you are using Google Chrome, you might hit `NET::ERR_CERT_INVALID`.
Because we know this is our app, we should trust it. To bypass Google Chrome
error, type `thisisunsafe` and hit enter.

d) To authenticate to this dashboard, use the token from this file:
`kubeadm-vagrant/src/output/cluster_admin_token.txt`.

<img alt="K8s Dashboard" src="../docs/images/k8s_dashboard.png" width="800px" />

Enjoy;
