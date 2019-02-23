output "cluster_info" {
  value = [
    for name in module.clusters : {
      cluster-name : name.cluster-name
      control-plane-public-ip : name.control_plane_public_ip
      control-plane-public-dns : name.control_plane_public_dns
    }
  ]
}