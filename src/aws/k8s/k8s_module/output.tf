output "cluster-name" {
  value = var.cluster-name
}

output "control_plane_public_dns" {
  value = aws_instance.control-plane.public_dns
}

output "control_plane_public_ip" {
  value = aws_instance.control-plane.public_ip
}

output "node01_public_dns" {
  value = aws_spot_instance_request.node[0].public_dns
}

output "node01_public_ip" {
  value = aws_spot_instance_request.node[0].public_ip
}

output "node02_public_dns" {
  value = aws_spot_instance_request.node[1].public_dns
}

output "node02_public_ip" {
  value = aws_spot_instance_request.node[1].public_ip
}

output "kubeconfig" {
  value = module.kubeconfig.stdout
}

output "cluster-admin-token" {
   value = module.cluster-admin-token.stdout
}
