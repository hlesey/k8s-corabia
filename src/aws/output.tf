output "cluster_info" {
  value = [
    for name in module.clusters : {
      Cluster_Name : name.cluster-name
      Control_Plane_Public_IP : name.control_plane_public_ip
      Control_Plane_Public_DNS : name.control_plane_public_dns
    }
  ]
}