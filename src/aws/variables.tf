variable "region" {
  default = "eu-central-1"
}

variable "az" {
  default = "a"
}

variable "k8s-ssh-key-path" {
  default = "~/.ssh/id_rsa_k8s_test"
}

variable "k8s-ssh-key" {
  default = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDNpn+BqQupT8UmoaPnhFSZbGc7NGpLc7a83NbyaACmxkbg1A+4Xa/YArHQJ7ShcEXajnkbGLSb0U/BUt3BTavCQh+W62FLSrbTncgPIylCptaNLQ/5vbqrc7lNuBB1FxbinwBp75YWbl3PjXzGdnexznXH+gVIsJJKkngTeeckEN3AvonkHgQNpPY0XzsgeirKWpmXv+uUBs8J4jmba4OVt3yd7MTZ5UdPXmrrlJUEKZRw+anzVsitI+OW2obVlD9DoRhHEMYuaOTl6NbVRimI4vM1CqjTLivUYVC29txqmRehtMMwS8nkVNyxn7GccBAsgg/won5YTkCr6TRQFo6Ah5U6neELw46TmNKYpsZwQ7TivpYk9uYJqiph8I+i1gPA1t0+84lZDA+feigiY9k5R0nbVYrsszDNsuLGjttudeq6Fw8EG+cgEkPFyrGOXAxybIlls8TQW3/RtcHwOJaCprBZbr441ZzuUp8BwD61QygI1MKfEgBE6qETpT93jIQnJbmYTET91D8WZe4wRoM1k083isxFtS5enGwaEdnedspTxB7d/fcP5Zob/V20BUMYsH4z2syLCAa9x4FJeokAN2Js962Yz5hvNispVgv/kfb9FFIBmDFtmp2XhcMQ8OaEPyvk/p25wJtlkJLrH6bButNTSikYvLxSWSWS5nmWsw== aneci"
}

variable "k8s-ssh-key-name" {
  default = "test-ssh"
}