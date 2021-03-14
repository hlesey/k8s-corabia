variable "region" {
  default = "eu-central-1"
}

variable "az" {
  default = "a"
}

variable "k8s-ssh-key-path" {
  default = "~/.ssh/id_rsa_local"
}

variable "k8s-ssh-key" {
  default = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDlT3F3OejZwEishIaViqpbCUyE5TEpga4t2+UKeTWLYWYunPez50YMTTH7jByXFX7Kfbeln5jfk/FKssCKQJKnQCTU4AaRUp1vnWwmsc6ehcrk6/CzKhP073GQwpM2fgCUTNUw5AYJZruMLtcDJwNdZhnr1giajEF983I/ZWu25NpzO9zzSO3WdySMQSIWP7N5W/X/rIyubL2SjJJnCt1UH5zf8HfZiaLArDfauLZGvv30oa9e81TPKvyAklhF0TU+nYHwnL0SQoytsiljjSvpFqCgM9bshuVHXaD/P+FcHYRg9dteT8C5oDPQIVG6w0qkPQyRK9sYkARz37BzuJAkAL9RrWpK5y5FziKOUTA5YHMScVYZLqxS6MVf8Xn6n//w2cahJxWourq2Doyuj0OwgwHNIbDiEZEeN92nAo5iRcwKEKYT5RKjm/+qBufgOVX/4sM6byZ1dn8CHJTZqa2i3mI7KGY3G6QtLE4OlayaJHnAMrnWuKF7azoOv8uzuMIqdutBeDZifp70qUgkVZkTU2Ic8HU+ZQ48X8HuZrlENZ+aV5h7jXJDLVHEqgY6DypDre07oe8AeYkEfUMxtIOjgmkReEanxhA3Oy0q8RqTnr9LCpfqUcy5oLe6zQP3Y3Jy3tg/C7fbVM22N2m5f3TkinQHJF6NW9LZ4QL6wpFogQ=="
}

variable "k8s-ssh-key-name" {
  default = "test-ssh"
}