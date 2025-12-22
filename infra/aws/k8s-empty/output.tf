output "cluster_info" {
  value = [
    for name in module.clusters : {
      cluster-name : name.cluster-name
      lab-control-plane-public-ip : name.control_plane_public_ip
      lab-control-plane-public-dns : name.control_plane_public_dns
      lab-control-plane-private-ip : name.control_plane_private_ip
      lab-control-plane-private-dns : name.control_plane_private_dns
      lab-node-public-ip : name.node_public_ip
      lab-node-public-dns : name.node_public_dns
    }
  ]
}
