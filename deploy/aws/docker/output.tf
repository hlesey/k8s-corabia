
output "dockerhost_info" {
  value = [
    for name in module.dockerhost : {
      dockerhost-name : name.dockerhost-name
      dockerhost-public-ip : name.dockerhost_public_ip
      dockerhost-public-dns : name.dockerhost_public_dns
    }
  ]
}
